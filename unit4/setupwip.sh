#! /bin/bash
#install MEGA65-core from a clean Ubuntu Linux 18.04
#(AMD64 version) virtualised on an Oracle Virtualbox VM
#Version 6.0.4 r128413

echo "----------------\nInstalling mega65-core from a clean Ubuntu 18.04\n----------------"
echo "Installing GIT"
#install git and then clone into a new working directory
sudo apt-get install git
git clone https://github.com/MEGA65/mega65-core.git

#install dependencies
sudo apt install make
sudo apt-get install libusb-1.0-0-dev


git clone https://github.com/cambridgehackers/fpgajtag.git
cd fpgajtag