# config network
sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.102" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
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
sudo hostnamectl set-hostname elasticsearch-server

# install elasticsearch
sudo yum install -y java-1.8.0-openjdk
curl -LO https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.0.rpm
sha1sum elasticsearch-5.6.0.rpm
sudo rpm --install elasticsearch-5.6.0.rpm
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
sudo firewall-cmd --add-port=9200/tcp --permanent
sudo firewall-cmd --reload

# install logstash
curl -LO https://artifacts.elastic.co/downloads/logstash/logstash-5.6.0.rpm
sha1sum logstash-5.6.0.rpm
sudo rpm --install logstash-5.6.0.rpm
sudo systemctl enable logstash
sudo systemctl start logstash

# config logstash to use filebeats
sudo bash -c 'printf "input {
  beats {
    port => 5044
  }
}

filter {
  mutate {
    convert =&gt; [\"response\", \"integer\"]
    convert =&gt; [\"bytes\", \"integer\"]
    convert =&gt; [\"responsetime\", \"float\"]
  }
}

output {
  if [@metadata][beat] {
    elasticsearch {
      hosts => \"localhost:9200\"
      manage_template => false
      index => \"%%{[@metadata][beat]}-%%{+YYYY.MM.dd}\"
      document_type => \"%%{[@metadata][type]}\"
    }
  }
}" > /etc/logstash/conf.d/filebeats.conf'
sudo firewall-cmd --add-port=5044/tcp --permanent
sudo firewall-cmd --reload
