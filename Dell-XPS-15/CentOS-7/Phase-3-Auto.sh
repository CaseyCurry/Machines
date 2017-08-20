#! /bin/bash

cd ~/source
git clone https://anongit.freedesktop.org/git/xorg/util/macros.git
git clone https://anongit.freedesktop.org/git/xcb/util-renderutil.git
git clone https://anongit.freedesktop.org/git/xcb/util-image.git
git clone https://anongit.freedesktop.org/git/xcb/util-cursor.git
git clone https://anongit.freedesktop.org/git/xcb/proto.git
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
git checkout tags/4.10.4
make
sudo make install

# i3status
sudo yum install -y i3status

# i3 config
sudo yum install -y dejavu-sans-mono-fonts dmenu
printf "xrandr --dpi 220
exec i3" > ~/.xinitrc
printf "Xft.antialias: true
Xft.hinting: true
Xft.rgba: rgb
Xft.dpi: 220

XTerm*faceName: DejaVu Sans Mono
XTerm*faceSize: 8
XTerm.vt100.foreground: white
XTerm.vt100.background: black" > ~/.XResources
mkdir ~/.i3 && touch ~/.i3/config
cat /etc/i3/config | sed 's/Mod1/Mod4/g' > ~/.i3/config
sed -i '/font pango:mono/ s/^/#/' ~/.i3/config
sed -i 's/#font pango:DejaVu/font pango:DejaVu/' /etc/default/grub
sed -i '/exec i3-config-wizard/ s/^/#/' ~/.i3/config
sed -i '$aexec xrdb ~/.XResources' ~/.i3/config

# blacklist nouveau driver
# http://www.dedoimedo.com/computers/centos-7-nvidia.html
# https://www.linkedin.com/pulse/rhel7centos-nvidia-drviers-updated-christopher-meacham
sudo rpm -e xorg-x11-drivers xorg-x11-drv-nouveau
sudo bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf'
sudo sed -i 's/quiet/quiet rd.driver.blacklist=nouveau/' /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# reboot without nouveau drivers
reboot
