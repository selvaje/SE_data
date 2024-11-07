import os
import torch
import matplotlib.pyplot as plt
import numpy as np
import rasterio
import yaml
from prithvi.Prithvi import MaskedAutoencoderViT
import requests
import argparse

# Imports
from mmcv import Config
from mmseg.models import build_segmentor
from mmseg.datasets.pipelines import Compose, LoadImageFromFile
from mmseg.apis import init_segmentor
from model_inference import inference_segmentor, process_test_pipeline
from huggingface_hub import hf_hub_download
import matplotlib
from torch import nn

import warnings
warnings.filterwarnings("ignore")

NO_DATA = -9999
NO_DATA_FLOAT = 0.0001
PERCENTILES = (0.1, 99.9)

path_to_save = os.getenv('HOME')

def parse_args():
    parser = argparse.ArgumentParser(
        description="Calling models for inference"
    )
    parser.add_argument("-model_name", help="options are: 'masked_pred','flood_pred','crop_pred','finetune'", default="masked_pred", type=str)
    parser.add_argument("-device", help="device", default="cpu", type=str)

    args = parser.parse_args()

    return args

# """### Define some functions for visualization"""

def load_raster(path, crop=None):
    with rasterio.open(path) as src:
        img = src.read()

        # load first 6 bands
        img = img[:6]

        img = np.where(img == NO_DATA, NO_DATA_FLOAT, img)
        if crop:
            img = img[:, -crop[0]:, -crop[1]:]
    return img

def enhance_raster_for_visualization(raster, ref_img=None):
    if ref_img is None:
        ref_img = raster
    channels = []
    for channel in range(raster.shape[0]):
        valid_mask = np.ones_like(ref_img[channel], dtype=bool)
        valid_mask[ref_img[channel] == NO_DATA_FLOAT] = False
        mins, maxs = np.percentile(ref_img[channel][valid_mask], PERCENTILES)
        normalized_raster = (raster[channel] - mins) / (maxs - mins)
        normalized_raster[~valid_mask] = 0
        clipped = np.clip(normalized_raster, 0, 1)
        channels.append(clipped)
    clipped = np.stack(channels)
    channels_last = np.moveaxis(clipped, 0, -1)[..., :3]
    rgb = channels_last[..., ::-1]
    return rgb

def plot_image_mask_reconstruction(normalized, mask_img, pred_img, means, stds, input_data):
    # Mix visible and predicted patches
    rec_img = normalized.clone()
    rec_img[mask_img == 1] = pred_img[mask_img == 1]  # binary mask: 0 is keep, 1 is remove

    mask_img_np = mask_img.numpy().reshape(6, 224, 224).transpose((1, 2, 0))[..., :3]

    rec_img_np = (rec_img.numpy().reshape(6, 224, 224) * stds) + means

    fig, ax = plt.subplots(1, 3, figsize=(15, 6))

    for subplot in ax:
        subplot.axis('off')

    ax[0].imshow(enhance_raster_for_visualization(input_data))
    ax[0].set_title('Original')
    masked_img_np = enhance_raster_for_visualization(input_data).copy()
    masked_img_np[mask_img_np[..., 0] == 1] = 0
    ax[1].imshow(masked_img_np)
    ax[1].set_title('Random masking')
    ax[2].imshow(enhance_raster_for_visualization(rec_img_np, ref_img=input_data))
    ax[2].set_title('Reconstruction')
    print('Saving model prediction')
    plt.savefig('./test_outputs/output_reconstruction.png', bbox_inches='tight', pad_inches=0)
    
def preprocess_image(image, means, stds):
    # normalize image
    normalized = image.copy()
    normalized = ((image - means) / stds)
    normalized = torch.from_numpy(normalized.reshape(1, normalized.shape[0], 1, *normalized.shape[-2:])).to(torch.float32)
    return normalized

def download_file(url, local_filename):
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
    return local_filename

"""### Loading the model
Assuming you have the relevant files under this directory
"""

