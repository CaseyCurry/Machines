# bios
# disable RAID
# disable Secure Boot
# disable USB security

# prepare
sudo yum install -y git
mkdir ~/source
cd ~/source
git clone https://github.com/caseycurry/Machines
cd ./Machines/Dell-XPS-15/CentOS-7
chmod u+x Phase-2-Auto.sh

# execute phases
~/source/Dell-XPS-15/CentOS-7/Phase-2-Auto.sh
~/source/Dell-XPS-15/CentOS-7/Phase-3-Auto.sh
~/source/Dell-XPS-15/CentOS-7/Phase-4-Auto.sh
~/source/Dell-XPS-15/CentOS-7/Phase-5-Auto.sh
