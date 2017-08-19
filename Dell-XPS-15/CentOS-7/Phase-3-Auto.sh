#! /bin/bash

cd ~/source
git clone https://anongit.freedesktop.org/git/xorg/util/macros.git
git clone https://anongit.freedesktop.org/git/xcb/util-renderutil.git
git clone https://anongit.freedesktop.org/git/xcb/util-image.git
git clone https://anongit.freedesktop.org/git/xcb/util-cursor.git
git clone https://anongit.freedesktop.org/git/xcb/proto.git
git clone https://anongit.freedesktop.org/git/xcb/libxcb.git
git clone https://github.com/xkbcommon/libxkbcommon.git
git clone http://git.savannah.gnu.org/r/confuse.git
git clone https://github.com/i3/i3.git

# macros
cd ~/source/macros
git tag -l
git checkout tags/util-macros-1.19.0
./autogen.sh
make
sudo make install

# util-render
cd ~/source/util-renderutil
git submodule update --init
git tag -l
git checkout tags/0.3.9
./autogen.sh
make
sudo make install

# util-image
cd ~/source/util-image
git submodule update --init
git tag -l
git checkout tags/0.4.0
./autogen.sh
make
sudo make install

# util-cursor
cd ~/source/util-cursor
git submodule update --init
git tag -l
git checkout tags/0.1.2
./autogen.sh
make
sudo make install

# proto
cd ~/source/proto
git tag -l
git checkout tags/1.11
./autogen.sh
make
sudo make install

# libxcb
cd ~/source/libxcb
git tag -l
git checkout tags/1.11
./autogen.sh
make
sudo make install

# xkbcommon
cd ~/source/libxkbcommon
git tag -l
git checkout tags/xkbcommon-0.5.0
./autogen.sh
make
sudo make install

# confuse
cd ~/source/confuse
git tag -l
git checkout tags/V2_7
./autogen.sh
make
sudo make install

# i3
cd ~/source/i3
git tag -l
git checkout tags/4.10.2
make
sudo make install

# i3status
sudo yum install -y i3status

# i3 config
echo "exec i3" > ~/.xinitrc
mkdir ~/.i3 && touch ~/.i3/config
cat /etc/i3/config | sed 's/Mod1/mod/g' > ~/.i3/config
sed -i '/exec i3-config-wizard/ s/^/#/' ~/.i3/config
sed -i '1s/^/set $mod Mod4\n\n/' ~/.i3/config

# blacklist nouveau driver
# http://www.dedoimedo.com/computers/centos-7-nvidia.html
# https://www.linkedin.com/pulse/rhel7centos-nvidia-drviers-updated-christopher-meacham
sudo rpm -e xorg-x11-drivers xorg-x11-drv-nouveau
sudo bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf'
sudo sed -i 's/quiet/quiet rd.driver.blacklist=nouveau/' /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg


# download nvidia driver
sudo yum install -y kernel-devel kernel-headers gcc make
cd ~
curl -O http://us.download.nvidia.com/XFree86/Linux-x86_64/384.59/NVIDIA-Linux-x86_64-384.59.run
chmod +x NVIDIA-Linux-x86_64-384.59.run

# reboot with nouveau drivers
