#ENGR3812 Network Engineering Unit4 - lu0248 2167078
####MEGA65 Target Compilation form Clean Ubuntu 18.04 VM


## Package Dependencies
* Xilinx Vivado 2018.3 - shell script does not check for valid Vivado installations
* Linux Ubuntu 18.04 - tested using Oracle VirtualBox 6.0.4
* git
* make
* gcc
* libusb-1.0-0-dev
* fpgajtag
* zlib1g-dev
* build-essential
* checkinstall
* libreadline-gplv2-dev
* libncursesw5-dev
* libssl-dev
* libsqlite3-dev
* tk-dev
* libgdbm-dev
* libc6-dev
* libbz2-dev
* libpng-dev
* bison
* flex
* gperf
* autoconf
* Python 2.7.10

##Installation Procedure
###0. Preliminaries
Use a clean install of a Linux Ubuntu 18.04 VM using Oracle VirtualBox VM Manager.

You may have to update the apt database before this process. Use the -y option to skip operator input:

    sudo apt-get update


A gcc compiler and the make capability are required to compile most future packages:

    sudo apt install -y make
    sudo apt-get -y install gcc
    

###1. Install git
Install git and then clone and checkout the development branch of the mega65 repo:

    sudo apt-get -y install git
    git clone https://github.com/MEGA65/mega65-core.git
    cd mega65-core
    git checkout development

###2. Third Party Programs

The direct dependencies of the mega65-core according to the documentation found in the [mega65 repo doc](https://github.com/MEGA65/mega65-core/blob/master/docs/build.md) are:

1. fpgajtag
2. gcc
3. make
4. cbmconvert
5. python (2.7.10)
6. ICARUS Verilog


The next steps will guide you through the installation of the dependencies and their sub-dependencies:

#####1. fpgajtag

The package libusb is required, use apt-get to install it:

    sudo apt-get install -y libusb-1.0-0-dev

Clone the contents of the fpgajtag repository to another directory (eg. mega-65-temp):

    mkdir mega-65-temp
    cd mega-65-temp
    git clone https://github.com/cambridgehackers/fpgajtag.git

The Makefile references zlib.h which it expects to be in the fpgajtag directory. However, for that to happen, the rest of the contents of zlib will have to be in the fpgajtag cirectory. To avoid this mess, change the include statement to point to zlib/zlib.h usig your favourite text editor or using the following command while in ~/fpgajtag:


    sed -i 's|#include <zlib.h>|#include "zlib/zlib.h"|' util.c

Then clone zlib into fpgajtag/src:

    cd fpgajtag/src
    git clone https://github.com/madler/zlib

The library zlib1g-dev is also required. Use apt-get:

    sudo apt-get install -y zlib1g-dev

fpgajtag should now be compilable using make in the ~/fpgajtag directory:

    make

#####2. gcc

Without gcc you would not have been able to install fpgajtag so it should be installed by now.

#####3. make

Without make you would not have been able to install fpgajtag so it should be installed by now.

#####4. cbmconvert


This simply requires libpng which can be installed using apt-get:

    sudo apt-get install -y libpng-dev

Clone the contents of the cbmconvert repository to another directory (eg. mega-65-temp) and use make as below:

    git clone https://github.com/sasq64/cbmconvert
    cd cbmconvert
    make -f Makefile.unix
    sudo make install

#####5. Python 2.7.10

Python can be installed from a [download](https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz) from their website or using the commands below:

    cd /usr/src
    sudo wget     https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
    sudo tar xzf Python-2.7.10.tgz
    cd Python-2.7.10
    sudo ./configure
    sudo make altinstall

Upon calling make on mega65, an error may occur where the installation path of python is not in the expected location of /usr/env/. To work around this the installations or references can be moved or changed respectively or the python-minimal package can be installed instead:

    sudo apt-get install -y python-minimal

#####6. ICARUS Verilog

ICARUS Verilog (iverilog) requires the following packages obtainable through apt-get:

    sudo apt-get install -y bison
    sudo apt-get install -y flex
    sudo apt-get install -y gperf
    sudo apt-get install -y autoconf

###3. Making MEGA65

Calling make in the mega65-core directory will require the following packages to be installed:

1. bison
2. flex
3. gperf
4. autoconf
2. 
3. 
4. 

# headers

*emphasis*

**strong**

* list

>block quote

    code (4 spaces indent)
[links](https://wikipedia.org)

----
## changelog
* 17-Feb-2013 re-design

----
## thanks
* [markdown-js](https://github.com/evilstreak/markdown-js)
