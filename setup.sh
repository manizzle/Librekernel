#!/bin/bash

git_commit()
{

echo "Setup failed! We are going to report this in github. Press Crtl+C to exit."
sleep 5

echo "Commiting ..."

# Get Current Date
name=$(date '+%y-%m-%d_%H-%M')

# Clone the repository
rm -rf librereports
export GIT_SSL_NO_VERIFY=1
git clone https://github.com/nikdavnik/librereports
cd librereports

# Run scripts and get logs
echo "********************* SETUP LOG *******************************" > "report.$name.log"
cat /var/libre_setup.log >> "report.$name.log"

echo "********************* INSTALLATION LOG ************************" >> "report.$name.log"
cat /var/libre_install.log >> "report.$name.log"

echo "********************* PACKAGES INSTALLATION  *******************" >> "report.$name.log"
cat /var/apt-get-update.log >> "report.$name.log"
cat /var/apt-get-update-default.log >> "report.$name.log"
cat /var/apt-get-install-aptth.log >> "report.$name.log"
cat /var/apt-get-install_1.log >> "report.$name.log"
cat /var/apt-get-install_2.log >> "report.$name.log"

echo "********************* CONFIGURATION LOG ************************" >> "report.$name.log"
cat /var/libre_config.log >> "report.$name.log"

echo "********************* SYSTEM INFORMATION ************************" >> "report.$name.log"
uname -a >> "report.$name.log"
cat /proc/cpuinfo | grep model >> "report.$name.log"
ifconfig >> "report.$name.log"

# Git global configs
git config --global user.email "nikdavnik@mail.ru"
git config --global user.name "libreroot"

git add report.$name.log
git commit report.$name.log -m "Report $date"
git push --repo https://libreroot:Librepass1@github.com/nikdavnik/librereports.git

}


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

# Checking status
if [ $? -ne 0 ]; then
        echo "Erron in installtaion script. Exiting ..." | tee /var/libre_setup.log
        git_commit
        exit 1
fi


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

# Checking status
if [ $? -ne 0 ]; then
        echo "Erron in configuration script. Exiting ..." | tee /var/libre_setup.log
        git_commit
        exit 1
fi

