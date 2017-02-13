#!/bin/bash

git_commit()
{

echo "Setup failed! Do you want to report this in github? [Y/N]"
LOOP_N=0
while [ $LOOP_N -eq 0 ]; do
read ANSWER
if [ "$ANSWER" = "Y" -o "$ANSWER" = "y" ]; then
LOOP_N=1
echo "Commiting ..."

# Get Current Date
name=$(date '+%y-%m-%d')

# Clone the repository
rm -rf librereports
git clone https://github.com/librerouter/librereports
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

git add report.$name.log
git commit report.$name.log -m "Report $date"
git push origin

elif [ "$ANSWER" = "N" -o "$ANSWER" = "n" ]; then
LOOP_N=1
echo "Exiting ..."
else
LOOP_N=0
echo "Please type \"Y\" or \"N\""
fi
done

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

