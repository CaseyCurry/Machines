#!/bin/bash

sudo yum update -y
sudo yum install -y epel-release

# prepare
sudo yum install -y git
mkdir ~/source
cd ~/source
git clone https://github.com/caseycurry/Machines
cd ./Machines/Dell-XPS-15/CentOS-7
chmod u+x Phase-2-Auto.sh
chmod u+x Phase-3-Auto.sh
chmod u+x Phase-4-Auto.sh

# begin i3 install
sudo yum install -y bzip2 gcc git pkgconfig autoconf automake libtool gperf byacc libxslt bison flex
sudo yum groupinstall -y "X Window System"
sudo yum install -y libxcb-devel libXcursor-devel pango-devel pcre-devel perl-Data-Dumper perl-Pod-Parser startup-notification-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel yajl-devel check-devel gettext-devel xterm
sudo yum install -y xorg-x11-xkb-extras xorg-x11-xkb-utils-devel libxkbfile-devel libev-devel
sudo bash -c 'printf "export XORG_CONFIG=/etc/X11/
export PKG_CONFIG_LIBDIR=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/lib64/pkgconfig/
export PKG_CONFIG_PATH=/usr/share/pkgconfig/:/usr/local/share/pkgconfig/
export ACLOCAL_PATH=/usr/local/share/aclocal/
export LD_LIBRARY_PATH=/usr/local/lib/" > /etc/profile.d/pclib.sh'

# reboot the machine so kernel and env vars take place.
reboot
