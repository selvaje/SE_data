# Prepare OSGeoLive for Spatial Ecology courses


In order to execute the Spatial Ecology exercise we will need first install the OSGeoLive Linux Virtual Machine and then populate with additional software and data.

[OSGeoLive](https://live.osgeo.org/en/index.html) is a self-contained bootable DVD, USB thumb drive or Virtual Machine based on Lubuntu, that allows you to try a wide variety of open source geospatial software without installing anything. It is composed entirely of free software, allowing it to be freely distributed, duplicated and passed around (source https://live.osgeo.org/en/index.html)

For running a Virtual Machine in your OS we need a virtualization software such as [Virtualbox](https://www.virtualbox.org/) and a vmdk file that contains the virtualized OS.

**Install Virtualbox**

Open you browser and go to [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads) and base on your OS download the Virtualbox executable and install it. 

**Download OSGeoLive**

Open you browser and go to [https://sourceforge.net/projects/osgeo-live/files/](https://sourceforge.net/projects/osgeo-live/files/). Proceed with the download of osgeolive-13.0-amd64.vmdk.7z. The osgeolive-13.0-amd64.vmdk.7z is a quite large file therefore according to your Internet connection it can take several hours. When the download is finished unzipped. A this point you are ready to load the osgeolive-13.0-amd64.vmdk inside Virtualbox. 

**Install OSGeoLive inside Virtualbox**

Lunch Virtualbox from OS and follow the below instructions. 

![title](Installation_vm_osgeo-live13_p0.png)
![title](Installation_vm_osgeo-live13_p1.png)
![title](Installation_vm_osgeo-live13_p2.png)
![title](Installation_vm_osgeo-live13_p3.png)
![title](Installation_vm_osgeo-live13_p4.png)
![title](Installation_vm_osgeo-live13_p5.png)
![title](Installation_vm_osgeo-live13_p6.png)
![title](Installation_vm_osgeo-live13_p7.png)
![title](Installation_vm_osgeo-live13_p8.png)
![title](Installation_vm_osgeo-live13_p9.png)



**Populate OSGeoLive with additional software**

Open the terminal and run line by line the following codes. The sudo password is "user". For security what you type is not shown, anyway it is recorded. After typed the password press enter.

Update the OS. This operation can last few minutes. Be patient. 

    sudo apt update   # update the repositories
    sudo apt upgrade  # installation of the sw

Add to Virtualbox additional add-on to improve the graphical user interface of the VM.
From the Virtualbox menu press Device > Insert Guest Addition CD image

    cd /media/user/VBox_GAs_*
    sudo ./VBoxLinuxAdditions.run

Install pktools

    sudo apt install pktools 

Install openev

    # first install dependencies libraries
    sudo apt-get install libc6:i386 libxext6:i386 libstdc++5
    # download and unzip openev 
    cd /tmp
    wget https://sourceforge.net/projects/openev/files/OpenEV/1.8.0/openev-linux-180.tar.gz
    tar xvf openev-linux-180.tar.gz
    #install openev
    cd openev
    sudo ./install linux   /usr/bin/openev
    # add to the ~/.bashrc the alias openev
    echo "alias openev='/usr/bin/openev/bin/openev' "  >>  ~/.bashrc
    source ~/.bashrc

Install a new version of R 

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
    sudo apt update 
    sudo apt install r-base r-base-core r-recommended r-base-dev

Install R studio
   
    # First install dependencies libraries
    sudo apt install lib32gcc1 lib32stdc++6 libc6-i386 libclang-6.0-dev libclang-common-6.0-dev libclang-dev libclang1-6.0 libgc1c2 libobjc-7-dev libobjc4
    # download and install rstudio 
    wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.3.1093-amd64.deb
    sudo dpkg -i rstudio-1.3.1093-amd64.deb
    
Install additional editors
    
    # one of the oldest editor which is still used my many programmer
    sudo apt install emacs25
    # and editor markdown language
    sudo add-apt-repository ppa:wereturtle/ppa
    sudo apt-get update
    sudo apt-get install ghostwriter

Download the data and start to follow the exercises.

    cd $HOME
    git clone  https://github.com/selvaje/SE_data.git
