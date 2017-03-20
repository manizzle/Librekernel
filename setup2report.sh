#!/bin/bash
do_report() {

git init
echo "192.30.253.112  github.com" >> /etc/hosts


#write known activated key priv and pub ssh keys

mkdir /root/librereport
mkdir /root/librereport/reports
 
echo "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAxwMD4WceAgx3iySnPmFmF0O4cSwgwU3u+T/oxk8CE/XkXejl
eBafOFpOnDJluf0kBrnzfPxadCDsPUdv4XUGrxHBQuIgVzU4TRoWf+RY551xnVDM
mB+S538FVBrfEDJn2Nfb8iQ4Py+qBDZMdja6j4Ppdi7ggsOZFD9lrbm53fqjj6+g
aigwB2e4N7fSDm8OXvqoI8jsTj0PKCXryJGs4buievi8BmQ6rJ3JGkeZi9y0XQWi
LYjKiFWQSCkkVgKsUJMN8H3kY4gXyqTcsnrzL9CywODhI9HTh0WgVEWiGnibty9D
F1BwsmwpbXTO5E7TtRNwhV+OYRFsyjJlEGV5rwIDAQABAoIBAAyqcXXIBU3mEzmk
1IwQ0NmMMtHpGBCVcC8m1R7B6oTwsl8Tsn8JGYsRnE0um/DRXpia/xcmTG91pPNl
d4Zm100PGTizgZFrTrEBhwsOsmXTTGbRvKO15ribCfDHYQj73EYdvt7TVU0YMH7i
Ic2oQAlgQNyHsTxBTJ3QRx1eY6jv7PqF1BQsUVTl5OlvNv4SslIMjwbDzSOKpP/E
49PGFG4ycazJyg247YVC3acY/kvM25MakT3SF9thoykBVllRA1Jt15nTBF89wjQ9
PnsjFu8bh+rq9un+zoIjifWKZXmqEsCz6DltgaTOShCMKlO8wBcF8WXREabdbH1O
RInD+aECgYEA5g2VwiL2krvu+zFaDkScOMwn4A4EKBSKZO3BuFP2iEOzGs3Mh48e
jQu7WAf6CNMgOb8XMG0LfS7UcUfgKmlExoSW1Z0BGpc423e1fSSTajmD6177x9az
QQ6kLShKGROaMNkyOsBmm21G3j18hezW0s9voD7hul11tEY+hRiRNZECgYEA3XUp
muMQn9v/p6VSoSeQZq6yED5ZTYC5MvLlHaBPwrSQ6mqcx07D2kx39ZW7KLOh8QOP
x/YsTi4FC+9gRwjUceQ3/6KQO4MkH0sNKGpFb6m8PIWfgjIR1hxw1X3WJ/zE+2v4
7MLUSSEPg1tJjgVVxCYFf6ROmeUZhSkCD/ZTGz8CgYEAh4VzNmVAWhpp4wIkqgkS
+oaR6vR20GGhUWmaWArmTUmMZfrcRPMzrSU/HNG+Ipq0/i+q6nUicoE21vDfhjxz
LnsHHBmcf9ybuvXfLTRxvv7YzrwqmIPLH0UPxCZa2EDq8WHRrDiReXg7akpQY9is
iI14la7VbOMHpsZGqENbr3ECgYAOcvqH9JC9HWmM0qiVgzNUv8k2bhr9h4yN2nNA
f5k0pvtdkB8ykd0NfTfGekJ/4ViLlSPodBNn9nC12qR5fgX+eFl/AGhQubm9oPP2
0xg8tOJnQICrygCH68sg4tj6Ou/PR7gyGnQnYVTVyTr/XTG/Xou1TE8kk2Ia4hYU
XIoHmQKBgAXd4jtNP+BZzJzh2/3m92h8H57Lamc32hKwZx4ssPM292DvAswomty4
iftcAyKtwK4haVr+JRScTFxVJF+7+Ivp6dkoOUvD/Yqizh+t0pmXtQEd/vuMe3oO
Nj8Asv3K/AaBFa/Puax815J0gmZUwnzIOvVVcJVJ7fSy/BuxyiAd
-----END RSA PRIVATE KEY-----
" > /root/librereport/ssh_key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHAwPhZx4CDHeLJKc+YWYXQ7hxLCDBTe75P+jGTwIT9eRd6OV4Fp84Wk6cMmW5/SQGufN8/Fp0IOw9R2/hdQavEcFC4iBXNThNGhZ/5FjnnXGdUMyYH5LnfwVUGt8QMmfY19vyJDg/L6oENkx2NrqPg+l2LuCCw5kUP2Wtubnd+qOPr6BqKDAHZ7g3t9IObw5e+qgjyOxOPQ8oJevIkazhu6J6+LwGZDqsnckaR5mL3LRdBaItiMqIVZBIKSRWAqxQkw3wfeRjiBfKpNyyevMv0LLA4OEj0dOHRaBURaIaeJu3L0MXUHCybCltdM7kTtO1E3CFX45hEWzKMmUQZXmv root@ASUS" > /root/librereport/ssh_key.pub
chmod 700 ssh_key
git config --global user.email "kinko@interec.og"
git config --global user.name "Reporter"
eval $(ssh-agent -s)
ssh-add /root/librereport/ssh_key
git remote set-url origin git@github.com:librereport/reports.git
#####git pull git@github.com:librereport/reports.git

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
mv /tmp2 /root/librereport/reports/report.$timestamp
git add /root/librereport/reports/report.$timestamp
git commit -m 'New report'
git push origin master --force
killall ssh-agent

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
# do_installation
# do_configuration
do_report
