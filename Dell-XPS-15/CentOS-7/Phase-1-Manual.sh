# bios
# disable RAID
# disable Secure Boot

# change font size
vi /etc/vconsole.conf

# prepare
yum install git
mkdir ~/source
cd ~/source
git clone https://github.com/caseycurry/Machines
cd ./Dell-XPS-15/CentOS-7
chmod u+x Phase-2-Auto.sh

# execute phase 2
./Phase-2-Auto.sh

# reboot

# execute phase 3
cd ~/source/Dell-XPS-15/CentOS-7
chmod u+x Phase-3-Auto.sh
./Phase-3-Auto.sh
