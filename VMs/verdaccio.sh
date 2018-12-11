# config network
sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.103" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo sed -i "s/plugins=ifcfg-rh/plugins=ifcfg-rh\ndns=none/" /etc/NetworkManager/NetworkManager.conf
sudo bash -c 'printf "nameserver 192.168.56.109
nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf'

sudo service network restart

sudo yum update -y
sudo yum install -y epel-release
sudo yum install -y ntpdate
sudo ntpdate 129.6.15.28
sudo hostnamectl set-hostname verdaccio-server

# install node
curl -sL https://rpm.nodesource.com/setup_6.x | sudo bash -
sudo yum install -y nodejs

# install verdaccio
sudo npm install --global verdaccio
sudo bash -c 'printf "[Unit]
Description=verdaccio Service

[Service]
Type=simple
User=verdaccio
WorkingDirectory=/home/verdaccio
ExecStart=/usr/bin/verdaccio
ExecStop=/usr/bin/bash -c "kill verdaccio"

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/verdaccio.service'

sudo bash -c 'sed -i "$ alisten:" ~/verdaccio/config.yaml'
sudo bash -c 'sed -i "$ a  - 0.0.0.0:4873" ~/verdaccio/config.yaml'

sudo systemctl enable verdaccio
sudo systemctl start verdaccio
sudo firewall-cmd --add-port=4873/tcp --permanent
sudo firewall-cmd --reload
