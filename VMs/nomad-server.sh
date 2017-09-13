# config network
sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.110" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo sed -i "s/plugins=ifcfg-rh/plugins=ifcfg-rh\ndns=none/" /etc/NetworkManager/NetworkManager.conf
sudo bash -c 'printf "nameserver 192.168.56.109
nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf'

sudo systemctl restart network

sudo yum update -y
sudo yum install -y epel-release

# install consul
sudo yum install -y unzip
curl -LO https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_amd64.zip
unzip consul_0.9.2_linux_amd64.zip
rm consul_0.9.2_linux_amd64.zip
sudo mv consul /usr/local/bin/consul

sudo firewall-cmd --add-port=8300-8303/tcp --permanent
sudo firewall-cmd --add-port=8500/tcp --permanent
sudo firewall-cmd --add-port=8600/tcp --permanent
sudo firewall-cmd --add-port=8600/udp --permanent
sudo firewall-cmd --add-port=20000-60000/tcp --permanent
sudo firewall-cmd --reload

sudo mkdir /etc/consul.d
sudo bash -c 'printf "[Unit]
Description=Consul Service

[Service]
Type=simple
ExecStart=/usr/local/bin/consul agent -server -ui -bootstrap-expect=1 \\
    -client=0.0.0.0 -data-dir=/tmp/consul -node=consul-server -bind=$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)") \\
    -enable-script-checks=true -datacenter=dev-lab -config-dir=/etc/consul.d \\
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

sudo firewall-cmd --add-port=4646-4648/tcp --permanent
sudo firewall-cmd --add-port=4648/udp --permanent
sudo firewall-cmd --reload

sudo mkdir /etc/nomad.d
sudo bash -c 'printf "name = \"nomad-server\"
datacenter=\"dev-lab\"
data_dir = \"/etc/nomad.d\"
bind_addr = \"$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)")\"

server {
  enabled = true
  bootstrap_expect = 1
}" > /etc/nomad.d/server.hcl'
sudo bash -c 'printf "[Unit]
Description=Nomad Service
After=consul.service

[Service]
Type=simple
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/server.hcl
RestartSec=3
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/nomad.service'
sudo systemctl enable nomad
sudo systemctl start nomad

bash -c 'printf "\\nNOMAD_ADDR=http://$(ip -4 addr show enp0s8 | grep -oP "(?<=inet ).*(?=/)"):4646"' >> ~/.bash_profile
bash -c 'printf "\\n\\nexport NOMAD_ADDR' >> ~/.bash_profile
source ~/.bash_profile

# install consul-template
cd /tmp
curl -LO https://releases.hashicorp.com/consul-template/0.19.2/consul-template_0.19.2_linux_amd64.tgz
tar -xzf consul-template_0.19.2_linux_amd64.tgz
sudo mv consul-template /usr/local/bin/consul-template
sudo ln /usr/local/bin/consul-template /usr/bin/consul-template

# install nginx
sudo bash -c 'printf "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo'
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo firewall-cmd --add-service=http --permamnent
sudo firewall-cmd --add-service=https --permamnent
sudo firewall-cmd --reload
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
sudo setenforce 0

# configure nginx
sudo mkdir /www && sudo mkdir /www/containers
sudo chown -R cj:nginx /www
sudo chmod -R 754 /www
sudo bash -c 'printf "{{ range services }}{{ if or (.Tags | contains \"luca\") (.Tags | contains \"dependency\") }}
upstream {{ .Name }} { {{ range service .Name }}
  server {{ .Address }}:{{ .Port }};{{ end }}
}
{{ end }}{{ end }}
server {
  listen *:80 default_server;

  location ~ \.aci {
    root /www/containers;
  }
  {{ range services }}{{ if .Tags | contains \"dependency\" }}
  location ^~ /{{ .Name }}/ {
    proxy_pass http://{{ .Name }}/;
    proxy_set_header X-NginX-Proxy true;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
  {{ end }}{{ end }}
  {{ range services }}{{ if .Tags | contains \"app\" }}
  location / {
    proxy_pass http://{{ .Name }};
    proxy_set_header X-NginX-Proxy true;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
  {{ end }}{{ end }}
  {{ range services }}{{ if .Tags | contains \"luca\" }}
  location ^~ /{{ index (.Name | split \"-\") 1 }}/{{ index (.Name | split \"-\") 0 }}/ {
    proxy_pass http://{{ .Name }}{{ if .Tags | contains \"client\" }}/{{ end }};
    proxy_set_header X-NginX-Proxy true;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
  {{ end }}{{ end }}
  error_page 404 /404.html;

  error_page 500 502 503 504 /50x.html;

  location = /50x.html {
    root /usr/share/nginx/html;
  }
}" > /etc/nginx/conf.d/default.ctmpl'
sudo bash -c 'printf "[Unit]
Description=Consul-Template for Nginx Configuration
After=consul.service

[Service]
Type=simple
ExecStart=/usr/bin/consul-template -template \"/etc/nginx/conf.d/default.ctmpl:/etc/nginx/conf.d/default.conf:nginx -s reload\"
RestartSec=5
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/consul-template.service'
sudo systemctl enable consul-template
sudo systemctl start consul-template

# fix permissions on home directory to allow ssh with public key
chmod g-w /home/cj
chmod 700 /home/cj/.ssh
chmod 600 /home/cj/.ssh/authorized_keys
