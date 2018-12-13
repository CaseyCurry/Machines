# disable Secure Boot in BIOS

# change terminal font size
sed -i 's/sun16/sun32/' /etc/vconsole.conf
reboot

# wifi
mkfs.vfat -n 'volume' /dev/sda -I
# copy NetworkManager-1.12.0-6.el7.x86_64.rpm onto usb
mkdir ~/usb
mount /dev/sda ~/usb
rpm -ivh ~/usb/NetworkManager-wifi-1.12.0-6.el7.x86_64.rpm
rm -r ~/usb

# update
yum update -y
yum upgrade -y
yum install -y epel-release

# kernel
yum install kernel-devel kernel-headers gcc gcc-c++ make
uname -r
rpm -q kernel-devel
# repeat this and reboot until the versions match
yum -y upgrade kernel kernel-devel

# chrome
bash -c 'printf "[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo'
yum install -y google-chrome-stable
ln -s /usr/bin/google-chrome /usr/local/bin/chrome

# postman
mkdir ~/Downloads
curl -o ~/Downloads/postman.tar.gz https://dl.pstmn.io/download/latest/linux64
tar -xzf ~/Downloads/postman.tar.gz -C /opt
rm -r ~/Downloads
ln -s /opt/Postman/Postman /usr/local/bin/postman

# node
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
yum install -y nodejs

# vscode
bash -c 'printf "[vscode]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
rpm --import https://packages.microsoft.com/keys/microsoft.asc
yum check-update
yum install code

# kafka
yum install java-1.8.0-openjdk
useradd kafka -m
passwd kafka
usermod -aG wheel kafka
su -l kafka
mkdir ~/Downloads
curl http://www-eu.apache.org/dist/kafka/2.1.0/kafka_2.12-2.1.0.tgz -o ~/Downloads/kafka.tgz
mkdir  ~/kafka && cd ~/kafka
tar -xvzf ~/Downloads/kafka.tgz --strip 1
rm -r ~/Downloads
sudo bash -c 'printf "[Unit]
Description=Zookeeper Service
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/zookeeper.service'
sudo bash -c 'printf "[Unit]
Description=Kafka Service
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /home/kafka/kafka/kafka.log 2>&1'
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/kafka.service'
sudo systemctl start kafka
sudo systemctl enable kafka
logout

# mongo
bash -c 'printf "[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" > /etc/yum.repos.d/mongodb-org.repo'
yum install mongodb-org
systemctl start mongod
systemctl enable mongod

# verdaccio
useradd verdaccio -m
passwd verdaccio
usermod -aG wheel verdaccio
npm install --global verdaccio
bash -c 'printf "[Unit]
Description=Verdaccio Service
Requires=network.target
After=network.target

[Service]
Type=simple
User=verdaccio
ExecStart=/usr/bin/verdaccio
ExecStop=/usr/bin/bash -c "kill verdaccio"
Restart=on-abnormal

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/verdaccio.service'
systemctl start verdaccio
systemctl enable verdaccio
npm set registry http://localhost:4873/

# audio
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum install -y alsa-utils

# graphics
bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf'
sed -i 's/quiet/quiet rd.driver.blacklist=nouveau/' /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
# download nvidia driver
init 3
chmod +x ~/Downloads/NVIDIA-Linux-x86_64-410.78run
~/Downloads/NVIDIA-Linux-x86_64-410.78.run
init 5
rm -r ~/Downloads

# i3
yum groupinstall -y "X Window System" "Desktop" "Desktop Platform"
yum install -y dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts
yum install -y i3 dmenu xterm
# sign-in as user
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
sed -i 's/#font pango:DejaVu/font pango:DejaVu/' ~/.i3/config
sed -i '/exec i3-config-wizard/ s/^/#/' ~/.i3/config
sed -i '$aexec xrdb ~/.XResources' ~/.i3/config

# git
mkdir ~/src
curl -L -O -o ~/src/ius-release.rpm https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ~/src/ius-release.rpm
sudo yum install -y git2u
sudo rm -r ~/src
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=14400'

