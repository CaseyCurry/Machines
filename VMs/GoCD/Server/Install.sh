sudo bash -c 'sed -i "$ aDNS1=8.8.8.8" /etc/sysconfig/network-scripts/iccfg-enp0s3'
sudo bash -c 'sed -i "$ aDNS1=8.8.4.4" /etc/sysconfig/network-scripts/iccfg-enp0s3'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/iccfg-enp0s3'
reboot
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk
sudo bash -c 'printf "[gocd]
name = GoCD
baseurl = https://download.go.cd
enabled = 1
gpgcheck = 1
gpgkey = https://download.go.cd/GOCD-GPG-KEY.asc" > /etc/yum.repos.d/gocd.repo'
sudo yum install -y go-server
sudo firewall-cmd --zone=public --add-port=8153/tcp --permanent
