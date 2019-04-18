#! /bin/bash
#install MEGA65-core from a clean Ubuntu Linux 18.04
#(AMD64 version) virtualised on an Oracle Virtualbox VM
#Version 6.0.4 r128413

echo "--------Installing mega65-core onto a clean Ubuntu 18.04--------"
echo "--------$PWD"
echo "--------Installing git and cloning"
#install git and then clone into a new working directory
sudo apt-get -y install git
git clone https://github.com/MEGA65/mega65-core.git
cd mega65-core
git checkout development
cd ..

echo "--------Installing dependencies"
#install dependencies
echo "--------make"
sudo apt install -y make
echo "--------gcc"
sudo apt-get -y install gcc

#libs required for compilation of fpgajtag and zlib
sudo apt-get install -y libusb-1.0-0-dev

#a temporary file for dumping all dependency install files
mkdir mega-65-temp
cd mega-65-temp
echo "--------fpgajtag"
#TO CLEANUP
git clone https://github.com/cambridgehackers/fpgajtag.git
cd fpgajtag/src
#TO CLEANUP
git clone https://github.com/madler/zlib
sed -i 's|#include <zlib.h>|#include "zlib/zlib.h"|' util.c
sudo apt-get install -y zlib1g-dev
cd ..
make
sudo cp src/fpgajtag /usr/local/bin
cd ..
echo "--------DONE fpgajtag"

#python 2.7.10
#instructions: https://tecadmin.net/install-python-2-7-on-ubuntu-and-linuxmint/
sudo apt-get -y update
echo "--------build-essential checkinstall"
sudo apt-get -y install build-essential checkinstall
echo "--------libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev"
sudo apt-get -y install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

echo "--------libpng-dev"
sudo apt-get install -y libpng-dev

echo "--------cbmconvert 2.1.2"
git clone https://github.com/sasq64/cbmconvert
cd cbmconvert
make -f Makefile.unix
sudo make install

echo "--------Python 2.7.10"
cd /usr/src
sudo wget https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
sudo tar xzf Python-2.7.10.tgz
cd Python-2.7.10
sudo ./configure
sudo make altinstall
cd $PWD/mega-65-temp
echo "--------DONE Python2.7.10"

echo "--------PLEASE INSTALL A RECENT VERSION OF XILINX VIVADO ISE"
#https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools/v2012_4---14_7.html
#Full Installer for Linux (TAR/GZIP - 6.09 GB) 
#MD5 SUM Value : e8065b2ffb411bb74ae32efa475f9817