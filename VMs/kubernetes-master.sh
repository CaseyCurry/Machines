# config network
sudo bash -c 'sed -i "$ aDNS1=8.8.8.8" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "$ aDNS2=8.8.4.4" /etc/sysconfig/network-scripts/ifcfg-enp0s3'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s3'

sudo bash -c 'sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "s/ONBOOT=no/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aIPADDR=192.168.56.105" /etc/sysconfig/network-scripts/ifcfg-enp0s8'
sudo bash -c 'sed -i "$ aNETMASK=255.255.255.0" /etc/sysconfig/network-scripts/ifcfg-enp0s8'

sudo service network restart

# install master
sudo yum update -y
sudo yum install -y epel-release

sudo bash -c 'printf "[kubernetes]
name=kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo=gpgcheck
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" > /etc/yum.repos.d/kubernetes.repo'

sudo bash -c 'printf "[virt7-rkt-common-candidate]
name=virt7-rkt-common-candidate
baseurl=http://cbs.centos.org/repos/virt7-rkt-common-candidate/x86_64/os/
enabled=1
gpgcheck=0" > /etc/yum.repos.d/virt7-rkt-common-candidate.repo'

sudo bash -c 'sed -i "'s/SELINUX=enforcing/SELINUX=permissive'" > /etc/selinux/config'
sudo setenforce Permissive

sudo yum install -y rkt etcd flannel
sudo yum install -y kubelet kubectl kubeadm kubernetes-cni

sudo bash -c 'printf "KUBE_ETCD_SERVERS=/"--etcd-servers=http://192.168.56.106:2379/"
KUBE_LOGTOSTDERR=/"--logtostderr=true/"
KUBE_LOG_LEVEL=/"--v=0/"
KUBE_ALLOW_PRIV=/"--allow-privileged=false/"
KUBE_MASTER=/"--master=http://192.168.56.105:8080/"" > /etc/kubernetes/config'
sudo bash -c 'sed "s/localhost:2379/0.0.0.0:2379/g" > /etc/etcd/etcd.conf'
#curl -LO https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/saltbase/salt/generate-cert/make-ca-cert.sh

sudo bash -c 'printf "KUBE_API_ADDRESS=/"--bind-address=0.0.0.0/"
KUBE_API_PORT=/"--port=8080/"
KUBELET_PORT=/"--kubelet_port=10250/"
KUBE_ETCD_SERVERS=/"--etcd_servers=http://127.0.0.1:2379/"
KUBE_SERVICE_ADDRESSES=/"--portal_net=10.254.0.0/16/"
KUBE_ADMISSION_CONTROL=/"--admission_control=NamespaceAutoProvision,LimitRanger,ResourceQuota/"
KUBE_API_ARGS=/"/"" > /etc/kubernetes/apiserver'

sudo bash -c 'printf "KUBELET_ADDRESSES=/"--machines=192.168.56.106/"
KUBE_CONTROLLER_MANAGER_ARGS=/"/"" > /etc/kubernetes/controller-manager'

sudo bash -c 'sed "s/atomic.io/kube-centos/" > /etc/sysconfig/flanneld'

sudo systemctl enable etcd
sudo systemctl restart etcd

sudo etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config "{ \"Network\": \"192.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

sudo systemctl enable flanneld
sudo systemctl restart flanneld
