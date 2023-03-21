echo Install http://pktools.nongnu.org/html/index.html
    
    apt install -y pktools 

echo  Install OpenEV http://openev.sourceforge.net

    # first install dependencies libraries
    apt install -y libc6:i386 libxext6:i386 libstdc++5
    # download and unzip openev 
    cd /tmp
    wget https://sourceforge.net/projects/openev/files/OpenEV/1.8.0/openev-linux-180.tar.gz
    tar xvf openev-linux-180.tar.gz
    #install openev
    cd openev
    bash ./install linux   /usr/bin/openev
    # add to the ~/.bashrc the alias openev
    echo "alias openev='/usr/bin/openev/bin/openev' "  >>  /home/user/.bashrc
    source /home/user/.bashrc
    # test openev 
    # openev /home/user/jupyter/notebook_gallery/Rasterio/data/world.rgb.tif /home/user/.local/share/cartopy/shapefiles/natural_earth/physical/ne_110m_land.shp

# Install a new version of [R](https://www.r-project.org/   ; https://cran.mirror.garr.it/CRAN/ ) 

# apt -y update -qq
# install two helper packages we need
# apt -y install --no-install-recommends software-properties-common dirmngr
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
# wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
# add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# apt -y install --no-install-recommends r-base
    
# echo Install R studio https://rstudio.com
   
# apt-get install gdebi-core
# wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2022.12.0-353-amd64.deb

# gdebi rstudio-2022.12.0-353-amd64.deb
    
echo  Install additional editors
    
    # one of the oldest editor which is still used my many programmer
    apt install -y emacs
    # and editor markdown language
    # add-apt-repository -y ppa:wereturtle/ppa
    # apt update -y
    # apt install -y ghostwriter
    # test ghostwriter
    # ghostwriter /home/user/jupyter/notebook_gallery/Pandas_py3/README.md

echo  Download the data and start to follow the exercises.