def main(model_name, device): 
    # load weights
    weights_path = "./prithvi/Prithvi_100M.pt"
    checkpoint = torch.load(weights_path, map_location="cpu")
    
    # Create 'test_outputs' folder to save outputs in case it doesn't exist
    output_folder = os.path.join(path_to_save,'test_outputs')
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    
    # read model config
    if model_name=='masked_pred': 
        model_cfg_path = "./prithvi/Prithvi_100M_config.yaml"
        with open(model_cfg_path) as f:
            model_config = yaml.safe_load(f)

        model_args, train_args = model_config["model_args"], model_config["train_params"]

        # let us use only 1 frame for now (the model was trained on 3 frames)
        model_args["num_frames"] = 1

        # instantiate model
        model = MaskedAutoencoderViT(**model_args)
        model.eval()

        # load weights into model
        # strict=false since we are loading with only 1 frame, but the warning is expected
        del checkpoint['pos_embed']
        del checkpoint['decoder_pos_embed']
        _ = model.load_state_dict(checkpoint, strict=False)

        """ Let's try it out!
        We can access the images directly from the HuggingFace space thanks to rasterio
        """

        raster_path = "https://huggingface.co/spaces/ibm-nasa-geospatial/Prithvi-100M-demo/resolve/main/HLS.L30.T13REN.2018013T172747.v2.0.B02.B03.B04.B05.B06.B07_cropped.tif"
        input_data = load_raster(raster_path, crop=(224, 224))
        # print(f"Input data shape is {input_data.shape}")
        raster_for_visualization = enhance_raster_for_visualization(input_data)
        plt.imshow(raster_for_visualization)

        # Save the image
        plt.savefig(os.path.join(output_folder,'input_data.png'), bbox_inches='tight', pad_inches=0)

        """Lets call the model!
        We pass:
         - The normalized input image, cropped to size (224, 224)
         - `mask_ratio`: The proportion of pixels that will be masked

        The model returns a tuple with:
         - loss
         - reconstructed image
         - mask used
        """

        # statistics used to normalize images before passing to the model
        means = np.array(train_args["data_mean"]).reshape(-1, 1, 1)
        stds = np.array(train_args["data_std"]).reshape(-1, 1, 1)

        normalized = preprocess_image(input_data, means, stds)
        with torch.no_grad():
            mask_ratio = 0.5
            _, pred, mask = model(normalized, mask_ratio=mask_ratio)
            mask_img = model.unpatchify(mask.unsqueeze(-1).repeat(1, 1, pred.shape[-1])).detach().cpu()
            pred_img = model.unpatchify(pred).detach().cpu()

        """ Lets use these to build a nice output visualization"""

        plot_image_mask_reconstruction(normalized, mask_img, pred_img, means, stds, input_data)
        plt.savefig(os.path.join(output_folder,'output_masked_data.png'), bbox_inches='tight', pad_inches=0)

        
    elif model_name == 'flood_pred':
        """Inference with finetuned Prithvi

        Let's explore a finetuned example - Flood Segmentation

        This time, lets use the huggingface hub library to directly download the files for the finetuned model. 
        To install huggingface, run the command below
        %pip install huggingface_hub

        """

        '''
        Inference with finetuned Prithvi
        Let's explore a model for flood classification
        '''
        print('\nStarting the flood classification test')
        config_path=hf_hub_download(repo_id="ibm-nasa-geospatial/Prithvi-100M-sen1floods11", filename="sen1floods11_Prithvi_100M.py")
        ckpt=hf_hub_download(repo_id="ibm-nasa-geospatial/Prithvi-100M-sen1floods11", filename='sen1floods11_Prithvi_100M.pth')
        # finetuned_model = init_segmentor(Config.fromfile(config_path), ckpt, device="cpu")
        print('Loading model...')
        finetuned_model = init_segmentor(Config.fromfile(config_path), ckpt, device=device)

        """Let's grab an image to do inference on"""

        download_file('https://huggingface.co/spaces/ibm-nasa-geospatial/Prithvi-100M-sen1floods11-demo/resolve/main/Spain_7370579_S2Hand.tif', 'Spain_7370579_S2Hand.tif')
        download_file('https://huggingface.co/spaces/ibm-nasa-geospatial/Prithvi-100M-sen1floods11-demo/resolve/main/India_900498_S2Hand.tif', 'India_900498_S2Hand.tif')
        download_file('https://huggingface.co/spaces/ibm-nasa-geospatial/Prithvi-100M-sen1floods11-demo/resolve/main/USA_430764_S2Hand.tif', 'USA_430764_S2Hand.tif')

        input_data_inference = load_raster("Spain_7370579_S2Hand.tif")
        # print(f"Image input shape is {input_data_inference.shape}")
        raster_for_visualization = enhance_raster_for_visualization(input_data_inference)
        plt.axis('off')
        plt.imshow(raster_for_visualization)
        # Save the output image
        plt.savefig(os.path.join(output_folder,'input_data_flood.png'), bbox_inches='tight', pad_inches=0)
        plt.close('all')

        custom_test_pipeline = process_test_pipeline(finetuned_model.cfg.data.test.pipeline)
        result = inference_segmentor(finetuned_model, "Spain_7370579_S2Hand.tif", custom_test_pipeline=custom_test_pipeline)
        del raster_for_visualization, input_data_inference

        # Let's plot the results
        fig, ax = plt.subplots(1, 3, figsize=(15, 10))
        input_data_inference = load_raster("Spain_7370579_S2Hand.tif")
        norm = matplotlib.colors.Normalize(vmin=0, vmax=2)
        ax[0].imshow(enhance_raster_for_visualization(input_data_inference))
        # ax[1].imshow(result[0], norm=norm, cmap="jet")
        ax[1].imshow(result[0], norm=norm)
        ax[2].imshow(enhance_raster_for_visualization(input_data_inference))
        ax[2].imshow(result[0], cmap="jet", alpha=0.3, norm=norm)
        for subplot in ax:
            subplot.axis('off')
        plt.savefig(os.path.join(output_folder,'flood_prediction_Spain.png'), bbox_inches='tight', pad_inches=0)
        plt.close('all')

        filename = "USA_430764_S2Hand.tif"
        input_data_inference = load_raster(filename)
        # print(f"Image input shape is {input_data_inference.shape}")
        raster_for_visualization = enhance_raster_for_visualization(input_data_inference)
        plt.axis('off')
        plt.imshow(raster_for_visualization)
        # adapt this pipeline for Tif files with > 3 images
        custom_test_pipeline = process_test_pipeline(finetuned_model.cfg.data.test.pipeline)
        result = inference_segmentor(finetuned_model, filename, custom_test_pipeline=custom_test_pipeline)
        fig, ax = plt.subplots(1, 3, figsize=(15, 10))
        input_data_inference = load_raster(filename)
        norm = matplotlib.colors.Normalize(vmin=0, vmax=2)
        ax[0].imshow(enhance_raster_for_visualization(input_data_inference))
        # ax[1].imshow(result[0], norm=norm, cmap="jet")
        ax[1].imshow(result[0], norm=norm)
        ax[2].imshow(enhance_raster_for_visualization(input_data_inference))
        ax[2].imshow(result[0], cmap="jet", alpha=0.3, norm=norm)
        for subplot in ax:
            subplot.axis('off')
        plt.savefig(os.path.join(output_folder,'flood_prediction_USA.png'), bbox_inches='tight', pad_inches=0)
        plt.close('all')
        del raster_for_visualization, input_data_inference

        filename = "India_900498_S2Hand.tif"
        input_data_inference = load_raster(filename)
        # print(f"Image input shape is {input_data_inference.shape}")
        raster_for_visualization = enhance_raster_for_visualization(input_data_inference)
        plt.axis('off')
        plt.imshow(raster_for_visualization)

        custom_test_pipeline = process_test_pipeline(finetuned_model.cfg.data.test.pipeline)
        # print('custom_test_pipeline: ',custom_test_pipeline)
        result = inference_segmentor(finetuned_model, filename, custom_test_pipeline=custom_test_pipeline)
        fig, ax = plt.subplots(1, 3, figsize=(15, 10))
        input_data_inference = load_raster(filename)
        norm = matplotlib.colors.Normalize(vmin=0, vmax=2)
        ax[0].imshow(enhance_raster_for_visualization(input_data_inference))
        # ax[1].imshow(result[0], norm=norm, cmap="jet")
        ax[1].imshow(result[0], norm=norm)
        ax[2].imshow(enhance_raster_for_visualization(input_data_inference))
        ax[2].imshow(result[0], cmap="jet", alpha=0.3, norm=norm)
        for subplot in ax:
            subplot.axis('off')
        plt.savefig(os.path.join(output_folder,'flood_prediction_India.png'), bbox_inches='tight', pad_inches=0)
        plt.close('all')
        del raster_for_visualization, input_data_inference
        del finetuned_model
    
    elif model_name == 'crop_pred':
        '''
        Inference with finetuned Prithvi
        Let's explore a second finetuned model - Crop Classification
        '''
        print('\nStarting the crop classification test')
        config_path=hf_hub_download(repo_id="ibm-nasa-geospatial/Prithvi-100M-multi-temporal-crop-classification",filename="multi_temporal_crop_classification_Prithvi_100M.py")
        ckpt=hf_hub_download(repo_id="ibm-nasa-geospatial/Prithvi-100M-multi-temporal-crop-classification",filename='multi_temporal_crop_classification_Prithvi_100M.pth')
        print('Loading model...')
        finetuned_model = init_segmentor(Config.fromfile(config_path), ckpt, device=device)
        print('Done loading!')

        # Download an example image
        download_file('https://huggingface.co/spaces/ibm-nasa-geospatial/Prithvi-100M-multi-temporal-crop-classification-demo/resolve/main/chip_102_345_merged.tif', 'chip_102_345_merged.tif')

        # Load a sample image
        import matplotlib.patches as mpatches
        # filename = "/project/geocourse/Data/ml/chip_102_345_merged.tif"
        filename = "chip_102_345_merged.tif"
        input_data_inference = load_raster(filename)
        # print(f"Image input shape is {input_data_inference.shape}")

        # adapt this pipeline for Tif files with > 3 images
        custom_test_pipeline = process_test_pipeline(finetuned_model.cfg.data.test.pipeline)
        result = inference_segmentor(finetuned_model, filename, custom_test_pipeline=custom_test_pipeline)
        # print('result.shape: ',result[0].shape)

        fig, ax = plt.subplots(1, 2, figsize=(15, 10))
        input_data_inference = load_raster(filename)
        norm = matplotlib.colors.Normalize(vmin=0, vmax=13)
        ax[0].imshow(enhance_raster_for_visualization(input_data_inference))
        ax[1].imshow(result[0], norm=norm, cmap="tab20")
        # ax[2].imshow(enhance_raster_for_visualization(input_data_inference))
        # ax[2].imshow(result[0], cmap="jet", alpha=0.3, norm=norm)

        # Turn off axis for all subplots
        for subplot in ax:
            subplot.axis('off')

        # Define the legend handles
        legend_labels = [ 
            "Natural Vegetation",
            "Forest",
            "Corn",
            "Soybeans",
            "Wetlands",
            "Developed/Barren",
            "Open Water",
            "Winter Wheat",
            "Alfalfa",
            "Fallow/Idle Cropland",
            "Cotton",
            "Sorghum",
            "Other"]
        colors = [plt.cm.tab20(norm(i)) for i in range(13)]
        handles = [mpatches.Patch(color=colors[i], label=legend_labels[i]) for i in range(13)]

        # Add the legend to ax[2]
        ax[1].legend(handles=handles, loc='upper right',bbox_to_anchor = (1.5, 1))
        plt.savefig(os.path.join(output_folder,'crop_prediction.png'), bbox_inches='tight', pad_inches=0)
    
    elif model_name == 'finetune': 
    
        ''' Finetuning for your use case
        To finetune, you can now write a PyTorch loop as usual to train on your dataset. Simply extract the backbone from the model with some surgery and run only the model features forward, with no masking!

         In general some reccomendations are:
        - At least in the beggining, experiment with freezing the backbone. This will give you much faster iteration through experiments.
        - Err on the side of a smaller learning rate
        - With an unfrozen encoder, regularization is your friend! (Weight decay, dropout, batchnorm...)
        '''

        # if going with plain pytorch:
        # - remember to normalize images beforehand (find the normalization statistics in the config file)
        # - turn off masking by passing mask_ratio = 0
        normalized = preprocess_image(input_data)
        features, _, _ = model.forward_encoder(normalized, mask_ratio=0)
        print('features.shape: ',features.shape)

        ''' What do these features look like?
        These are the standard output of a ViT.
        - Dim 1: Batch size
        - Dim 2: [`cls_token`] + tokens representing flattened image
        - Dim 3: embedding dimension

        First reshape features into "image-like" shape:
        - Drop cls_token
        - reshape into HxW shape
        '''

        print(f"Encoder features have shape {features.shape}")

        # drop cls token
        reshaped_features = features[:, 1:, :]

        # reshape
        feature_img_side_length = int(np.sqrt(reshaped_features.shape[1]))
        reshaped_features = reshaped_features.view(-1, feature_img_side_length, feature_img_side_length, model_args["embed_dim"])
        # channels first
        reshaped_features = reshaped_features.permute(0, 3, 1, 2)
        print(f"Encoder features have new shape {reshaped_features.shape}")

        ''' Example of a segmentation head
        A simple segmentation head can consist of a few upscaling blocks + a final head for classification
        '''
        num_classes = 2
        upscaling_block = lambda in_channels, out_channels: nn.Sequential(nn.Upsample(scale_factor=2), nn.Conv2d(kernel_size=3, in_channels=in_channels, out_channels=out_channels, padding=1), nn.ReLU())
        embed_dims = [model_args["embed_dim"] // (2**i) for i in range(5)]
        segmentation_head = nn.Sequential(
            *[
            upscaling_block(embed_dims[i], embed_dims[i+1]) for i in range(4)
            ],
            nn.Conv2d(kernel_size=1, in_channels=embed_dims[-1], out_channels=num_classes))

        print('len(embed_dims): ',len(embed_dims))
        print('segmentation_head: ',segmentation_head)
        print('segmentation_head(reshaped_features).shape: ',segmentation_head(reshaped_features).shape)


if __name__ == "__main__":
    # unpack args
    print('Starting...')
    print(f'Saving the outputs to {path_to_save}')
    args = parse_args()
    model_name = args.model_name
    device = args.device
    
    main(model_name,device)
