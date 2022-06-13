#!/bin/bash

echo "installing dependencies"

apt-get update
apt-get install -y  --no-install-recommends \
                      apt-utils \
                      build-essential \
                      cmake \
                      libgdal-dev \
                      make \
                      python3 \
                      python3-dev \
                      python3-numpy \
                      python3-gdal \
                      python3-pip \
                      python3-wheel \
                      python-pip-whl \
                      sqlite3 \
                      swig \
                      zlib1g-dev \
                      libgeotiff-dev \
                      libgsl0-dev \
                      libfann-dev \
                      libfftw3-dev \
                      libshp-dev \
                      uthash-dev \
                      libjsoncpp-dev \
                      libboost-serialization-dev \
                      libboost-filesystem-dev \
                      python3-setuptools \
                      libtool \
                      python3-xarray \
                      python3-netcdf4 \
                      python3-pyproj \
                      curl \
                      git \
                      gzip \
                      tar \
                      unzip

echo "install mial, jiplib, and pyjeo"

#
# Download and compile libraries
#

# Env vars for paths, library versions
INSTALL_HOME=/home/install

# Prepare compilation directory
mkdir -p $INSTALL_HOME


#
# Download and compile libraries
#
curl -L --output $INSTALL_HOME/mial.tar.gz https://github.com/ec-jrc/jeolib-miallib/archive/refs/tags/v1.0.2.tar.gz --verbose

# - mial
set -xe \
    && cd $INSTALL_HOME \
    && tar xzvf mial.tar.gz \
    && cd $INSTALL_HOME/jeolib-miallib* \
    && make generic \
    && make install-generic \
    && ldconfig \
    && cd $INSTALL_HOME \
    && rm mial.tar.gz \
    && rm -rf $INSTALL_HOME/jeolib-miallib*

curl -L --output $INSTALL_HOME/jiplib.tar.gz https://github.com/ec-jrc/jeolib-jiplib/archive/refs/tags/v1.0.8.tar.gz --verbose

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
    && make install \
    && ldconfig \
    && cd $INSTALL_HOME \
    && rm jiplib.tar.gz \
    && rm -rf $INSTALL_HOME/jeolib-jiplib*

curl -L --output $INSTALL_HOME/pyjeo.tar.gz https://github.com/ec-jrc/jeolib-pyjeo/archive/refs/tags/v1.0.8.tar.gz --verbose

# - pyjeo
cd $INSTALL_HOME \
    && tar xzvf pyjeo.tar.gz \
    && cd $INSTALL_HOME/jeolib-pyjeo* \
    && python3 setup.py install \
    && cd $INSTALL_HOME \
    && rm -rf $INSTALL_HOME/jeolib-pyjeo*
    #&& rm pyjeo.tar.gz
