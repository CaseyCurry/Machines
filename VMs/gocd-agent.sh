# config network
sudo bash -c 'sed -i "$ aDNS1=8.8.8.8" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "$ aDNS2=8.8.4.4" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'

sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.101" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo service network restart

# install go-agent-1
sudo yum update -y
sudo hostnamectl set-hostname gocd-agent-1
sudo yum install -y epel-release
sudo yum install -y java-1.8.0-openjdk
sudo curl https://download.gocd.org/gocd.repo -o /etc/yum.repos.d/gocd.repo
sudo yum install -y go-agent
sudo bash -c 'sed -i "s/127.0.0.1/192.168.56.100/" /etc/default/go-agent'
sudo /etc/init.d/go-agent start

sudo mkdir /var/go
sudo chown -R go:go /var/go
sudo chmod -R 740 /var/go

# install go-agent-2
sudo cp /etc/init.d/go-agent /etc/init.d/go-agent-2
sudo sed -i 's/# Provides: go-agent$/# Provides: go-agent-2/g' /etc/init.d/go-agent-2
sudo ln -s /usr/share/go-agent /usr/share/go-agent-2
sudo cp -p /etc/default/go-agent /etc/default/go-agent-2
sudo mkdir /var/{lib,log}/go-agent-2
sudo chown go:go /var/{lib,log}/go-agent-2
sudo chkconfig go-agent-2 on
sudo /etc/init.d/go-agent-2 start

# install go-agent-3
sudo cp /etc/init.d/go-agent /etc/init.d/go-agent-3
sudo sed -i 's/# Provides: go-agent$/# Provides: go-agent-3/g' /etc/init.d/go-agent-3
sudo ln -s /usr/share/go-agent /usr/share/go-agent-3
sudo cp -p /etc/default/go-agent /etc/default/go-agent-3
sudo mkdir /var/{lib,log}/go-agent-3
sudo chown go:go /var/{lib,log}/go-agent-3
sudo chkconfig go-agent-3 on
sudo /etc/init.d/go-agent-3 start

# install go-agent-4
sudo cp /etc/init.d/go-agent /etc/init.d/go-agent-4
sudo sed -i 's/# Provides: go-agent$/# Provides: go-agent-4/g' /etc/init.d/go-agent-4
sudo ln -s /usr/share/go-agent /usr/share/go-agent-4
sudo cp -p /etc/default/go-agent /etc/default/go-agent-4
sudo mkdir /var/{lib,log}/go-agent-4
sudo chown go:go /var/{lib,log}/go-agent-4
sudo chkconfig go-agent-4 on
sudo /etc/init.d/go-agent-4 start

# install go-agent-5
sudo cp /etc/init.d/go-agent /etc/init.d/go-agent-5
sudo sed -i 's/# Provides: go-agent$/# Provides: go-agent-5/g' /etc/init.d/go-agent-5
sudo ln -s /usr/share/go-agent /usr/share/go-agent-5
sudo cp -p /etc/default/go-agent /etc/default/go-agent-5
sudo mkdir /var/{lib,log}/go-agent-5
sudo chown go:go /var/{lib,log}/go-agent-5
sudo chkconfig go-agent-5 on
sudo /etc/init.d/go-agent-5 start

# create public key
sudo passwd -uf go
su - go
ssh-keygen -t rsa -P ''
ssh-copy-id cj@192.168.56.110

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

# acbuild
cd /tmp
curl -O https://raw.githubusercontent.com/CaseyCurry/LucaOpsEnvironment/master/dependencies/rkt/latest/acbuild-v0.4.0.tar.gz
tar xf ./acbuild-v0.4.0.tar.gz
sudo cp ./acbuild-v0.4.0/* /usr/local/bin/
