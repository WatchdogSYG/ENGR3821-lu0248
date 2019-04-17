#! /bin/bash
#install MEGA65-core from a clean Ubuntu Linux 18.04
#(AMD64 version) virtualised on an Oracle Virtualbox VM
#Version 6.0.4 r128413

echo "--------Installing mega65-core from a clean Ubuntu 18.04--------"
echo "AUTO: $PWD"
echo "AUTO: Installing git and cloning"
#install git and then clone into a new working directory
sudo apt-get -y install git
git clone https://github.com/MEGA65/mega65-core.git
git checkout development

echo "AUTO: Installing dependencies"
#install dependencies
sudo apt install make
sudo apt-get -y install gcc

#python 2.7.10
#instructions: https://tecadmin.net/install-python-2-7-on-ubuntu-and-linuxmint/
sudo apt-get -y update
sudo apt-get -y install build-essential checkinstall
sudo apt-get -y install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
cd /usr/src
sudo wget https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
sudo tar xzf Python-2.7.10.tgz
cd Python-2.7.10
sudo ./configure
sudo make altinstall
cd $PWD

#fpgajtag
sudo apt-get -y install libusb-1.0-0-dev
git clone https://github.com/cambridgehackers/fpgajtag.git
cd fpgajtag
make
