# config network
sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.111" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo sed -i "s/plugins=ifcfg-rh/plugins=ifcfg-rh\ndns=none/" /etc/NetworkManager/NetworkManager.conf
sudo bash -c 'printf "nameserver 192.168.56.109
nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf'

sudo systemctl restart network

sudo yum update -y
sudo yum install -y epel-release
sudo yum install -y ntpdate
sudo ntpdate 129.6.15.28
sudo hostnamectl set-hostname nomad-client-two

# install consul
sudo yum install -y unzip
curl -LO https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_amd64.zip
unzip consul_0.9.2_linux_amd64.zip
rm consul_0.9.2_linux_amd64.zip
sudo mv consul /usr/local/bin/consul

sudo firewall-cmd --add-port=8300-8303/tcp --permanent
sudo firewall-cmd --add-port=8400/tcp --permanent
sudo firewall-cmd --add-port=8500/tcp --permanent
sudo firewall-cmd --add-port=20000-60000/tcp --permanent
sudo firewall-cmd --reload

sudo mkdir /etc/consul.d
sudo bash -c 'printf "[Unit]
Description=Consul Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/consul agent -retry-join=server.consul.devlab \\
    -datacenter=dev-lab -data-dir=/tmp/consul -node=consul-client-two -bind=$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)") \\
    -enable-script-checks=true -config-dir=/etc/consul.d
RestartSec=3
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/consul.service'
sudo systemctl enable consul
sudo systemctl start consul

# install nomad
curl -LO https://releases.hashicorp.com/nomad/0.6.2/nomad_0.6.2_linux_amd64.zip
unzip nomad_0.6.2_linux_amd64.zip
sudo yum remove -y unzip
rm nomad_0.6.2_linux_amd64.zip
sudo mv nomad /usr/local/bin/nomad

sudo firewall-cmd --add-port=4646-4647/tcp --permanent
sudo firewall-cmd --reload

sudo mkdir /etc/nomad.d
sudo bash -c 'printf "name = \"nomad-client-two\"
datacenter = \"dev-lab\"
data_dir = \"/etc/nomad.d\"
bind_addr = \"$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)")\"

client {
  network_interface = \"enp0s8\"
  enabled = true
  meta {
    \"rkt\" = \"1\",
    \"grafana\" = \"1\"
  }
  options {
    \"driver.raw_exec.enable\" = \"1\"
  }
}" > /etc/nomad.d/client.hcl'

sudo bash -c 'printf "[Unit]
Description=Nomad Service
After=consul.service

[Service]
Type=simple
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/client.hcl
RestartSec=3
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/nomad.service'
sudo systemctl enable nomad
sudo systemctl start nomad

bash -c 'printf "\\nNOMAD_ADDR=http://$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)"):4646"' >> ~/.bash_profile
bash -c 'printf "\\n\\nexport NOMAD_ADDR"' >> ~/.bash_profile
source ~/.bash_profile

# install rkt
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
sudo setenforce 0
sudo bash -c 'printf "[rkt]
name=rkt
baseurl=http://cbs.centos.org/repos/virt7-rkt-common-candidate/x86_64/os/
enabled=1
gpgcheck=0" > /etc/yum.repos.d/cbs-rkt.repo'
sudo yum install -y rkt
