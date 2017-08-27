# config network
sudo bash -c 'sed -i "$ aDNS1=8.8.8.8" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "$ aDNS2=8.8.4.4" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'

sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.101" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo service network restart

# install agent
sudo yum update -y
sudo hostnamectl set-hostname gocd-agent-1
sudo yum install -y epel-release
sudo yum install -y java-1.8.0-openjdk
sudo curl https://download.gocd.org/gocd.repo -o /etc/yum.repos.d/gocd.repo
sudo yum install -y go-agent
sudo bash -c 'sed -i "s/127.0.0.1/192.168.56.100/" /etc/default/go-agent'
sudo bash -c 'sed -i "s//var/lib/${SERVICE_NAME:-go-agent}//home/go/" /etc/default/go-agent'
sudo /etc/init.d/go-agent start
sudo mkdir /home/go
sudo chown -R go /home/go
sudo chmod -R u+rX /home/go
sudo mkdir /var/go
sudo chown -R go /var/go
sudo chmod -R u+rX /var/go

# install git
curl -L -O https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh ius-release.rpm
sudo yum install -y git2u
rm ius-release.rpm

# install node
curl -sL https://rpm.nodesource.com/setup_6.x | sudo bash -
sudo yum install -y nodejs
npm set registry http://192.168.56.103:4873
npm adduser
