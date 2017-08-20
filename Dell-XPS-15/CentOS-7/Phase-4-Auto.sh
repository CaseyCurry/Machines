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

# install chrome
sudo bash -c 'printf "[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo'
sudo yum install -y google-chrome-stable
sudo ln -s /usr/bin/google-chrome-stable /usr/local/bin/chrome

# install audio
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum install -y alsa-utils

# link missing ath10k firmware
sudo ln -s /lib/firmware/ath10k/QCA6174/hw3.0/firmware-4.bin /lib/firmware/ath10k/QCA6174/hw3.0/firmware-5.bin

# cleanup
sudo rm -rf ~/source

# reboot without gpu
reboot
