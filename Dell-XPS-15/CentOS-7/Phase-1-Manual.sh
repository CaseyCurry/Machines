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

# execute phase 2
sudo ./Phase-2-Auto.sh

# reboot

# execute phase 3
cd ~/source/Dell-XPS-15/CentOS-7
sudo ./Phase-3-Auto.sh
