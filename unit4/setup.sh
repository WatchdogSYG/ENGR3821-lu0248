#! /bin/bash
#install MEGA65-core from a clean Ubuntu Linux 18.04
#(AMD64 version) virtualised on an Oracle Virtualbox VM
#Version 6.0.4 r128413

sudo apt-get -y update
echo "--------Installing mega65-core onto a clean Ubuntu 18.04--------"
echo "--------$PWD"
echo "--------Installing git and cloning"
#install git and then clone into a new working directory
sudo apt-get -y install git
git clone https://github.com/MEGA65/mega65-core.git
cd mega65-core
git checkout development

echo "--------Installing mega65 direct dependencies"
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

echo "--------iverilog dependencies"


echo "--------Python 2.7.10"
cd /usr/src
sudo wget https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
sudo tar xzf Python-2.7.10.tgz
cd Python-2.7.10
sudo ./configure
sudo make altinstall
sudo apt-get install -y python-minimal
cd $PWD/mega-65-temp

echo "--------DONE Python2.7.10"

#GNAT for GHDL
sudo apt-get install -y gnat
sudo apt-get -y install bison flex gperf autoconf

echo "________DONE________"
echo -e "________Please make sure you have the following before using mega65:________\n\n- current licenced version of Xilinx Vivado installed\n- enough memory {mem>4GB}\n"
echo -e "________syntax: make [target] ..\ne.g.: make src/tools/monitor_save src/tools/monitor_load src/tools/mega65_ftp bin/te0725.bit"


#swapExtendOptional
#sudo swapoff -a
#sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
#sudo mkswap /swapfile
#sudo swapon /swapfile
#free -h
#sudo swapon --show
#sudo cp /etc/fstab /etc/fstab.bak
#echo '/swapfile swap default 0 0' | tee -a /etc/fstab