#! /bin/bash

rm ./NVIDIA-Linux-x86_64-384.59.run

#bumblebee
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum install -y bumblebee
sudo yum install -y mesa-libOSMesa
sudo yum install -y xorg-x11-drv-intel
sudo printf "[Unit]
Description=Bumblebee Daemon

[Service]
Type=simple
CPUSchedulingPolicy=idle
ExecStart=/usr/sbin/bumblebeed
Restart=always
RestartSec=60
StandardOutput=kmsg

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/bumblebeed.service
sudo systemctl enable --now bumblebeed

sudo rm /etc/bumblebee/bumblebee.conf
sudo printf "[bumblebeed]
VirtualDisplay=:8
KeepUnusedXServer=false
ServerGroup=bumblebee
TurnCardOffAtExit=false
NoEcoModeOverride=false
Driver=nvidia
XorgConfDir=/etc/bumblebee/xorg.conf.d

[optirun]
Bridge=auto
VGLTransport=proxy
PrimusLibraryPath=/usr/lib/primus:/usr/lib32/primus
AllowFallbackToIGC=false

[driver-nvidia]
KernelDriver=nvidia
PMMethod=bbswitch
LibraryPath=/usr/lib64/nvidia:/usr/lib64/vdpau:/usr/lib/nvidia:/usr/lib/vdpau
XorgModulePath=/usr/lib64/xorg/modules/extensions/nvidia,/usr/lib64/xorg/modules/drivers,/usr/lib64/xorg/modules
XorgConfFile=/etc/bumblebee/xorg.conf.nvidia" > /etc/bumblebee/bumblebee.conf

# usermod -a -G audio cj
# usermod -a -G video cj
sudo usermod -a -G bumblebee cj



sudo rm -rf ~/source
