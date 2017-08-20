#! /bin/bash

# disable nvidia gpu
sudo yum install -y dkms kernel-devel kernel-headers
cd ~/source
git clone https://github.com/Bumblebee-Project/bbswitch
cd ./bbswitch
git tag -l
git checkout tags/v0.8
sudo make -f Makefile.dkms
sudo modprobe bbswitch
sudo bash -c 'echo "bbswitch" > /etc/modules-load.d/bbswitch.conf'
sudo bash -c 'echo "options bbswitch load_state=0" > /etc/modprobe.d/bbswitch.conf'

# cleanup
sudo rm -rf ~/source
