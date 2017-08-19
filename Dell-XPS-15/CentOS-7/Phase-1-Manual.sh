# bios
# disable RAID
# disable Secure Boot

# change font size
sudo vi /etc/vconsole.conf

# prepare
sudo yum install -y git
mkdir ~/source
cd ~/source
git clone https://github.com/caseycurry/Machines
cd ./Machines/Dell-XPS-15/CentOS-7
chmod u+x Phase-2-Auto.sh
chmod u+x Phase-3-Auto.sh
chmod u+x Phase-4-Auto.sh

# execute phase 2
sudo ~/source/Dell-XPS-15/CentOS-7/Phase-2-Auto.sh

# reboot

# execute phase 3
~/source/Dell-XPS-15/CentOS-7/Phase-3-Auto.sh

# reboot

# install nvidia driver
sudo ~/NVIDIA-Linux-x86_64-384.59.run

# reboot

# execute phase 4
~/source/Dell-XPS-15/CentOS-7/Phase-4-Auto.sh
