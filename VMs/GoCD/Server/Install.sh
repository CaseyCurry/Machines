sudo bash -c 'sed -i "$ aDNS1=8.8.8.8" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "$ aDNS2=8.8.4.4" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'

sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.100" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo service network restart

sudo yum update -y
sudo yum install -y java-1.8.0-openjdk
sudo curl https://download.gocd.org/gocd.repo -o /etc/yum.repos.d/gocd.repo
sudo yum install -y go-server
sudo /etc/init.d/go-server start
sudo firewall-cmd --add-port=8153/tcp --permanent
sudo firewall-cmd --add-port=8154/tcp --permanent
sudo firewall-cmd --reload
