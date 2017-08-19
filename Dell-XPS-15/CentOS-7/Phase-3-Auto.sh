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

# Macros
cd ~/source/macros
git tag -l
git checkout tags/util-macros-1.19.0
./autogen.sh
make
sudo make install

#util-render
cd ~/source/util-renderutil
git submodule update --init
git tag -l
git checkout tags/0.3.9
./autogen.sh
make
sudo make install

#util-image
cd ~/source/util-image
git submodule update --init
git tag -l
git checkout tags/0.4.0
./autogen.sh
make
sudo make install

#util-cursor
cd ~/source/util-cursor
git submodule update --init
git tag -l
git checkout tags/0.1.2
./autogen.sh
make
sudo make install

#proto
cd ~/source/proto
git tag -l
git checkout tags/1.11
./autogen.sh
make
sudo make install

#libxcb
cd ~/source/libxcb
git tag -l
git checkout tags/1.11
./autogen.sh
make
sudo make install

#xkbcommon
cd ~/source/libxkbcommon
git tag -l
git checkout tags/xkbcommon-0.5.0
./autogen.sh
make
sudo make install

#confuse
cd ~/source/confuse
git tag -l
git checkout tags/V2_7
./autogen.sh
make
sudo make install

#i3
cd ~/source/i3
git tag -l
git checkout tags/4.10.2
make
sudo make install

#i3status
cd ~/source
sudo yum install pulseaudio-libs-devel alsa-lib-devel asciidoc libnl3-devel
git clone https://github.com/i3/i3status.git
curl -GL -O http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.29.tar.gz
tar xvf wireless_tools.29.tar.gz
cd wireless_tools.29
make
sudo make install

cd ~/source/i3status/
make
sudo make install
echo "exec i3" > ~/.xinitrc

#nvidia driver

#bumblebee

#i3

usermod -a -G audio cj
usermod -a -G video cj
usermod -a -G bumblebee cj
