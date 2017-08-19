#!/bin/bash

yum update
yum install -y epel-release

# begin i3 install
yum install nano bzip2 gcc git pkgconfig autoconf automake libtool gperf byacc libxslt bison flex
yum groupinstall "X Window System"
yum install libxcb-devel libXcursor-devel pango-devel pcre-devel perl-Data-Dumper perl-Pod-Parser startup-notification-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel yajl-devel check-devel gettext-devel xterm
yum install xorg-x11-xkb-extras xorg-x11-xkb-utils-devel libxkbfile-devel libev-devel
print f "export XORG_CONFIG=/etc/X11/
export PKG_CONFIG_LIBDIR=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/lib64/pkgconfig/
export PKG_CONFIG_PATH=/usr/share/pkgconfig/:/usr/local/share/pkgconfig/
export ACLOCAL_PATH=/usr/local/share/aclocal/
export LD_LIBRARY_PATH=/usr/local/lib/" > /etc/profile.d/pclib.sh

# reboot the machine so kernel and env vars take place.
