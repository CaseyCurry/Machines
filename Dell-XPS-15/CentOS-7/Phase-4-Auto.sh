#!/bin/bash

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

# install atom
cd ~/source
curl -L -O https://github.com/atom/atom/releases/download/v1.19.1/atom.x86_64.rpm
sudo yum localinstall -y atom.x86_64.rpm
sudo yum install -y gvfs

# install packages
# apm install --packages-file ~/source/Machines/atom-packages
# apm upgrade --confirm false

# config git
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=14400'

# install virtualbox
sudo curl -L -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
sudo yum install -y binutils qt gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
sudo yum install -y VirtualBox-5.1
sudo /usr/lib/virtualbox/vboxdrv.sh setup
sudo usermod -a -G vboxusers cj

# download CentOS 7 Min
mkdir ~/images
cd ~/images
curl -L -O http://centos.mirror.constant.com/7/isos/x86_64/CentOS-7-x86_64-Minimal-1611.iso

# install node
curl -sL https://rpm.nodesource.com/setup_6.x | sudo bash -
sudo yum install -y nodejs

# config git
git config --global user.name "CaseyCurry"
git config --global user.email "casey.de.curry@gmail.com"

# cleanup
sudo rm -rf ~/source

# reboot without gpu
reboot
