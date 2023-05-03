#!/bin/bash

echo "installing dependencies"

sudo apt-get update
sudo apt remove -y python3-xarray || true
sudo apt-get install -y  \
        apt-utils \
        curl \
        git \
        gzip \
        tar \
        unzip \
        build-essential \
        make \
        cmake \
        libtool \
        swig \
        sqlite3 \
        zlib1g-dev \
        libgdal-dev \
        libproj-dev \
        libgeotiff-dev \
        libgsl-dev \
        libgsl0-dev \
        libfann-dev \
        libfann2 \
        libfftw3-dev \
        libssl-dev \
        libshp-dev \
        uthash-dev \
        libopenblas-dev \
        libjsoncpp-dev \
        libpython3-dev \
        libboost-serialization-dev \
        libboost-filesystem-dev \
        python3-setuptools \
        python3 \
        python3-dev \
        python3-numpy \
        python3-gdal \
        python3-pip \
        python3-wheel \
        python3-xarray \
        python3-netcdf4 \
        python3-pyproj \
        python3-pip-whl

echo "install mial, jiplib, and pyjeo"

#
# Download and compile libraries
#

# Env vars for paths, library versions
INSTALL_HOME=$HOME/pyjeo-install

# Prepare compilation directory
mkdir -p $INSTALL_HOME


#
# Download and compile libraries
#
curl -L --output $INSTALL_HOME/mial.tar.gz https://github.com/ec-jrc/jeolib-miallib/archive/refs/tags/v1.1.0.tar.gz


#- mial
set -xe \
    && cd $INSTALL_HOME \
    && tar xzvf mial.tar.gz \
    && cd $INSTALL_HOME/jeolib-miallib* \
    && mkdir build \
        && cd build \
        && cmake .. \
        && sleep 5 \
        && make -j $NCPU \
        && sudo make install \
    && sudo ldconfig \
    && cd $INSTALL_HOME \
    && rm mial.tar.gz \
    && rm -rf $INSTALL_HOME/jeolib-miallib*

curl -L --output $INSTALL_HOME/jiplib.tar.gz https://github.com/ec-jrc/jeolib-jiplib/archive/refs/tags/v1.1.1.tar.gz

# - jiplib
set -xe \
    && cd $INSTALL_HOME \
    && tar xzvf jiplib.tar.gz \
    && cd $INSTALL_HOME/jeolib-jiplib* \
    && mkdir build \
    && cd build \
    && cmake .. \
    && sleep 5 \
    && make -j $NCPU \
    && sudo make install \
    && sudo ldconfig \
    && cd $INSTALL_HOME \
    && rm jiplib.tar.gz \
    && rm -rf $INSTALL_HOME/jeolib-jiplib*

curl -L --output $INSTALL_HOME/pyjeo.tar.gz https://github.com/ec-jrc/jeolib-pyjeo/archive/refs/tags/v1.1.2.tar.gz

# - pyjeo
cd $INSTALL_HOME \
    && tar xzvf pyjeo.tar.gz \
    && cd $INSTALL_HOME/jeolib-pyjeo* \
    && python3 setup.py install --user --prefix= \
    && cd $INSTALL_HOME \
    && rm pyjeo.tar.gz \
    && rm -rf $INSTALL_HOME/jeolib-pyjeo*
