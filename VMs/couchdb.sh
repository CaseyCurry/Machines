# config network
sudo bash -c 'sed -i "$ aDNS1=8.8.8.8" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "$ aDNS2=8.8.4.4" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'

sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.100" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo service network restart

# install couchdb
sudo yum update -y
sudo yum install -y epel-release
sudo bash -c 'printf "[couchdb]
name=bintray--apache-couchdb-rpm
baseurl=http://apache.bintray.com/couchdb-rpm/el$releasever/$basearch/
enabled=1
gpgcheck=0
repo_gpgcheck=0" > /etc/yum.repos.d/couchdb.repo'
sudo yum install -y couchdb
sudo bash -c 'sed -i "0,/127.0.0.1/{s/127.0.0.1/0.0.0.0/}"'
sudo firewall-cmd --add-port=5984/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl enable couchdb
sudo systemctl start couchdb
# http://docs.couchdb.org/en/2.1.0/install/setup.html#install-setup
