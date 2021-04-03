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
    sudo ./install linux   /usr/bin/openev
    # add to the ~/.bashrc the alias openev
    echo "alias openev='/usr/bin/openev/bin/openev' "  >>  ~/.bashrc
    source ~/.bashrc
    # test openev 
    # openev /home/user/jupyter/notebook_gallery/Rasterio/data/world.rgb.tif /home/user/.local/share/cartopy/shapefiles/natural_earth/physical/ne_110m_land.shp

# Install a new version of [R](https://www.r-project.org/) 

    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
    apt update -y 
    apt install -y r-base r-base-core r-recommended r-base-dev

echo Install R studio https://rstudio.com
   
    # First install dependencies libraries
    sudo apt install -y lib32gcc1 lib32stdc++6 libc6-i386 libclang-6.0-dev libclang-common-6.0-dev libclang-dev libclang1-6.0 libgc1c2 libobjc-7-dev libobjc4
    # download and install rstudio 
    wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.4.1106-amd64.deb
    sudo dpkg -i rstudio-1.4.1106-amd64.deb
    # test rstudio
    # rstudio    

echo  Install additional editors
    
    # one of the oldest editor which is still used my many programmer
    apt install -y emacs25
    # and editor markdown language
    add-apt-repository -y ppa:wereturtle/ppa
    apt update -y
    apt install -y ghostwriter
    # test ghostwriter
    # ghostwriter /home/user/jupyter/notebook_gallery/Pandas_py3/README.md

echo  Download the data and start to follow the exercises.

    cd $HOME
    git clone  https://github.com/selvaje/SE_data.git
