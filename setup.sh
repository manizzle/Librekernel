#!/bin/bash
do_report() {


#write known activated key priv and pub ssh keys

mkdir /root/librereport
mkdir /root/librereport/reports
cd /root/librereport
git init
echo "192.30.253.112  github.com" >> /etc/hosts
 

git config --global user.email "kinko@interec.og"
git config --global user.name "Reporter"

#Collects some system info
mkdir /tmp2
dmidecode > /tmp2/dmi.log
ps auxwww  > /tmp2/ps.log
free            > /tmp2/free.log
lsusb          > /tmp2/usb.log
lspci           > /tmp2/usb.log
cat /proc/version > /tmp2/version.log


cp /var/libre_setup.log /tmp2/.
cp /var/libre_install.log /tmp2/.
cp /var/libre_config.log /tmp2/.

# Update the new.tar.gz file to github
timestamp=$(date '+%y-%m-%d_%H-%M')
file="report"

git remote add origin https://librereport:Librereport2017@github.com/librereport/reports.git
git remote set-url origin https://librereport:Librereport2017@github.com/librereport/reports.git

mv /tmp2 /root/librereport/reports/report.$timestamp
git add /root/librereport/reports/report.$timestamp
git --no-replace-objects commit -m "New report $timestamp"
git --no-replace-objects push origin master --force

}






do_installation() {

# -----------------------------------------------
# Installation part
# -----------------------------------------------   

echo "Downloading installation script ..." | tee /var/libre_setup.log
wget --no-check-certificate https://raw.githubusercontent.com/Librerouter/Librekernel/gh-pages/app-installation-script.sh
if [ $? -ne 0 ]; then
        echo "Unable to download installtaion script. Exiting ..." | tee /var/libre_setup.log 
        git_commit
        exit 1
fi
echo "Running installation scirpt" | tee /var/libre_setup.log
chmod +x app-installation-script.sh
./app-installation-script.sh

}

do_configuration() {

# -----------------------------------------------
# Configuration part
# -----------------------------------------------   

echo "Downloading configuration script ..." | tee /var/libre_setup.log
wget --no-check-certificate https://raw.githubusercontent.com/Librerouter/Librekernel/gh-pages/app-configuration-script.sh
if [ $? -ne 0 ]; then
        echo "Unable to download configuration script. Exiting ..." | tee /var/libre_setup.log
        git_commit
        exit 1
fi
echo "Running configuraiton script" | tee /var/libre_setup.log
chmod +x app-configuration-script.sh
./app-configuration-script.sh

}


# Main
do_installation
do_configuration
do_report
