#!/bin/bash
# ---------------------------------------------------------
# This script aims to configure all the packages and 
# services which have been installed by test.sh script.
# This script is functionally seperated into 4 parts
#       1. Detect system variables
# 	2. Configuration of Network Interfaces 
# 	3. Configuration of Revers Proxy Services 
# 	4. Configuration of Applications
# ---------------------------------------------------------


# ---------------------------------------------------------
# Variables list
# ---------------------------------------------------------
PROCESSOR="Not Detected"        # Processor type (ARM/Intel/AMD)
HARDWARE="Not Detected"         # Hardware type (Board/Physical/Virtual)
PLATFORM="Not Detected"         # Platform type (U12/U14/D7/D8/T7)
ARCH="Not Detected"		# Architecture (i386/x86_64)
EXT_INTERFACE="Not Detected"    # External Interface (Connected to Internet)
INT_INETRFACE="Not Detected"    # Internal Interface (Connected to local network)


# ---------------------------------------------------------
# This function checks user. 
# Script must be executed by root user, otherwise it will
# output an error and terminate further execution.
# ---------------------------------------------------------
check_root ()
{
	echo -ne "Checking user root ... "
	if [ "$(whoami)" != "root" ]; then
		echo "Fail"
		echo "You need to be root to proceed. Exiting"
		exit 1
	else
	echo "OK"
fi
}


# ---------------------------------------------------------
# Function to get varibales from /var/box_variables file
# Variables to be initialized are:
#   PLATFORM
#   HARDWARE
#   PROCESSOR
#   EXT_INTERFACE
#   INT_INTERFACE
# ----------------------------------------------------------
get_variables()
{
	echo "Initializing variables ..."
	if [ -e /var/box_variables ]; then
		PLATFORM=`cat /var/box_variables | grep "Platform" | awk {'print $2'}`
		HARDWARE=`cat /var/box_variables | grep "Hardware" | awk {'print $2'}`
		PROCESSOR=`cat /var/box_variables | grep "Processor" | awk {'print $2'}`
		ARCH=`cat /var/box_variables | grep "Architecture" | awk {'print $2'}`
		EXT_INTERFACE=`cat /var/box_variables | grep "Ext_int" | awk {'print $2'}`
		INT_INTERFACE=`cat /var/box_variables | grep "Int_int" | awk {'print $2'}`

#	touch "/tmp/variables.log"

		if [ -z "$PLATFORM" -o -z "$HARDWARE" \
		     -o -z "$PROCESSOR" -o -z "$ARCH" \
		     -o -z "$EXT_INTERFACE" -o -z "$INT_INTERFACE" ]; then
			echo "Error: Can not detect variables. Exiting"
			exit 5
		else
			echo "Platform:      $PLATFORM"
			echo "Hardware:      $HARDWARE"
			echo "Processor:     $PROCESSOR"
			echo "Architecture:  $ARCH"
			echo "Ext Interface: $EXT_INTERFACE"
			echo "Int Interface: $INT_INTERFACE"
		fi 
	else 
		echo "Error: i cant find variables of the machine and operating system ,the installation script wasnt installed or failed, please check the Os requirements (at the moment only works in Debian 8 we are ongoing to ubuntu)" 
		exit 6
	fi
}


# ----------------------------------------------
# This function detects platform.
#
# Suitable platform are:
#
#  * Ubuntu 12.04
#  * Ubuntu 14.04
#  * Debian GNU/Linux 7
#  * Debian GNU/Linux 8
#  * Trisquel 7
# ----------------------------------------------
get_platform ()
{
        echo "Detecting platform ..."
        FILE=/etc/issue
        if cat $FILE | grep "Ubuntu 12.04" > /dev/null; then
                PLATFORM="U12"
        elif cat $FILE | grep "Ubuntu 14.04" > /dev/null; then
                PLATFORM="U14"
        elif cat $FILE | grep "Debian GNU/Linux 7" > /dev/null; then
                PLATFORM="D7"
        elif cat $FILE | grep "Debian GNU/Linux 8" > /dev/null; then
                PLATFORM="D8"
        elif cat $FILE | grep "Trisquel GNU/Linux 7.0" > /dev/null; then
                PLATFORM="T7"
        else
                echo "ERROR: UNKNOWN PLATFORM"
                exit
        fi
        echo "Platform: $PLATFORM"
}


# ----------------------------------------------
# This function checks hardware
# Hardware can be.
# 1. Intel board pipo x10.
# 2. Intel Physical/Virtual machine.
# Function gets Processor, Hardware and
# Architecture types and saves them in 
# PROCESSOR, HARDWARE and ARCH variables.
# ----------------------------------------------
get_hardware()
{
        echo "Detecting hardware ..."

        # Checking CPU for ARM and saving
        # Processor and Hardware types in
        # PROCESSOR and HARDWARE variables
        if grep ARM /proc/cpuinfo > /dev/null 2>&1; then
           PROCESSOR="ARM"
           HARDWARE=`cat /proc/cpuinfo | grep Hardware | awk {'print $3'}`
        # Checking CPU for Intel and saving
        # Processor and Hardware types in
        # PROCESSOR and HARDWARE variables
        elif grep Intel /proc/cpuinfo > /dev/null 2>&1;  then
           PROCESSOR="Intel"
           HARDWARE=`dmidecode -s system-product-name`
        # Checking CPU for AMD and saving
        # Processor and Hardware types in
        # PROCESSOR and HARDWARE variables
        elif grep AMD /proc/cpuinfo > /dev/null 2>&1;  then
           PROCESSOR="AMD"
           HARDWARE=`dmidecode -s system-product-name`
        fi

        # Detecting Architecture
        ARCH=`uname -m`

        # Printing Processor Hardware and Architecture types

        echo "Processor: $PROCESSOR"
        echo "Hardware: $HARDWARE"
        echo "Architecture: $ARCH"
}


# ----------------------------------------------
# This function enables DHCP client and checks
# for Internet on predefined network interface.
#
# Steps to define interface are:
#
# 1. Checking Internet access.
# *
# *
# ***** If success.
# *
# *     2. Get Interface name
# *
# ***** If no success.
#     *
#     * 2. Checking for DHCP server and Internet in
#       *  network connected to eth0.
#       *
#       ***** If success.
#       *   *
#       *   * 2. Enable DHCP client on eth0 and
#       *        default route to eth0
#       *
#       ***** If no success.
#           *
#           * 2. Checking for DHCP server and Internet
#           *  in network connected to eth1
#           *
#           ***** If success.
#           *   *
#           *   * 3. Enable DHCP client on eth1.
#           *
#           *
#           ***** If no success.
#               *
#               * 3. Warn user and exit with error.
#
# ----------------------------------------------
get_interfaces()
{
        # Check internet Connection. If Connection exist then get
        # and save Internet side network interface name in
        # EXT_INTERFACE variable
        if ping -c1 8.8.8.8 >/dev/null 2>/dev/null; then
                EXT_INTERFACE=`route -n | awk {'print $1 " " $8'} | grep "0.0.0.0" | awk {'print $2'} | sed -n '1p'`
                echo "Internet connection established on interface $EXT_INTERFACE"
        else
                # Checking eth0 for Internet connection
                echo "Getting Internet access on eth0"
                echo "# interfaces(5) file used by ifup(8) and ifdown(8) " > /etc/network/interfaces
                echo -e "auto lo\niface lo inet loopback\n" >> /etc/network/interfaces
                echo -e  "auto eth0\niface eth0 inet dhcp" >> /etc/network/interfaces
                /etc/init.d/networking restart
                if ping -c1 8.8.8.8 >/dev/null 2>/dev/null; then
                        echo "Internet conection established on: eth0"
                        EXT_INTERFACE="eth0"
                else
                        echo "Warning: Unable to get Internet access on eth0"
                        # Checking eth1 for Internet connection
                        echo "Getting Internet access on eth1"
                        echo "# interfaces(5) file used by ifup(8) and ifdown(8) " > /etc/network/interfaces
                        echo -e "auto lo\niface lo inet loopback\n" >> /etc/network/interfaces
                        echo -e "auto eth1\niface eth1 inet dhcp" >> /etc/network/interfaces
                        /etc/init.d/networking restart
                        if ping -c1 8.8.8.8 >/dev/null 2>/dev/null; then
                                echo "Internet conection established on: eth1"
                                EXT_INTERFACE="eth1"
                        else
                                echo "Warning: Unable to get Internet access on eth1"
                                echo "Please plugin Internet cable to eth0 or eth1 and enable DHCP on gateway"
                                echo "Error: Unable to get Internet access. Exiting"
                                exit 7
                        fi
                fi
        fi
        # Getting internal interface name
        INT_INTERFACE=`ls /sys/class/net/ | grep -w 'eth0\|eth1\|wlan0\|wlan1' | grep -v "$EXT_INTERFACE" | sed -n '1p'`
        echo "Internal interface: $INT_INTERFACE"
}


# ---------------------------------------------------------
# Function to get info about available HDDs 
# ---------------------------------------------------------
get_hdd(){
echo "Checking HDDs ..."

ALL_HDD=`lsblk -l | grep "disk" | awk '{print $1}' ORS=' '`
HDDS=`lsblk -l | grep "disk" | awk '{print $1}' | wc -l`

SYS_HDD=`lsblk -l | grep -w "/" | awk '{print $1}' | sed 's/[0-9]//g'`

if [ $HDDS -ge 2 ]; then
        EXT_HDD=`echo $ALL_HDD | sed s/"$SYS_HDD "//g`
else
        EXT_HDD="N/A"
fi
echo " 
Detected:  $ALL_HDD
System:    $SYS_HDD 
External:  $EXT_HDD
"   
}  


# ---------------------------------------------------------
# This functions configures hostname and static lookup
# table 
# ---------------------------------------------------------
configure_hosts()
{
echo "librerouter" > /etc/hostname

cat << EOF > /etc/hosts
#
# /etc/hosts: static lookup table for host names
#

#<ip-address>   <hostname.domain.org>   <hostname>
127.0.0.1       localhost.librenet librerouter localhost
10.0.0.1        librerouter.librenet
10.0.0.11       kibana.librenet
10.0.0.12       snorby.librenet
10.0.0.244      ntop.librenet
10.0.0.245      webmin.librenet
10.0.0.246      squidguard.librenet
10.0.0.247      gitlab.librenet
10.0.0.248	trac.librenet
10.0.0.249      redmine.librenet
10.0.0.250      easyrtc.librenet
10.0.0.251      yacy.librenet
10.0.0.252      friendica.librenet
10.0.0.253      owncloud.librenet
10.0.0.254      mailpile.librenet
10.0.0.250      conference.librerouter.net
10.0.0.251      search.librerouter.net
10.0.0.252      social.librerouter.net
10.0.0.253      storage.librerouter.net
10.0.0.254      email.librerouter.net
EOF
}


# ----------------------------------------------
# This script installs bridge-utils package and
# configures bridge interfaces.
#
# br0 = eth0 and wlan0
# br1 = eth1 and wlan1
# ----------------------------------------------
configure_bridges()
{
        # Updating and installing bridge-utils package
        echo "Updating repositories ..."
        apt-get update 2>&1 > /tmp/apt-get-update-bridge.log
        echo "Installing bridge-utils ..."
        apt-get install bridge-utils 2>&1 > /tmp/apt-get-install-bridge.log

        # Checking if bridge-utils is installed successfully
        if [ $? -ne 0 ]; then
                echo "Error: Unable to install bridge-utils"
                exit 8
        else

        EXT_BR_INT=`echo $EXT_INTERFACE | tail -c 2`
        INT_BR_INT=`echo $INT_INTERFACE | tail -c 2`

        echo "Configuring bridge interfaces..."
        echo "# interfaces(5) file used by ifup(8) and ifdown(8) " > /etc/network/interfaces
        echo "auto lo" >> /etc/network/interfaces
        echo "iface lo inet loopback" >> /etc/network/interfaces

        # Configuring bridge interfaces

        echo "#External network interface" >> /etc/network/interfaces
        echo "auto $EXT_INTERFACE" >> /etc/network/interfaces
        echo "allow-hotplug $EXT_INTERFACE" >> /etc/network/interfaces
        echo "iface $EXT_INTERFACE inet dhcp" >> /etc/network/interfaces

        echo "#External network interface" >> /etc/network/interfaces
        echo "auto wlan$EXT_BR_INT" >> /etc/network/interfaces
        echo "allow-hotplug wlan$EXT_BR_INT" >> /etc/network/interfaces
        echo "iface wlan$EXT_BR_INT inet manual" >> /etc/network/interfaces

        echo "##External Network Bridge " >> /etc/network/interfaces
        echo "#auto br$EXT_BR_INT" >> /etc/network/interfaces
        echo "#allow-hotplug br$EXT_BR_INT" >> /etc/network/interfaces
        echo "#iface br$EXT_BR_INT inet dhcp" >> /etc/network/interfaces
        echo "#bridge_ports eth$EXT_BR_INT wlan$EXT_BR_INT" >> /etc/network/interfaces

        echo "#Internal network interface" >> /etc/network/interfaces
        echo "auto $INT_INTERFACE" >> /etc/network/interfaces
        echo "allow-hotplug $INT_INTERFACE" >> /etc/network/interfaces
        echo "iface $INT_INTERFACE inet manual" >> /etc/network/interfaces

        echo "#Internal network interface" >> /etc/network/interfaces
        echo "auto wlan$INT_BR_INT" >> /etc/network/interfaces
        echo "allow-hotplug wlan$INT_BR_INT" >> /etc/network/interfaces
        echo "iface wlan$INT_BR_INT inet manual" >> /etc/network/interfaces

        echo "# Internal network Bridge" >> /etc/network/interfaces
        echo "auto br$INT_BR_INT" >> /etc/network/interfaces
        echo "allow-hotplug br$INT_BR_INT" >> /etc/network/interfaces
        echo "# Setup bridge" >> /etc/network/interfaces
        echo "iface br$INT_BR_INT inet static" >> /etc/network/interfaces
        echo "    bridge_ports eth$INT_BR_INT wlan$INT_BR_INT" >> /etc/network/interfaces
        echo "    address 10.0.0.1" >> /etc/network/interfaces
        echo "    netmask 255.255.255.0" >> /etc/network/interfaces
        echo "    network 10.0.0.0" >> /etc/network/interfaces
        fi
}


# ---------------------------------------------------------
# This function configures internal and external interfaces
# ---------------------------------------------------------
configure_interfaces()
{
	# Network interfaces configuration for 
	# Physical/Virtual machine
if [ "$PROCESSOR" = "Intel" -o "$PROCESSOR" = "AMD" -o "$PROCESSOR" = "ARM" ]; then
	cat << EOF >  /etc/network/interfaces 
	# interfaces(5) file used by ifup(8) and ifdown(8)
	auto lo
	iface lo inet loopback

	#External network interface
	auto $EXT_INTERFACE
	allow-hotplug $EXT_INTERFACE
	iface $EXT_INTERFACE inet dhcp

	#Internal network interface
	auto $INT_INTERFACE
	allow-hotplug $INT_INTERFACE
	iface $INT_INTERFACE inet static
	    address 10.0.0.1
	    netmask 255.255.255.0
            network 10.0.0.0
    
	#Yacy
	auto $INT_INTERFACE:1
	allow-hotplug $INT_INTERFACE:1
	iface $INT_INTERFACE:1 inet static
	    address 10.0.0.251
            netmask 255.255.255.0

	#Friendica
	auto $INT_INTERFACE:2
	allow-hotplug $INT_INTERFACE:2
	iface $INT_INTERFACE:2 inet static
	    address 10.0.0.252
	    netmask 255.255.255.0
    
	#OwnCloud
	auto $INT_INTERFACE:3
	allow-hotplug $INT_INTERFACE:3
	iface $INT_INTERFACE:3 inet static
	    address 10.0.0.253
	    netmask 255.255.255.0
    
	#Mailpile
	auto $INT_INTERFACE:4
	allow-hotplug $INT_INTERFACE:4
	iface $INT_INTERFACE:4 inet static
	    address 10.0.0.254
	    netmask 255.255.255.0
	
	#Webmin
	auto $INT_INTERFACE:5
	allow-hotplug $INT_INTERFACE:5
	iface $INT_INTERFACE:5 inet static
	    address 10.0.0.245
	    netmask 255.255.255.0
	
	#EasyRTC
	auto $INT_INTERFACE:6
	allow-hotplug $INT_INTERFACE:6
	iface $INT_INTERFACE:6 inet static
	    address 10.0.0.250
            netmask 255.255.255.0

	#Kibana
	auto $INT_INTERFACE:7
	allow-hotplug $INT_INTERFACE:7
	iface $INT_INTERFACE:7 inet static
	    address 10.0.0.11
	    netmask 255.255.255.0

	#Snorby
	auto $INT_INTERFACE:8
	allow-hotplug $INT_INTERFACE:8
	iface $INT_INTERFACE:8 inet static
	    address 10.0.0.12
	    netmask 255.255.255.0

        #squidguard
        auto $INT_INTERFACE:9
        allow-hotplug $INT_INTERFACE:9
        iface $INT_INTERFACE:9 inet static
            address 10.0.0.246
            netmask 255.255.255.0

        #gitlab
        auto $INT_INTERFACE:10
        allow-hotplug $INT_INTERFACE:10
        iface $INT_INTERFACE:10 inet static
            address 10.0.0.247
            netmask 255.255.255.0

        #trac
        auto $INT_INTERFACE:11
        allow-hotplug $INT_INTERFACE:11
        iface $INT_INTERFACE:11 inet static
            address 10.0.0.248
            netmask 255.255.255.0

        #redmine
        auto $INT_INTERFACE:12
        allow-hotplug $INT_INTERFACE:12
        iface $INT_INTERFACE:12 inet static
            address 10.0.0.249
            netmask 255.255.255.0

	#Webmin
        auto $INT_INTERFACE:13
        allow-hotplug $INT_INTERFACE:13
        iface $INT_INTERFACE:13 inet static
            address 10.0.0.244
            netmask 255.255.255.0
EOF
	# Network interfaces configuration for board
#	elif [ "$PROCESSOR" = "ARM" ]; then
#	cat << EOF >  /etc/network/interfaces 
#	# interfaces(5) file used by ifup(8) and ifdown(8)
#	auto lo
#	iface lo inet loopback
#
#	#External network interface
#	auto eth0
#	allow-hotplug eth0
#	iface eth0 inet dhcp
#
#	#External network interface
#	# wireless wlan0
#	auto wlan0
#	allow-hotplug wlan0
#	iface wlan0 inet dhcp
#
#	##External Network Bridge 
#	#auto br0
#	allow-hotplug br0
#	iface br0 inet dhcp   
#	    bridge_ports eth0 wlan0
#
#	#Internal network interface
#	auto eth1
#	allow-hotplug eth1
#	iface eth1 inet manual
#
#	#Internal network interface
#	# wireless wlan1
#	auto wlan1
#	allow-hotplug wlan1
#	iface wlan1 inet manual
#
#	#Internal network Bridge
#	auto br1
#	allow-hotplug br1
#	# Setup bridge
#	iface br1 inet static
#	    bridge_ports eth1 wlan1
#	    address 10.0.0.1
#	    netmask 255.255.255.0
#	    network 10.0.0.0
#    
#	#Yacy
#	auto eth1:1
#	allow-hotplug eth1:1
#	iface eth1:1 inet static
#	    address 10.0.0.251
#	    netmask 255.255.255.0
#
#	#Friendica
#	auto eth1:2
#	allow-hotplug eth1:2
#	iface eth1:2 inet static
#	    address 10.0.0.252
#	    netmask 255.255.255.0
#    
#	#OwnCloud
#	auto eth1:3
#	allow-hotplug eth1:3
#	iface eth1:3 inet static
#	    address 10.0.0.253
#	    netmask 255.255.255.0
#    
#	#Mailpile
#	auto eth1:4
#	allow-hotplug eth1:4
#	iface eth1:4 inet static
#	    address 10.0.0.254
#	    netmask 255.255.255.0
#	
#	#Webmin
#	auto eth1:5
#	allow-hotplug eth1:5
#	iface eth1:5 inet static
#	    address 10.0.0.245
#	    netmask 255.255.255.0
#
#	#EasyRTC
#	auto eth1:6
#	allow-hotplug eth1:6
#	iface eth1:6 inet static
#	    address 10.0.0.250
#	    netmask 255.255.255.0
#
#EOF

fi

# Restarting network configuration
/etc/init.d/networking restart
}


# ---------------------------------------------------------
# Function to configure DHCP server
# ---------------------------------------------------------
configure_dhcp()
{
echo "Configuring dhcp server ..."
echo "
ddns-update-style none;
option domain-name \"librerouter.librenet\";
option domain-name-servers 10.0.0.1;
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet 10.0.0.0 netmask 255.255.255.0 {
range 10.0.0.100 10.0.0.200;
option routers 10.0.0.1;
}
" > /etc/dhcp/dhcpd.conf

# Restarting dhcp server
service isc-dhcp-server restart
}


# ---------------------------------------------------------
# Function to configure blacklists
# ---------------------------------------------------------
configre_blacklists()
{
#mkdir -p /etc/blacklists
#cd /etc/blacklists
#
#cat << EOF > /etc/blacklists/update-blacklists.sh
##!/bin/bash
#
##squidguard DB
#mkdir -p /etc/blacklists/shallalist/tmp 
#cd /etc/blacklists/shallalist/tmp
#wget http://www.shallalist.de/Downloads/shallalist.tar.gz
#tar xvzf shallalist.tar.gz ; res=\$?
#rm -f shallalist.tar.gz
#if [ "\$res" = 0 ]; then
# rm -fr /etc/blacklists/shallalist/ok
# mv /etc/blacklists/shallalist/tmp /etc/blacklists/shallalist/ok
#else
# rm -fr /etc/blacklists/shallalist/tmp 
#fi
#
#mkdir -p /etc/blacklists/urlblacklist/tmp
#cd /etc/blacklists/urlblacklist/tmp
#wget http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download\\&file=bigblacklist -O urlblacklist.tar.gz
#tar xvzf urlblacklist.tar.gz ; res=\$?
#rm -f urlblacklist.tar.gz
#if [ "\$res" = 0 ]; then
# rm -fr /etc/blacklists/urlblacklist/ok
# mv /etc/blacklists/urlblacklist/tmp /etc/blacklists/urlblacklist/ok
#else
# rm -fr /etc/blacklists/urlblacklist/tmp 
#fi
#
#mkdir -p /etc/blacklists/mesdk12/tmp
#cd /etc/blacklists/mesdk12/tmp
#wget http://squidguard.mesd.k12.or.us/blacklists.tgz
#tar xvzf blacklists.tgz ; res=\$?
#rm -f blacklists.tgz
#if [ "\$res" = 0 ]; then
# rm -fr /etc/blacklists/mesdk12/ok
# mv /etc/blacklists/mesdk12/tmp /etc/blacklists/mesdk12/ok
#else
# rm -fr /etc/blacklists/mesdk12/tmp 
#fi
#
#mkdir -p /etc/blacklists/capitole/tmp
#cd /etc/blacklists/capitole/tmp
#wget ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/publicite.tar.gz
#tar xvzf publicite.tar.gz ; res=\$?
#rm -f publicite.tar.gz
#if [ "\$res" = 0 ]; then
# rm -fr /etc/blacklists/capitole/ok
# mv /etc/blacklists/capitole/tmp /etc/blacklists/capitole/ok
#else
# rm -fr /etc/blacklists/capitole/tmp 
#fi
#
#
## chown proxy:proxy -R /etc/blacklists/*
#
#EOF
#
#chmod +x /etc/blacklists/update-blacklists.sh
#/etc/blacklists/update-blacklists.sh
#
#cat << EOF > /etc/blacklists/blacklists-iptables.sh
##ipset implementation for nat
#for i in \$(grep -iv [A-Z] /etc/blacklists/shallalist/ok/BL/adv/domains)
#do
#  iptables -t nat -I PREROUTING -i br1 -s 10.0.0.0/16 -p tcp -d \$i -j DNAT --to-destination 5.5.5.5
#done
#EOF
#
#chmod +x /etc/blacklists/blacklists-iptables.sh

cat /etc/unbound/block_domain.list.conf | awk -F '"' '{print $2}' | awk '{print $1}' > ads_domains
for i in `cat ads_domains`
do
iptables -t nat -I PREROUTING -p tcp -s 10.0.0.0/24 -d $i -j DNAT --to-destination 10.0.0.1
done

}


# ---------------------------------------------------------
# Function to configure mysql
# ---------------------------------------------------------
configure_mysql()
{
echo "Configuring MySQL ..."
# Getting MySQL password
if grep "DB_PASS" /var/box_variables > /dev/null 2>&1; then
	MYSQL_PASS=`cat /var/box_variables | grep "DB_PASS" | awk {'print $2'}`
else
	MYSQL_PASS=`pwgen 10 1`
	echo "DB_PASS: $MYSQL_PASS" >> /var/box_variables
	# Setting password
	mysqladmin -u root password $MYSQL_PASS
fi
}


# ---------------------------------------------------------
# Function to configure banks direct access to Internet
# ---------------------------------------------------------
configure_banks_access()
{
touch /var/banks_ips.txt
echo "192.229.182.219
194.224.167.58
195.21.32.34
195.21.32.40
192.229.182.219
" > /var/banks_ips.txt

touch /var/banks_access.sh
cat << EOF > /var/banks_access.sh
#!/bin/bash
for i in \$(cat /var/banks_ips.txt)
do
iptables -t nat -I PREROUTING -i $INT_INTERFACE -p tcp -d \$i -j ACCEPT
done
EOF
chmod a+x /var/banks_access.sh
}


# ---------------------------------------------------------
# Function to configure iptables
# ---------------------------------------------------------
configure_iptables()
{

# Disabling ipv6 and enabling ipv4 forwarding
echo "
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
" > /etc/sysctl.conf

# Restarting sysctl
sysctl -p > /dev/null

cat << EOF > /etc/rc.local
#!/bin/sh

iptables -X
iptables -F
iptables -t nat -F
iptables -t filter -F

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.11 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.12 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.244 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.245 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.246 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.247 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.248 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.249 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.250 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.251 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.252 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.253 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.254 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p udp -d 10.0.0.1 --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 80 -j REDIRECT --to-ports 80
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 443 -j REDIRECT --to-ports 443
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 7000 -j REDIRECT --to-ports 7000

# to squid-i2p 
iptables -t nat -A OUTPUT     -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -m tcp --sport 80 -d 10.191.0.1 -j REDIRECT --to-ports 3128

# ssh to tor socks proxy
iptables -t nat -A OUTPUT -p tcp -d 10.0.0.0/8 --dport 22 -j REDIRECT --to-ports 9051
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.0/8 --dport 22 -j REDIRECT --to-ports 9051

# to squid-tor
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.0/8 -j DNAT --to 10.0.0.1:3129

# to squid http 
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --dport 80 -j DNAT --to 10.0.0.1:3130

# to squid https 
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --dport 443 -j REDIRECT --to-ports 3131

# iptables nat
iptables -t nat -A POSTROUTING -o $EXT_INTERFACE -j MASQUERADE 

# Redirecting traffic to tor
#iptables -t nat -A PREROUTING -i eth0 -p tcp -d 10.0.0.0/8 --dport 80 --syn -j REDIRECT --to-ports 9040
#iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 53

# Redirecting http traffic to squid 
#iptables -t nat -A PREROUTING -i eth1 -p tcp ! -d 10.0.0.0/24 --dport 80 -j DNAT --to 10.0.0.1:3128
#iptables -t nat -A PREROUTING -i eth0 -p tcp ! -d 10.0.0.0/24 --dport 80 -j DNAT --to 10.0.0.1:3128

## i2p petitions 
#iptables -t nat -A OUTPUT     -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
#iptables -t nat -A PREROUTING -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
#iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -m tcp --sport 80 -d 10.191.0.1 -j REDIRECT --to-ports 3128 

## Allow surf onion zone
#iptables -t nat -A PREROUTING -p tcp -d 10.192.0.0/16 -j REDIRECT --to-port 9040
#iptables -t nat -A OUTPUT     -p tcp -d 10.192.0.0/16 -j REDIRECT --to-port 9040
#iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --syn -m multiport ! --dports 80 -j REDIRECT --to-ports 9040

## Enable Blacklist
#[ -e /etc/blacklists/blacklists-iptables.sh ] && /etc/blacklists/blacklists-iptables.sh &

# Configuring banks direct access
/var/banks_access.sh

# Stopping dnsmasq
kill -9 \`ps aux | grep dnsmasq | awk {'print \$2'} | sed -n '1p'\` \
2> /dev/null
service unbound restart

# Starting easyrtc
nohup nodejs /opt/easyrtc/server_example/server.js &

# Starting Mailpile
/usr/bin/screen -dmS mailpile_init /opt/Mailpile/mp

# Restarting i2p
/etc/init.d/i2p restart

# Restarting tor
/etc/init.d/tor restart

# Running uwsgi
uwsgi --ini /etc/uwsgi/uwsgi.ini & > /dev/null 2>&1

# Time sync
ntpdate -s ntp.ubuntu.com

# Start nginx
/etc/init.d/nginx start > /dev/null 2>&1 

# Start suricata
suricata -D -c /etc/suricata/suricata.yaml -i lo &

# Start logstash
/opt/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf & > /dev/null 2>&1

# Start Evebox
evebox -e http://localhost:9200 &

# Start elasticsearch
/etc/init.d/elasticsearch start

# Start Trac 
tracd -s -b 127.0.0.1 --port 8000 /opt/trac/libretrac &

# Start Redmine
thin -c /opt/redmine/redmine-3.3.1 --servers 1 -e production -a 127.0.0.1 -p 8889 -d start > /dev/null 2>&1

# Start Redsocks
/opt/redsocks/redsocks -c /opt/redsocks/redsocks.conf

exit 0
EOF

chmod +x /etc/rc.local

/etc/rc.local
}


# ---------------------------------------------------------
# Function to configure TOR
# ---------------------------------------------------------
configure_tor()
{
echo "Configuring Tor server ..."
tordir=/var/lib/tor/hidden_service
for i in yacy owncloud friendica mailpile easyrtc ssh gitlab trac redmine  
do

# Setting user and group to debian-tor
mkdir -p $tordir/$i
chown debian-tor:debian-tor $tordir/$i -R
rm -f $tordir/$i/*

# Setting permission to 2740 "rwxr-s---"
chmod 2700 $tordir/*

done

# Setting RUN_DAEMON to yes
# waitakey
# $EDITOR /etc/default/tor 
sed "s~RUN_DAEMON=.*~RUN_DAEMON=\"yes\"~g" -i /etc/default/tor


rm -f /etc/tor/torrc
#cp /usr/share/tor/tor-service-defaults-torrc /etc/tor/torrc
echo "" > /usr/share/tor/tor-service-defaults-torrc

echo "Configuring Tor hidden services"

echo "
DataDirectory /var/lib/tor
PidFile /var/run/tor/tor.pid
RunAsDaemon 1
User debian-tor

ControlSocket /var/run/tor/control GroupWritable RelaxDirModeCheck
ControlSocketsGroupWritable 1
SocksPort unix:/var/run/tor/socks WorldWritable
SocksPort 127.0.0.1:9050

CookieAuthentication 1
CookieAuthFileGroupReadable 1
CookieAuthFile /var/run/tor/control.authcookie

Log notice file /var/log/tor/log

# ----- Hidden services ----- #

HiddenServiceDir /var/lib/tor/hidden_service/yacy
HiddenServicePort 80 10.0.0.251:80

HiddenServiceDir /var/lib/tor/hidden_service/owncloud
HiddenServicePort 80 10.0.0.253:80
HiddenServicePort 443 10.0.0.253:443

#HiddenServiceDir /var/lib/tor/hidden_service/prosody
#HiddenServicePort 5222 127.0.0.1:5222
#HiddenServicePort 5269 127.0.0.1:5269

HiddenServiceDir /var/lib/tor/hidden_service/friendica
HiddenServicePort 80 10.0.0.252:80
HiddenServicePort 443 10.0.0.252:443 

HiddenServiceDir /var/lib/tor/hidden_service/mailpile
HiddenServicePort 80 10.0.0.254:80
HiddenServicePort 443 10.0.0.254:443

HiddenServiceDir /var/lib/tor/hidden_service/easyrtc
HiddenServicePort 80 10.0.0.250:80
HiddenServicePort 443 10.0.0.250:443

HiddenServiceDir /var/lib/tor/hidden_service/ssh
HiddenServicePort 22 10.0.0.1:22

HiddenServiceDir /var/lib/tor/hidden_service/gitlab
HiddenServicePort 80 10.0.0.247:80
HiddenServicePort 443 10.0.0.247:443

HiddenServiceDir /var/lib/tor/hidden_service/trac
HiddenServicePort 80 10.0.0.248:80
HiddenServicePort 443 10.0.0.248:443

HiddenServiceDir /var/lib/tor/hidden_service/redmine
HiddenServicePort 80 10.0.0.249:80
HiddenServicePort 443 10.0.0.249:443

# ----- Tor DNS ----- #

DNSPort   127.0.0.1:9053
VirtualAddrNetworkIPv4 10.0.0.0/8
AutomapHostsOnResolve 1
" >>  /etc/tor/torrc

service nginx stop 
sleep 10
service tor restart

LOOP_S=0
LOOP_N=0
while [ $LOOP_S -lt 1 ]
do
if [ -e "/var/lib/tor/hidden_service/yacy/hostname" ]; then
echo "Tor successfully configured"
LOOP_S=1
else
sleep 1
LOOP_N=$((LOOP_N + 1))
fi
# Wail up to 60 s for tor hidden services to become available
if [ $LOOP_N -eq 60 ]; then
echo "Error: Unable to configure tor. Exiting ..."
exit 1 
fi 
done
}


# ---------------------------------------------------------
# Function to configure I2P services
# ---------------------------------------------------------
configure_i2p()
{
echo "Configuring i2p server ..."
# echo "Changeing RUN_DAEMON ..."
# waitakey
# $EDITOR /etc/default/i2p
sed "s~RUN_DAEMON=.*~RUN_DAEMON=\"true\"~g" -i /etc/default/i2p

# i2p hidden services
cat << EOF > /var/lib/i2p/i2p-config/i2ptunnel.config
# NOTE: This I2P config file must use UTF-8 encoding
tunnel.0.description=HTTP proxy for browsing eepsites and the web
tunnel.0.i2cpHost=127.0.0.1
tunnel.0.i2cpPort=7654
tunnel.0.interface=127.0.0.1
tunnel.0.listenPort=4444
tunnel.0.name=I2P HTTP Proxy
tunnel.0.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.0.option.i2cp.reduceIdleTime=900000
tunnel.0.option.i2cp.reduceOnIdle=true
tunnel.0.option.i2cp.reduceQuantity=1
tunnel.0.option.i2p.streaming.connectDelay=1000
tunnel.0.option.i2ptunnel.httpclient.SSLOutproxies=false.i2p
tunnel.0.option.inbound.length=3
tunnel.0.option.inbound.lengthVariance=0
tunnel.0.option.inbound.nickname=shared clients
tunnel.0.option.outbound.length=3
tunnel.0.option.outbound.lengthVariance=0
tunnel.0.option.outbound.nickname=shared clients
tunnel.0.option.outbound.priority=10
tunnel.0.proxyList=false.i2p
tunnel.0.sharedClient=true
tunnel.0.startOnLoad=true
tunnel.0.type=httpclient
tunnel.1.description=IRC tunnel to access the Irc2P network
tunnel.1.i2cpHost=127.0.0.1
tunnel.1.i2cpPort=7654
tunnel.1.interface=127.0.0.1
tunnel.1.listenPort=6668
tunnel.1.name=Irc2P
tunnel.1.option.crypto.lowTagThreshold=14
tunnel.1.option.crypto.tagsToSend=20
tunnel.1.option.i2cp.closeIdleTime=1200000
tunnel.1.option.i2cp.closeOnIdle=true
tunnel.1.option.i2cp.delayOpen=true
tunnel.1.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.1.option.i2cp.newDestOnResume=false
tunnel.1.option.i2cp.reduceIdleTime=600000
tunnel.1.option.i2cp.reduceOnIdle=true
tunnel.1.option.i2cp.reduceQuantity=1
tunnel.1.option.i2p.streaming.connectDelay=1000
tunnel.1.option.i2p.streaming.maxWindowSize=16
tunnel.1.option.inbound.length=3
tunnel.1.option.inbound.lengthVariance=0
tunnel.1.option.inbound.nickname=Irc2P
tunnel.1.option.outbound.length=3
tunnel.1.option.outbound.lengthVariance=0
tunnel.1.option.outbound.nickname=Irc2P
tunnel.1.option.outbound.priority=15
tunnel.1.sharedClient=false
tunnel.1.startOnLoad=true
tunnel.1.targetDestination=irc.dg.i2p:6667,irc.postman.i2p:6667,irc.echelon.i2p:6667
tunnel.1.type=ircclient
tunnel.2.description=I2P Monotone Server
tunnel.2.i2cpHost=127.0.0.1
tunnel.2.i2cpPort=7654
tunnel.2.interface=127.0.0.1
tunnel.2.listenPort=8998
tunnel.2.name=mtn.i2p-projekt.i2p
tunnel.2.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.2.option.i2cp.reduceIdleTime=900000
tunnel.2.option.i2cp.reduceOnIdle=true
tunnel.2.option.i2cp.reduceQuantity=1
tunnel.2.option.inbound.length=3
tunnel.2.option.inbound.lengthVariance=0
tunnel.2.option.inbound.nickname=shared clients
tunnel.2.option.outbound.length=3
tunnel.2.option.outbound.lengthVariance=0
tunnel.2.option.outbound.nickname=shared clients
tunnel.2.sharedClient=true
tunnel.2.startOnLoad=false
tunnel.2.targetDestination=mtn.i2p-projekt.i2p:4691
tunnel.2.type=client
tunnel.3.description=My eepsite
tunnel.3.i2cpHost=127.0.0.1
tunnel.3.i2cpPort=7654
tunnel.3.name=I2P webserver
tunnel.3.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.3.option.inbound.length=3
tunnel.3.option.inbound.lengthVariance=0
tunnel.3.option.inbound.nickname=eepsite
tunnel.3.option.outbound.length=3
tunnel.3.option.outbound.lengthVariance=0
tunnel.3.option.outbound.nickname=eepsite
tunnel.3.option.shouldBundleReplyInfo=false
tunnel.3.privKeyFile=eepsite/eepPriv.dat
tunnel.3.spoofedHost=mysite.i2p
tunnel.3.startOnLoad=false
tunnel.3.targetHost=127.0.0.1
tunnel.3.targetPort=7658
tunnel.3.type=httpserver
tunnel.3.description=My eepsite
tunnel.3.i2cpHost=127.0.0.1
tunnel.3.i2cpPort=7654
tunnel.3.name=I2P webserver
tunnel.3.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.3.option.inbound.length=3
tunnel.3.option.inbound.lengthVariance=0
tunnel.3.option.inbound.nickname=eepsite
tunnel.3.option.outbound.length=3
tunnel.3.option.outbound.lengthVariance=0
tunnel.3.option.outbound.nickname=eepsite
tunnel.3.option.shouldBundleReplyInfo=false
tunnel.3.privKeyFile=eepsite/eepPriv.dat
tunnel.3.spoofedHost=mysite.i2p
tunnel.3.startOnLoad=false
tunnel.3.targetHost=127.0.0.1
tunnel.3.targetPort=7658
tunnel.3.type=httpserver
tunnel.4.description=smtp server
tunnel.4.i2cpHost=127.0.0.1
tunnel.4.i2cpPort=7654
tunnel.4.interface=127.0.0.1
tunnel.4.listenPort=7659
tunnel.4.name=smtp.postman.i2p
tunnel.4.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.4.option.i2cp.reduceIdleTime=900000
tunnel.4.option.i2cp.reduceOnIdle=true
tunnel.4.option.i2cp.reduceQuantity=1
tunnel.4.option.inbound.length=3
tunnel.4.option.inbound.lengthVariance=0
tunnel.4.option.inbound.nickname=shared clients
tunnel.4.option.outbound.length=3
tunnel.4.option.outbound.lengthVariance=0
tunnel.4.option.outbound.nickname=shared clients
tunnel.4.sharedClient=true
tunnel.4.startOnLoad=true
tunnel.4.targetDestination=smtp.postman.i2p:25
tunnel.4.type=client
tunnel.5.description=pop3 server
tunnel.5.i2cpHost=127.0.0.1
tunnel.5.i2cpPort=7654
tunnel.5.interface=127.0.0.1
tunnel.5.listenPort=7660
tunnel.5.name=pop3.postman.i2p
tunnel.5.option.i2cp.destination.sigType=ECDSA_SHA256_P256
tunnel.5.option.i2cp.reduceIdleTime=900000
tunnel.5.option.i2cp.reduceOnIdle=true
tunnel.5.option.i2cp.reduceQuantity=1
tunnel.5.option.i2p.streaming.connectDelay=1000
tunnel.5.option.inbound.length=3
tunnel.5.option.inbound.lengthVariance=0
tunnel.5.option.inbound.nickname=shared clients
tunnel.5.option.outbound.length=3
tunnel.5.option.outbound.lengthVariance=0
tunnel.5.option.outbound.nickname=shared clients
tunnel.5.sharedClient=true
tunnel.5.startOnLoad=true
tunnel.5.targetDestination=pop.postman.i2p:110
tunnel.5.type=client
tunnel.6.description=HTTPS proxy for browsing eepsites and the web
tunnel.6.i2cpHost=127.0.0.1
tunnel.6.i2cpPort=7654
tunnel.6.interface=127.0.0.1
tunnel.6.listenPort=4445
tunnel.6.name=I2P HTTPS Proxy
tunnel.6.option.i2cp.reduceIdleTime=900000
tunnel.6.option.i2cp.reduceOnIdle=true
tunnel.6.option.i2cp.reduceQuantity=1
tunnel.6.option.i2p.streaming.connectDelay=1000
tunnel.6.option.inbound.length=3
tunnel.6.option.inbound.lengthVariance=0
tunnel.6.option.inbound.nickname=shared clients
tunnel.6.option.outbound.length=3
tunnel.6.option.outbound.lengthVariance=0
tunnel.6.option.outbound.nickname=shared clients
tunnel.6.proxyList=outproxy-tor.meeh.i2p
tunnel.6.sharedClient=true
tunnel.6.startOnLoad=true
tunnel.6.type=connectclient
tunnel.7.description=easyrtc
tunnel.7.name=easyrtc server
tunnel.7.option.enableUniqueLocal=false
tunnel.7.option.i2cp.destination.sigType=1
tunnel.7.option.i2cp.enableAccessList=false
tunnel.7.option.i2cp.enableBlackList=false
tunnel.7.option.i2cp.encryptLeaseSet=false
tunnel.7.option.i2cp.reduceIdleTime=1200000
tunnel.7.option.i2cp.reduceOnIdle=false
tunnel.7.option.i2cp.reduceQuantity=1
tunnel.7.option.i2p.streaming.connectDelay=0
tunnel.7.option.i2p.streaming.maxConcurrentStreams=0
tunnel.7.option.i2p.streaming.maxConnsPerDay=0
tunnel.7.option.i2p.streaming.maxConnsPerHour=0
tunnel.7.option.i2p.streaming.maxConnsPerMinute=0
tunnel.7.option.i2p.streaming.maxTotalConnsPerDay=0
tunnel.7.option.i2p.streaming.maxTotalConnsPerHour=0
tunnel.7.option.i2p.streaming.maxTotalConnsPerMinute=0
tunnel.7.option.inbound.backupQuantity=0
tunnel.7.option.inbound.length=3
tunnel.7.option.inbound.lengthVariance=0
tunnel.7.option.inbound.nickname=easyrtc server
tunnel.7.option.inbound.quantity=2
tunnel.7.option.inbound.randomKey=YlziI03Dh95j5lGlVzXjQehxMq913sDiSlgihQVJSiI=
tunnel.7.option.maxPosts=0
tunnel.7.option.maxTotalPosts=0
tunnel.7.option.outbound.backupQuantity=0
tunnel.7.option.outbound.length=3
tunnel.7.option.outbound.lengthVariance=0
tunnel.7.option.outbound.nickname=easyrtc server
tunnel.7.option.outbound.quantity=2
tunnel.7.option.outbound.randomKey=xPyC-Y3Voh5MznimTaS00rVP2v74khpLEDI5fikPoO8=
tunnel.7.option.postBanTime=1800
tunnel.7.option.postCheckTime=300
tunnel.7.option.postTotalBanTime=600
tunnel.7.option.rejectInproxy=false
tunnel.7.option.rejectReferer=false
tunnel.7.option.rejectUserAgents=false
tunnel.7.option.shouldBundleReplyInfo=false
tunnel.7.option.useSSL=false
tunnel.7.privKeyFile=i2ptunnel7-privKeys.dat
tunnel.7.spoofedHost=easyrtc.i2p
tunnel.7.startOnLoad=true
tunnel.7.targetHost=10.0.0.250
tunnel.7.targetPort=80
tunnel.7.type=httpserver
tunnel.8.description=yacy
tunnel.8.name=yacy server
tunnel.8.option.enableUniqueLocal=false
tunnel.8.option.i2cp.destination.sigType=1
tunnel.8.option.i2cp.enableAccessList=false
tunnel.8.option.i2cp.enableBlackList=false
tunnel.8.option.i2cp.encryptLeaseSet=false
tunnel.8.option.i2cp.reduceIdleTime=1200000
tunnel.8.option.i2cp.reduceOnIdle=false
tunnel.8.option.i2cp.reduceQuantity=1
tunnel.8.option.i2p.streaming.connectDelay=0
tunnel.8.option.i2p.streaming.maxConcurrentStreams=0
tunnel.8.option.i2p.streaming.maxConnsPerDay=0
tunnel.8.option.i2p.streaming.maxConnsPerHour=0
tunnel.8.option.i2p.streaming.maxConnsPerMinute=0
tunnel.8.option.i2p.streaming.maxTotalConnsPerDay=0
tunnel.8.option.i2p.streaming.maxTotalConnsPerHour=0
tunnel.8.option.i2p.streaming.maxTotalConnsPerMinute=0
tunnel.8.option.inbound.backupQuantity=0
tunnel.8.option.inbound.length=3
tunnel.8.option.inbound.lengthVariance=0
tunnel.8.option.inbound.nickname=yacy server
tunnel.8.option.inbound.quantity=2
tunnel.8.option.inbound.randomKey=YlziI03Dh95j5lGlVzXjQehxMq913sDiSlgihQVJSiI=
tunnel.8.option.maxPosts=0
tunnel.8.option.maxTotalPosts=0
tunnel.8.option.outbound.backupQuantity=0
tunnel.8.option.outbound.length=3
tunnel.8.option.outbound.lengthVariance=0
tunnel.8.option.outbound.nickname=yacy server
tunnel.8.option.outbound.quantity=2
tunnel.8.option.outbound.randomKey=xPyC-Y3Voh5MznimTaS00rVP2v74khpLEDI5fikPoO8=
tunnel.8.option.postBanTime=1800
tunnel.8.option.postCheckTime=300
tunnel.8.option.postTotalBanTime=600
tunnel.8.option.rejectInproxy=false
tunnel.8.option.rejectReferer=false
tunnel.8.option.rejectUserAgents=false
tunnel.8.option.shouldBundleReplyInfo=false
tunnel.8.option.useSSL=false
tunnel.8.privKeyFile=i2ptunnel8-privKeys.dat
tunnel.8.spoofedHost=yacy.i2p
tunnel.8.startOnLoad=true
tunnel.8.targetHost=10.0.0.251
tunnel.8.targetPort=80
tunnel.8.type=httpserver
tunnel.9.description=friendica
tunnel.9.name=friendica server
tunnel.9.option.enableUniqueLocal=false
tunnel.9.option.i2cp.destination.sigType=1
tunnel.9.option.i2cp.enableAccessList=false
tunnel.9.option.i2cp.enableBlackList=false
tunnel.9.option.i2cp.encryptLeaseSet=false
tunnel.9.option.i2cp.reduceIdleTime=1200000
tunnel.9.option.i2cp.reduceOnIdle=false
tunnel.9.option.i2cp.reduceQuantity=1
tunnel.9.option.i2p.streaming.connectDelay=0
tunnel.9.option.i2p.streaming.maxConcurrentStreams=0
tunnel.9.option.i2p.streaming.maxConnsPerDay=0
tunnel.9.option.i2p.streaming.maxConnsPerHour=0
tunnel.9.option.i2p.streaming.maxConnsPerMinute=0
tunnel.9.option.i2p.streaming.maxTotalConnsPerDay=0
tunnel.9.option.i2p.streaming.maxTotalConnsPerHour=0
tunnel.9.option.i2p.streaming.maxTotalConnsPerMinute=0
tunnel.9.option.inbound.backupQuantity=0
tunnel.9.option.inbound.length=3
tunnel.9.option.inbound.lengthVariance=0
tunnel.9.option.inbound.nickname=friendica server
tunnel.9.option.inbound.quantity=2
tunnel.9.option.inbound.randomKey=YlziI03Dh95j5lGlVzXjQehxMq913sDiSlgihQVJSiI=
tunnel.9.option.maxPosts=0
tunnel.9.option.maxTotalPosts=0
tunnel.9.option.outbound.backupQuantity=0
tunnel.9.option.outbound.length=3
tunnel.9.option.outbound.lengthVariance=0
tunnel.9.option.outbound.nickname=friendica server
tunnel.9.option.outbound.quantity=2
tunnel.9.option.outbound.randomKey=xPyC-Y3Voh5MznimTaS00rVP2v74khpLEDI5fikPoO8=
tunnel.9.option.postBanTime=1800
tunnel.9.option.postCheckTime=300
tunnel.9.option.postTotalBanTime=600
tunnel.9.option.rejectInproxy=false
tunnel.9.option.rejectReferer=false
tunnel.9.option.rejectUserAgents=false
tunnel.9.option.shouldBundleReplyInfo=false
tunnel.9.option.useSSL=false
tunnel.9.privKeyFile=i2ptunnel9-privKeys.dat
tunnel.9.spoofedHost=friendica.i2p
tunnel.9.startOnLoad=true
tunnel.9.targetHost=10.0.0.252
tunnel.9.targetPort=80
tunnel.9.type=httpserver
tunnel.10.description=owncloud
tunnel.10.name=owncloud server
tunnel.10.option.enableUniqueLocal=false
tunnel.10.option.i2cp.destination.sigType=1
tunnel.10.option.i2cp.enableAccessList=false
tunnel.10.option.i2cp.enableBlackList=false
tunnel.10.option.i2cp.encryptLeaseSet=false
tunnel.10.option.i2cp.reduceIdleTime=1200000
tunnel.10.option.i2cp.reduceOnIdle=false
tunnel.10.option.i2cp.reduceQuantity=1
tunnel.10.option.i2p.streaming.connectDelay=0
tunnel.10.option.i2p.streaming.maxConcurrentStreams=0
tunnel.10.option.i2p.streaming.maxConnsPerDay=0
tunnel.10.option.i2p.streaming.maxConnsPerHour=0
tunnel.10.option.i2p.streaming.maxConnsPerMinute=0
tunnel.10.option.i2p.streaming.maxTotalConnsPerDay=0
tunnel.10.option.i2p.streaming.maxTotalConnsPerHour=0
tunnel.10.option.i2p.streaming.maxTotalConnsPerMinute=0
tunnel.10.option.inbound.backupQuantity=0
tunnel.10.option.inbound.length=3
tunnel.10.option.inbound.lengthVariance=0
tunnel.10.option.inbound.nickname=owncloud server
tunnel.10.option.inbound.quantity=2
tunnel.10.option.inbound.randomKey=YlziI03Dh95j5lGlVzXjQehxMq913sDiSlgihQVJSiI=
tunnel.10.option.maxPosts=0
tunnel.10.option.maxTotalPosts=0
tunnel.10.option.outbound.backupQuantity=0
tunnel.10.option.outbound.length=3
tunnel.10.option.outbound.lengthVariance=0
tunnel.10.option.outbound.nickname=owncloud server
tunnel.10.option.outbound.quantity=2
tunnel.10.option.outbound.randomKey=xPyC-Y3Voh5MznimTaS00rVP2v74khpLEDI5fikPoO8=
tunnel.10.option.postBanTime=1800
tunnel.10.option.postCheckTime=300
tunnel.10.option.postTotalBanTime=600
tunnel.10.option.rejectInproxy=false
tunnel.10.option.rejectReferer=false
tunnel.10.option.rejectUserAgents=false
tunnel.10.option.shouldBundleReplyInfo=false
tunnel.10.option.useSSL=false
tunnel.10.privKeyFile=i2ptunnel10-privKeys.dat
tunnel.10.spoofedHost=owncloud.i2p
tunnel.10.startOnLoad=true
tunnel.10.targetHost=10.0.0.253
tunnel.10.targetPort=80
tunnel.10.type=httpserver
tunnel.11.description=mailpile
tunnel.11.name=mailpile server
tunnel.11.option.enableUniqueLocal=false
tunnel.11.option.i2cp.destination.sigType=1
tunnel.11.option.i2cp.enableAccessList=false
tunnel.11.option.i2cp.enableBlackList=false
tunnel.11.option.i2cp.encryptLeaseSet=false
tunnel.11.option.i2cp.reduceIdleTime=1200000
tunnel.11.option.i2cp.reduceOnIdle=false
tunnel.11.option.i2cp.reduceQuantity=1
tunnel.11.option.i2p.streaming.connectDelay=0
tunnel.11.option.i2p.streaming.maxConcurrentStreams=0
tunnel.11.option.i2p.streaming.maxConnsPerDay=0
tunnel.11.option.i2p.streaming.maxConnsPerHour=0
tunnel.11.option.i2p.streaming.maxConnsPerMinute=0
tunnel.11.option.i2p.streaming.maxTotalConnsPerDay=0
tunnel.11.option.i2p.streaming.maxTotalConnsPerHour=0
tunnel.11.option.i2p.streaming.maxTotalConnsPerMinute=0
tunnel.11.option.inbound.backupQuantity=0
tunnel.11.option.inbound.length=3
tunnel.11.option.inbound.lengthVariance=0
tunnel.11.option.inbound.nickname=mailpile server
tunnel.11.option.inbound.quantity=2
tunnel.11.option.inbound.randomKey=YlziI03Dh95j5lGlVzXjQehxMq913sDiSlgihQVJSiI=
tunnel.11.option.maxPosts=0
tunnel.11.option.maxTotalPosts=0
tunnel.11.option.outbound.backupQuantity=0
tunnel.11.option.outbound.length=3
tunnel.11.option.outbound.lengthVariance=0
tunnel.11.option.outbound.nickname=mailpile server
tunnel.11.option.outbound.quantity=2
tunnel.11.option.outbound.randomKey=xPyC-Y3Voh5MznimTaS00rVP2v74khpLEDI5fikPoO8=
tunnel.11.option.postBanTime=1800
tunnel.11.option.postCheckTime=300
tunnel.11.option.postTotalBanTime=600
tunnel.11.option.rejectInproxy=false
tunnel.11.option.rejectReferer=false
tunnel.11.option.rejectUserAgents=false
tunnel.11.option.shouldBundleReplyInfo=false
tunnel.11.option.useSSL=false
tunnel.11.privKeyFile=i2ptunnel11-privKeys.dat
tunnel.11.spoofedHost=mailpile.i2p
tunnel.11.startOnLoad=true
tunnel.11.targetHost=10.0.0.254
tunnel.11.targetPort=80
tunnel.11.type=httpserver
EOF

# Setting permissions
chown i2psvc:i2psvc /var/lib/i2p/i2p-config/i2ptunnel.config
chmod 600 /var/lib/i2p/i2p-config/i2ptunnel.config

# Restarting i2p
service i2p restart

LOOP_S=0
LOOP_N=0
echo "Configuring i2p hidden services ..."
while [ $LOOP_S -lt 1 ]
do
if [ `ls /var/lib/i2p/i2p-config/i2ptunnel-keyBackup/ 2>/dev/null | wc -l` -eq 6 ]; then
echo "i2p successfully configured"
LOOP_S=1
else
sleep 1
LOOP_N=$((LOOP_N + 1))
fi
# Wail up to 120 s for tor hidden services to become available
if [ $LOOP_N -eq 120 ]; then
echo "Error: Unable to configure i2p. Exiting ..."
exit 1
fi
done

}


# ---------------------------------------------------------
# Function to configure Unbound DNS server
# ---------------------------------------------------------
configure_unbound() 
{
echo '# Unbound configuration file for Debian.
#
# See the unbound.conf(5) man page.
#
# See /usr/share/doc/unbound/examples/unbound.conf for a commented
# reference config file.

server:
# The following line will configure unbound to perform cryptographic
# DNSSEC validation using the root trust anchor.

# Specify the interface to answer queries from by ip address.
interface: 10.0.0.1

# Port to answer queries
port: 53

# Serve ipv4 requests
do-ip4: yes

# Serve ipv6 requests
do-ip6: no

# Enable UDP
do-udp: yes

# Enable TCP
do-tcp: yes

# Not to answer id.server and hostname.bind queries
hide-identity: yes

# Not to answer version.server and version.bind queries
hide-version: yes

# Use 0x20-encoded random bits in the query 
use-caps-for-id: yes

# Cache minimum time to live
Cache-min-ttl: 3600

# Cache maximum time to live
cache-max-ttl: 86400

# Perform prefetching
prefetch: yes

# Number of threads 
num-threads: 2

## Unbound optimization ##

# Number od slabs
msg-cache-slabs: 4
rrset-cache-slabs: 4
infra-cache-slabs: 4
key-cache-slabs: 4

# Size pf cache memory
rrset-cache-size: 128m
msg-cache-size: 64m

# Buffer size for UDP port 53
so-rcvbuf: 1m

# Unwanted replies maximum number
unwanted-reply-threshold: 10000

# Define which network ips are allowed to make queries to this server.
access-control: 10.0.0.0/8 allow
access-control: 127.0.0.1/8 allow
access-control: 0.0.0.0/0 refuse

# Configure DNSSEC validation
# librenet, onion and i2p domains are not checked for DNSSEC validation
#    auto-trust-anchor-file: "/var/lib/unbound/root.key"
do-not-query-localhost: no
#    domain-insecure: "librenet"
#    domain-insecure: "onion"
#    domain-insecure: "i2p"

#Local destinations
local-zone: "librenet" static
local-data: "librerouter.librenet. IN A 10.0.0.1"
local-data: "i2p.librenet. IN A 10.0.0.1"
local-data: "tahoe.librenet. IN A 10.0.0.1"
local-data: "ntop.librenet. IN A 10.0.0.244"
local-data: "webmin.librenet. IN A 10.0.0.245"
local-data: "kibana.librenet. IN A 10.0.0.11"
local-data: "snorby.librenet. IN A 10.0.0.12"
local-data: "conference.librerouter.net. IN A 10.0.0.250"
local-data: "search.librerouter.net. IN A 10.0.0.251"
local-data: "social.librerouter.net. IN A 10.0.0.252"
local-data: "storage.librerouter.net. IN A 10.0.0.253"
local-data: "email.librerouter.net. IN A 10.0.0.254"
local-data: "squidguard.librenet. IN A 10.0.0.246"' > /etc/unbound/unbound.conf

for i in $(ls /var/lib/tor/hidden_service/)
do
if [ $i == "easyrtc" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.250\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "yacy" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.251\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "friendica" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.252\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "owncloud" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.253\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "mailpile" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.254\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "gitlab" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.247\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "trac" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.248\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "redmine" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.249\"" \
>> /etc/unbound/unbound.conf
fi
if [ $i == "ssh" ]; then
echo "local-data: \"$i.librenet. IN A 10.0.0.1\"" \
>> /etc/unbound/unbound.conf
fi
done

for i in $(ls /var/lib/tor/hidden_service/)
do
hn="$(cat /var/lib/tor/hidden_service/$i/hostname 2>/dev/null )"
if [ -n "$hn" ]; then
echo "local-zone: \"$hn.\" static" >> /etc/unbound/unbound.conf
if [ $i == "easyrtc" ]; then
echo "local-data: \"$hn. IN A 10.0.0.250\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "yacy" ]; then
echo "local-data: \"$hn. IN A 10.0.0.251\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "friendica" ]; then
echo "local-data: \"$hn. IN A 10.0.0.252\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "owncloud" ]; then
echo "local-data: \"$hn. IN A 10.0.0.253\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "mailpile" ]; then
echo "local-data: \"$hn. IN A 10.0.0.254\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "gitlab" ]; then
echo "local-data: \"$hn. IN A 10.0.0.247\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "trac" ]; then
echo "local-data: \"$hn. IN A 10.0.0.248\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "redmine" ]; then
echo "local-data: \"$hn. IN A 10.0.0.249\"" >> /etc/unbound/unbound.conf
fi
if [ $i == "ssh" ]; then
echo "local-data: \"$hn. IN A 10.0.0.1\"" >> /etc/unbound/unbound.conf
fi
fi
done

echo '
# I2P domains will be resolved us 10.191.0.1 
local-zone: "i2p." redirect
local-data: "i2p. IN A 10.191.0.1"

# Include social networks domains list configuration
include: /etc/unbound/socialnet_domain.list.conf

# Include search engines domains list configuration
include: /etc/unbound/searchengines_domain.list.conf

# Include webmail domains list configuration
include: /etc/unbound/webmail_domain.list.conf

# Include chat domains list configuration
include: /etc/unbound/chat_domain.list.conf

# Include storage domains list configuration
include: /etc/unbound/storage_domain.list.conf

# Include block domains list configuration
include: /etc/unbound/block_domain.list.conf

# .ounin domains will be resolved by TOR DNS 
forward-zone:
name: "onion"
forward-addr: 127.0.0.1@9053

# Forward rest of zones to DjDNS
forward-zone:
name: "."
forward-addr: 8.8.8.8@53

' >> /etc/unbound/unbound.conf

# Extracting classified domain list package
echo "Extracting files ..."
tar -xf shallalist.tar.gz
if [ $? -ne 0 ]; then
echo "Error: Unable to extract domains list. Exithing"
exit 6
fi

# Configuring social network domains list
echo "Configuring domain list ..."
find BL/socialnet -name domains -exec cat {} \; > socialnet_domain.list
find BL/searchengines -name domains -exec cat {} \; > searchengines_domain.list
find BL/webmail -name domains -exec cat {} \; > webmail_domain.list
find BL/chat -name domains -exec cat {} \; > chat_domain.list
find BL/downloads -name domains -exec cat {} \; > storage_domain.list
find BL/spyware -name domains -exec cat {} \; > block_domain.list
find BL/redirector -name domains -exec cat {} \; >> block_domain.list
find BL/tracker -name domains -exec cat {} \; >> block_domain.list

# Deleting old files
rm -rf shallalist 	

# Creating chat domains list configuration file
cat chat_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.250\""'} \
> /etc/unbound/chat_domain.list.conf
cat chat_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.250\""'} \
>> /etc/unbound/chat_domain.list.conf

# Adding skype to chat domain list
echo "local-data: \"skype.com IN A 10.0.0.250\"
local-data: \"www.skype.com IN A 10.0.0.250\"
" >> /etc/unbound/chat_domain.list.conf

# Creating search engines domains list configuration file
cat searchengines_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.251\""'} \
> /etc/unbound/searchengines_domain.list.conf
cat searchengines_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.251\""'} \
>> /etc/unbound/searchengines_domain.list.conf

# Creating social networks domains list configuration file
cat socialnet_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.252\""'} \
> /etc/unbound/socialnet_domain.list.conf
cat socialnet_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.252\""'} \
>> /etc/unbound/socialnet_domain.list.conf

# Creating storage domains list configuration file
cat storage_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.253\""'} \
> /etc/unbound/storage_domain.list.conf
cat storage_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.253\""'} \
>> /etc/unbound/storage_domain.list.conf

# Creating  webmail domains list configuration file
cat webmail_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.254\""'} \
> /etc/unbound/webmail_domain.list.conf
cat webmail_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.254\""'} \
>> /etc/unbound/webmail_domain.list.conf

# Creating  block domains list configuration file
cat block_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.245\""'} \
> /etc/unbound/block_domain.list.conf
cat block_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.245\""'} \
>> /etc/unbound/block_domain.list.conf

# Deleting old files
rm -rf socialnet_domain.list
rm -rf searchengines_domain.list
rm -rf webmail_domain.list
rm -rf chat_domain.list
rm -rf storage_domain.list
rm -rf block_domain.list

# Updating DNSSEC root trust anchor
unbound-anchor -a "/var/lib/unbound/root.key"

# There is a need to stop dnsmasq before starting unbound
echo "Stoping dnsmasq ..."
if ps aux | grep -w "dnsmasq" | grep -v "grep" > /dev/null;   then
kill -9 `ps aux | grep dnsmasq | awk {'print $2'} | sed -n '1p'`
fi

#     echo "
#	# Stopping dnsmasq
#	kill -9 \`ps aux | grep dnsmasq | awk {'print \$2'} | sed -n '1p'\` \
#	2> /dev/null
#	" >> /etc/rc.local
#
#	echo "service unbound restart" >> /etc/rc.local

echo "Starting Unbound DNS server ..."
service unbound restart
if ps aux | grep -w "unbound" | grep -v "grep" > /dev/null; then
echo "Unbound DNS server successfully started."
else
echo "Error: Unable to start unbound DNS server. Exiting"
exit 3
fi
}


# ---------------------------------------------------------
# Function to configure Friendica local service
# ---------------------------------------------------------
configure_friendica()
{
echo "Configuring Friendica local service ..."
if [ ! -e  /var/lib/mysql/frnd ]; then

# Defining MySQL user and password variables
# MYSQL_PASS="librerouter"
MYSQL_USER="root"

# Creating MySQL database frnd for friendica local service
echo "CREATE DATABASE frnd;" \
| mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" 
fi

# Inserting friendica database
sed -i  s/utf8mb4/utf8/g /var/www/friendica/database.sql
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" frnd < /var/www/friendica/database.sql

if [ -z "$(grep "friendica/include/poller" /etc/crontab)" ]; then
echo '*/10 * * * * /usr/bin/php /var/www/friendica/include/poller.php' >> /etc/crontab
fi

# Creating friendica configuration
echo "
<?php

\$db_host = 'localhost';
\$db_user = 'root';
\$db_pass = '$MYSQL_PASS';
\$db_data = 'frnd';

\$a->path = '';
\$default_timezone = 'America/Los_Angeles';
\$a->config['sitename'] = \"My Friend Network\";
\$a->config['register_policy'] = REGISTER_OPEN;
\$a->config['register_text'] = '';
\$a->config['admin_email'] = 'admin@librerouter.com';
\$a->config['max_import_size'] = 200000;
\$a->config['system']['maximagesize'] = 800000;
\$a->config['php_path'] = '/usr/bin/php';
\$a->config['system']['huburl'] = '[internal]';
\$a->config['system']['rino_encrypt'] = true;
\$a->config['system']['theme'] = 'duepuntozero';
\$a->config['system']['no_regfullname'] = true;
\$a->config['system']['directory'] = 'http://dir.friendi.ca';
" > /var/www/friendica/.htconfig.php

}


# ---------------------------------------------------------
# Function to configure EasyRTC local service
# ---------------------------------------------------------
configure_easyrtc()
{
echo "Starting EasyRTC local service ..."
if [ ! -e /opt/easyrtc/server_example/server.js ]; then
echo "Can not find EasyRTC server confiugration. Exiting ..."
exit 4
fi

cat << EOF > /opt/easyrtc/server_example/server.js 
// Load required modules
var https    = require("https");              // http server core module
var express = require("express");           // web framework external module
var serveStatic = require('serve-static');  // serve static files
var socketIo = require("socket.io");        // web socket external module
var easyrtc = require("../");               // EasyRTC external module
var fs = require("fs");

// Set process name
process.title = "node-easyrtc";

// Setup and configure Express http server. Expect a subfolder called "static" to be the web root.
var app = express();
app.use(serveStatic('static', {'index': ['index.html']}));

// Start Express http server on port 8443
var webServer = https.createServer(
{
key:  fs.readFileSync("/etc/ssl/nginx/easyrtc.key"),
cert: fs.readFileSync("/etc/ssl/nginx/easyrtc.crt")
},
app).listen(8443);

// Start Socket.io so it attaches itself to Express server
var socketServer = socketIo.listen(webServer, {"log level":1});

easyrtc.setOption("logLevel", "debug");

// Overriding the default easyrtcAuth listener, only so we can directly access its callback
easyrtc.events.on("easyrtcAuth", function(socket, easyrtcid, msg, socketCallback, callback) {
easyrtc.events.defaultListeners.easyrtcAuth(socket, easyrtcid, msg, socketCallback, function(err, connectionObj){
if (err || !msg.msgData || !msg.msgData.credential || !connectionObj) {
    callback(err, connectionObj);
    return;
}

connectionObj.setField("credential", msg.msgData.credential, {"isShared":false});

console.log("["+easyrtcid+"] Credential saved!", connectionObj.getFieldValueSync("credential"));

callback(err, connectionObj);
});
});

// To test, lets print the credential to the console for every room join!
easyrtc.events.on("roomJoin", function(connectionObj, roomName, roomParameter, callback) {
console.log("["+connectionObj.getEasyrtcid()+"] Credential retrieved!", connectionObj.getFieldValueSync("credential"));
easyrtc.events.defaultListeners.roomJoin(connectionObj, roomName, roomParameter, callback);
});

// Start EasyRTC server
var rtc = easyrtc.listen(app, socketServer, null, function(err, rtcRef) {
console.log("Initiated");

rtcRef.events.on("roomCreate", function(appObj, creatorConnectionObj, roomName, roomOptions, callback) {
console.log("roomCreate fired! Trying to create: " + roomName);

appObj.events.defaultListeners.roomCreate(appObj, creatorConnectionObj, roomName, roomOptions, callback);
});
});

//listen on port 8443
webServer.listen(8443, function () {
console.log('listening on http://localhost:8443');
});
EOF

# sed -i '/function connect() {/a easyrtc.setSocketUrl(":8443");' /opt/easyrtc/node_modules/easyrtc/demos/js/*.js

cd /opt/easyrtc/server_example

# Starting EasyRTC server
nohup nodejs server &

echo ""
cd
}


# ---------------------------------------------------------
# Function to configure Owncloud local service 
# ---------------------------------------------------------
configure_owncloud()
{
echo "Configuring Owncloud local service ..."

# Getting owncloud onion service name
SERVER_OWNCLOUD="$(cat /var/lib/tor/hidden_service/owncloud/hostname 2>/dev/null)"

# Getting owncloud files in web server root directory
#if [ ! -e  /var/www/owncloud ]; then
#if [ -e /ush/share/owncloud ]; then
#cp -r /usr/share/owncloud /var/www/owncloud
#else
#if [ -e /opt/owncloud ]; then
#cp -r /opt/owncloud /var/www/owncloud
#fi
#fi
#fi

chown -R www-data /var/www/owncloud

# owncloud configuration
cat << EOF > /var/www/owncloud/config/config.php 
<?php
\$CONFIG = array (
'trusted_domains' => 
array (
0 => 'owncloud.librenet',
1 => '$SERVER_OWNCLOUD',
2 => '$SERVER_OWNCLOUD.to',
),
);
EOF

# Setting permissions
chmod -R a+rw /var/www/owncloud/config/

# ojsxc app configuration
sed -i "34iexec(\'.\/configs.sh\');" /var/www/owncloud/index.php

echo "
#!/bin/bash
php5 occ app:enable ojsxc 
php occ config:app:set ojsxc installed_version --value=\"3.0.1\"
php occ config:app:set ojsxc ocsid --value=\"162257\"
php occ config:app:set ojsxc types --value=\"prelogin\"
php occ config:app:set ojsxc enabled --value=\"yes\"
php occ config:app:set ojsxc serverType --value=\"internal\"
#sudo -u www-data php occ config:app:set ojsxc boshUrl --value=\"\"
#sudo -u www-data php occ config:app:set ojsxc xmppDomain --value=\"\"
#sudo -u www-data php occ config:app:set ojsxc xmppResource --value=\"\"
php occ config:app:set ojsxc xmppOverwrite --value=\"false\"
php occ config:app:set ojsxc xmppStartMinimized --value=\"false\"
#sudo -u www-data php occ config:app:set ojsxc iceUrl --value=\"\"
#sudo -u www-data php occ config:app:set ojsxc iceUsername --value=\"\"
#sudo -u www-data php occ config:app:set ojsxc iceCredential --value=\"\"
#sudo -u www-data php occ config:app:set ojsxc iceSecret --value=\"\"
#sudo -u www-data php occ config:app:set ojsxc iceTtl --value=\"\"
" > /var/www/owncloud/configs.sh

# Setting permissions
chmod 777 /var/www/owncloud/configs.sh
}


# ---------------------------------------------------------
# Function to configure Privoxy
# --------------------------------------------------------
configure_privoxy()
{
/etc/init.d/privoxy stop
rm -f /etc/rc?.d/*privoxy*

#Privoxy I2P

cat << EOF > /etc/privoxy/config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action # Actions that are applied to all sites and maybe overruled later on.
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
filterfile user.filter      # User customizations
logfile logfile
listen-address  127.0.0.1:8118
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
forward .i2p 127.0.0.1:4444
EOF

#Privoxy TOR

cat << EOF > /etc/privoxy/config-tor 
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
logfile logfile
user-manual /usr/share/doc/privoxy/user-manual
listen-address 127.0.0.1:8119
toggle 0
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
forward-socks5t / 127.0.0.1:9050 .
max-client-connections 4096
EOF

cp /etc/init.d/privoxy /etc/init.d/privoxy-tor
sed "s~Provides:.*~Provides:          privoxy-tor~g" -i  /etc/init.d/privoxy-tor
sed "s~PIDFILE=.*~PIDFILE=/var/run/\$NAME-tor.pid~g" -i  /etc/init.d/privoxy-tor
sed "s~CONFIGFILE=.*~CONFIGFILE=/etc/privoxy/config-tor~g" -i /etc/init.d/privoxy-tor
sed "s~SCRIPTNAME=.*~SCRIPTNAME=/etc/init.d/\$NAME-tor~g" -i /etc/init.d/privoxy-tor

update-rc.d privoxy-tor defaults

echo "Restarting privoxy-tor ..."
service privoxy-tor restart

echo "Restarting privoxy-i2p ..."
service privoxy restart

}


# ---------------------------------------------------------
# Function to configure squid
# ---------------------------------------------------------
configure_squid()
{
echo "Configuring squid server ..."

# Generating certificates for ssl connection
echo "Generating certificates ..."
if [ ! -e /etc/squid/ssl_cert ]; then
mkdir /etc/squid/ssl_cert
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509  \
-keyout /etc/squid/ssl_cert/squid.key \
-out /etc/squid/ssl_cert/squid.crt -batch
chown -R proxy:proxy /etc/squid/ssl_cert
chmod -R 777 /etc/squid/ssl_cert
fi

echo "Creating log directory for Squid..."
rm -rf mkdir /var/log/squid
mkdir /var/log/squid
chown -R proxy:proxy /var/log/squid
chmod -R 777 /var/log/squid

echo "Calling Squid to create swap directories and initialize cert cache dir..."
squid -z
if [ -d "/var/cache/squid/ssl_db" ]; then
rm -rf /var/cache/squid/ssl_db
fi
/lib/squid/ssl_crtd -c -s /var/cache/squid/ssl_db
chown -R proxy:proxy /var/cache/squid/ssl_db
chmod -R 777 /var/cache/squid/ssl_db

# squid configuration
echo "Creating squid conf file ..."
echo "
acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT
acl librenetwork src 10.0.0.0/24
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localhost
http_access allow librenetwork
http_access deny all

# squidGuard configuration
url_rewrite_program /usr/bin/squidGuard -c /etc/squidguard/squidGuard.conf

# http configuration
http_port 10.0.0.1:3130 intercept
coredump_dir /var/spool/squid

# https configuration
https_port 10.0.0.1:3131 intercept ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=/etc/squid/ssl_cert/squid.crt key=/etc/squid/ssl_cert/squid.key
always_direct allow all

# SSL Proxy options
ssl_bump server-first all
sslproxy_cert_error allow all
sslproxy_cert_adapt setCommonName ssl::certDomainMismatch
sslproxy_options ALL,SINGLE_DH_USE,NO_SSLv3,NO_SSLv2 

# Refresh patterns
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\\?) 0     0%      0
refresh_pattern .               0       20%     4320

# sslcrtd configuration
sslcrtd_program /lib/squid/ssl_crtd -s /var/cache/squid/ssl_db -M 4MB
sslcrtd_children 5

# icap configuration
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_encode off
icap_client_username_header X-Authenticated-User
icap_preview_enable on
icap_preview_size 1024
icap_service icap_service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access icap_service_req allow all
icap_service icap_service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
#adaptation_access icap_service_resp allow all

# ecap configuration
loadable_modules /usr/local/lib/libreqmod.so
loadable_modules /usr/local/lib/librespmod.so
ecap_enable on
ecap_service ecap_service_req reqmod_precache bypass=on ecap://filtergizmo.com/ecapguardian/reqmod ecapguardian_listen_socket=/etc/ecapguardian/ecap/reqmod
adaptation_access ecap_service_req allow all
ecap_service ecap_service_resp respmod_precache bypass=on ecap://filtergizmo.com/ecapguardian/respmod ecapguardian_listen_socket=/etc/ecapguardian/ecap/respmod
#adaptation_access ecap_service_resp allow all

adaptation_service_chain myChain ecap_service_resp icap_service_resp
adaptation_access myChain allow all
" > /etc/squid/squid.conf

echo "Configuring squid startup file ..."
if [ ! -e /etc/squid/squid3.rc ]; then
echo "Could not find squid srartup script. Exiting ..."
exit 8
else
rm -rf /etc/init.d/squid*
cp /etc/squid/squid3.rc /etc/init.d/squid
sed "s~Provides:.*~Provides:          squid~g" -i  /etc/init.d/squid
sed "s~NAME=.*~NAME=squid~g" -i  /etc/init.d/squid
sed "s~DAEMON=.*~DAEMON=/usr/sbin/squid~g" -i  /etc/init.d/squid
sed "s~PIDFILE=.*~PIDFILE=/var/run/squid.pid~g" \
-i  /etc/init.d/squid
sed "s~CONFIG=.*~CONFIG=/etc/squid/squid.conf~g" \
-i /etc/init.d/squid
chmod +x /etc/init.d/squid
fi

update-rc.d squid start defaults
echo "Restarting squid server ..."
service squid restart

# squid TOR

echo "Creating squid-tor conf file ..."
cat << EOF > /etc/squid/squid-tor.conf 
# Tor acl
acl tor_url dstdomain .onion

# Privoxy+Tor access rules 
never_direct allow tor_url

# Local Privoxy is cache parent 
cache_peer 127.0.0.1 parent 8119 0 no-query no-digest default

cache_peer_access 127.0.0.1 allow tor_url
cache_peer_access 127.0.0.1 deny all

#acl manager proto cache_object
acl localhost src 127.0.0.1/32 
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 

acl localnet src 10.0.0.0/8     # RFC1918 possible internal network

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

http_access allow localnet
http_access allow localhost
http_access allow all
http_access deny all

#http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access deny all

http_port 3129 accel vhost allow-direct

hierarchy_stoplist cgi-bin ?

never_direct allow all

cache_store_log none

pid_filename /var/run/squid-tor.pid

cache_log /var/log/squid/cache.log

coredump_dir /var/spool/squid

#url_rewrite_program /usr/bin/squidGuard

no_cache deny all

# icap configuration
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_encode off
icap_client_username_header X-Authenticated-User
icap_preview_enable on
icap_preview_size 1024
icap_service service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_req allow all
icap_service service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_resp allow all
EOF

echo "Configuring squid-tor startup file ..."
cp /etc/init.d/squid /etc/init.d/squid-tor
sed "s~Provides:.*~Provides:          squid-tor~g" -i  /etc/init.d/squid-tor
sed "s~PIDFILE=.*~PIDFILE=/var/run/squid-tor.pid~g" -i  /etc/init.d/squid-tor
sed "s~CONFIG=.*~CONFIG=/etc/squid/squid-tor.conf~g" -i /etc/init.d/squid-tor

update-rc.d squid-tor start defaults
echo "Restarting squid-tor ..."
service squid-tor restart

#Squid I2P

echo "Creating squid-i2p conf file ..."
cat << EOF > /etc/squid/squid-i2p.conf
cache_peer 127.0.0.1 parent 8118 7 no-query no-digest

#acl manager proto cache_object
acl localhost src 127.0.0.1/32 
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 

acl localnet src 10.0.0.0/8     # RFC1918 possible internal network

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

http_access allow localnet
http_access allow localhost
http_access allow all
http_access deny all

http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access deny all

http_port 3128 accel vhost allow-direct

hierarchy_stoplist cgi-bin ?

never_direct allow all

cache_store_log none

pid_filename /var/run/squid-i2p.pid

cache_log /var/log/squid/cache.log

coredump_dir /var/spool/squid

#url_rewrite_program /usr/bin/squidGuard

no_cache deny all

# icap configuration
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_encode off
icap_client_username_header X-Authenticated-User
icap_preview_enable on
icap_preview_size 1024
icap_service service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_req allow all
icap_service service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_resp allow all
EOF

echo "Configuring squid-i2p startup file ..."
cp /etc/init.d/squid /etc/init.d/squid-i2p
sed "s~Provides:.*~Provides:          squid-i2p~g" -i  /etc/init.d/squid-i2p
sed "s~PIDFILE=.*~PIDFILE=/var/run/squid-i2p.pid~g" -i  /etc/init.d/squid-i2p
sed "s~CONFIG=.*~CONFIG=/etc/squid/squid-i2p.conf~g" -i /etc/init.d/squid-i2p

update-rc.d squid-i2p start defaults
echo "Restarting squid-i2p ..."
service squid-i2p restart
}


# ---------------------------------------------------------
# Function to configure c-icap
# ---------------------------------------------------------
configure_c_icap()
{
echo "Configuring c-icap ..."

# Making c-icap daemon run automatically on startup
echo "
# Defaults for c-icap initscript
# sourced by /etc/init.d/c-icap
# installed at /etc/default/c-icap by the maintainer scripts

# Should c-icap daemon run automatically on startup? (default: no)
START=yes

# Additional options that are passed to the Daemon.
DAEMON_ARGS=\"\"
" > /etc/default/c-icap

# c-icap configuration
echo "
PidFile /var/run/c-icap/c-icap.pid
CommandsSocket /var/run/c-icap/c-icap.ctl
Timeout 300
MaxKeepAliveRequests 100
KeepAliveTimeout 600
StartServers 3
MaxServers 10
MinSpareThreads     10
MaxSpareThreads     20
ThreadsPerChild     10
MaxRequestsPerChild  0
Port 1344
User c-icap
Group c-icap
ServerAdmin admin@librerouter.com
ServerName librerouter
TmpDir /tmp
MaxMemObject 131072
DebugLevel 1
TemplateDir /usr/share/c_icap/templates/
TemplateDefaultLanguage en
LoadMagicFile /etc/c-icap/c-icap.magic
RemoteProxyUsers off
RemoteProxyUserHeader X-Authenticated-User
RemoteProxyUserHeaderEncoded on
ServerLog /var/log/c-icap/server.log
AccessLog /var/log/c-icap/access.log
Service squidclamav squidclamav.so
Service echo srv_echo.so
" > /etc/c-icap/c-icap.conf

# Modules directory in Intel
if [ "$PROCESSOR" = "Intel" ]; then
echo "
ModulesDir /usr/lib/x86_64-linux-gnu/c_icap
ServicesDir /usr/lib/x86_64-linux-gnu/c_icap
" >> /etc/c-icap/c-icap.conf
fi

# Modules directory in ARM
if [ "$PROCESSOR" = "ARM" ]; then
echo "
ModulesDir /usr/lib/arm-linux-gnueabihf/c_icap
ServicesDir /usr/lib/arm-linux-gnueabihf/c_icap
" >> /etc/c-icap/c-icap.conf
fi

echo "Restarting c-icap service ..."
service c-icap restart
}


# ---------------------------------------------------------
# Function to configure squidclamav
# ---------------------------------------------------------
configure_squidclamav()
{
echo "Configuring squidclamav ..."
echo "
maxsize 5000000
redirect http://librerouter.librenet/virus_warning_page.html
clamd_local /var/run/clamav/clamd.ctl
#clamd_ip 10.0.0.1,127.0.0.1
#clamd_port 3310
timeout 1
logredir 0
dnslookup 1
safebrowsing 0
" > /etc/squidclamav.conf

echo "Restarting clamav daemon ..."
service clamav-daemon restart
}


# ---------------------------------------------------------
# Function to configure squidguard
# ---------------------------------------------------------
configure_squidguard()
{

echo "Configuring squidguard ..."

mkdir -p /etc/squidguard

# log file
touch /var/log/squidguard/squidGuard.log
chmod a+rw /var/log/squidguard/squidGuard.log

# Coniguration file
cat << EOF > /etc/squidguard/squidGuard.conf
#
# CONFIG FILE FOR SQUIDGUARD
#

dbhome /usr/local/squidGuard/db/blacklists
logdir /usr/local/squidGuard/logs

dest ads {
domainlist ads/domains
urllist ads/urls
}

dest proxy {
domainlist proxy/domains
urllist proxy/urls
}

dest spyware {
domainlist spyware/domains
urllist spyware/urls
}

dest redirector {
domainlist redirector/domains
urllist redirector/urls
}

dest suspect {
domainlist suspect/domains
urllist suspect/urls
}

# Access control 
acl {
default {
	pass !ads !proxy !spyware !redirector !suspect all
	redirect http://librerouter.librenet/squidguard_warning_page.html
}
}
EOF

squidGuard -C all
chmod -R a+rw /usr/local/squidGuard/db/*
}


# ---------------------------------------------------------
# Function to configure squidguardmgr
# ---------------------------------------------------------
configure_squidguardmgr()
{
# uwcgi configuretion
cat << EOF > /etc/uwsgi/uwsgi.ini
[uwsgi]
plugins = cgi
threads = 20
socket = 127.0.0.1:9000
cgi=/var/www/squidguardmgr 
cgi-allowed-ext = .cgi
EOF

}


# ---------------------------------------------------------
# Function to configure ecapguardian
# ---------------------------------------------------------
configure_ecapguardian()
{

echo "Configuring ecapguardian ..."

# Creating user
useradd e2guardian

# Creating log file
touch /var/log/ecapguardian/access.log
chmod a+rw /var/log/ecapguardian/access.log

# Creating socket directory
mkdir -p /etc/ecapguardian/ecap

# Running e2guardian
ecapguardian &

# Setting sockets permissions 
chmod -R a+rw /etc/ecapguardian/ecap

# Preparing files 
rm -rf /root/libre_scripts/
mkdir /root/libre_scripts/
touch /root/libre_scripts/ecapguardian.sh
chmod +x /root/libre_scripts/ecapguardian.sh

cat << EOF > /root/libre_scripts/ecapguardian.sh
#!/bin/bash
sleep 60
/usr/sbin/ecapguardian &
sleep 30
chmod -R a+rwx /etc/ecapguardian/ecap
EOF

# Creating cron job
rm -rf /root/libre_scripts/cron_jobs
echo "@reboot /root/libre_scripts/ecapguardian.sh" > /root/libre_scripts/cron_jobs
crontab /root/libre_scripts/cron_jobs
}


# ---------------------------------------------------------
# Function to configure postfix mail service
# ---------------------------------------------------------
configure_postfix()
{
# Configurinf postfix mail service
echo "Configuring postfix ..."

echo "
mtpd_banner = \$myhostname ESMTP \$mail_name (Debian/GNU)
biff = no
append_dot_mydomain = no 
readme_directory = no
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = librerouter.librenet
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = librerouter.librenet, localhost.librenet, localhost
relayhost =
mynetworks = 127.0.0.0/8, 10.0.0.0/24
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
" > /etc/postfix/main.cf

echo "Restarting postfix ..."
service postfix restart
}


# ---------------------------------------------------------
# Function to configura trac server
# ---------------------------------------------------------
configure_trac() 
{
# trac can only be installed on x86_64 (64 bit) architecture
# So we configure it if architecture is x86_64
if [ "$ARCH" == "x86_64" ]; then
        echo "Configuring Trac ..."
	rm -rf /opt/trac/libretrac
        mkdir -p /opt/trac/libretrac

        # Initializing trac project
        trac-admin /opt/trac/libretrac initenv LibreProject sqlite:db
	if [ $? -ne 0 ]; then
        	echo "Unable to configure trac. Exiting ..."
       		exit 1
	fi
	   
        # Setting permissions
        chown -R www-data:www-data /opt/trac/libretrac

	export LC_ALL=en_US.UTF-8
	kill -9 `netstat -tulpn | grep 8000 | awk '{print $7}' | awk -F/ '{print $1}'` 2> /dev/null	
        tracd -s -b 127.0.0.1 --port 8000 /opt/trac/libretrac &
else
        echo "Trac configuration is skipped as detected architecture: $ARCH"
fi
}


# ---------------------------------------------------------
# Function to configure redmine
# ---------------------------------------------------------
configure_redmine()
{
        echo "Configuring redmine ..."

        # Preparing MySQL
        MYSQL_USER="root"
	echo "CREATE DATABASE redmine CHARACTER SET utf8;" \
	| mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" > /dev/null 2>&1
        #CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'my_password';
        #GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';
        #exit

        # Redmine DB configuration
        cd /opt/redmine/redmine-3.3.1
        cp config/database.yml.example config/database.yml
	cp config/configuration.yml.example config/configuration.yml

	# Run bundle
	bundle install --without development test rmagick

	# Creating thin configuration
	echo "
pid: /var/run/thin.pid
timeout: 30
wait: 30
log: /var/log/thin.log
max_conns: 1024
environment: production
max_persistent_conns: 512
servers: 1
threaded: true
no-epoll: true
daemonize: true
chdir: /opt/redmine/redmine-3.3.1
" > /etc/thin2.1/config.yml 
	
        # Customize DB configuration
echo "
production:
  adapter: mysql2
  database: redmine
  host: localhost
  username: root
  password: "$MYSQL_PASS"
  encoding: utf8

#development:
#  adapter: mysql2
#  database: redmine
#  host: localhost
#  username: root
#  password: "$MYSQL_PASS"
#  encoding: utf8
" > config/database.yml

	# Migrate database and load default settings
	RAILS_ENV=production bundle exec rake db:migrate
	RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data

	# Start thin server
	thin -c /opt/redmine/redmine-3.3.1 --servers 1 -e production -a 127.0.0.1 -p 8889 -d star

        # Link the redmine public dir to the nginx-redmine root:
        # ln -s /opt/redmine/redmine-3.3.1/public/ /var/www/html/redmine
}


# ---------------------------------------------------------
# Function to configure ntop
# ---------------------------------------------------------
configure_ntopng()
{
	echo "configuring ntopng ..."

	# Interface configuretion
	# sed -i 's/INTERFACES="none"/INTERFACES="$EXT_INTERFACE"/g' /var/lib/ntop/init.cfg

	# Creating configuration file
	rm -rf /etc/ntopng/ntopng.conf
	touch /etc/ntopng/ntopng.conf
	echo "
#--user ntop
#--daemon
#--db-file-path /usr/share/ntop
#--interface $EXT_INTERFACE
#-p /etc/ntop/protocol.list 
#? --protocols=\"HTTP=http|www|https|3128,FTP=ftp|ftp-data\"
#--trace-level 0 # FATALERROR only
#--trace-level 1 # ERROR and above only 
#--trace-level 2 # WARNING and above only
#--trace-level 3 # INFO, WARNING and ERRORs - the default
#--trace-level 4 # NOISY - everything
#--trace-level 6 # NOISY + MSGID
#--trace-level 7 # NOISY + MSGID + file/line
#--daemon --use-syslog
#--http-server -w 127.0.0.1:3000
#--https-server -w 127.0.0.1:3001
--pid-path=/var/tmp/ntopng.pid
--daemon
--interface=$EXT_INTERFACE,$INT_INTERFACE
--http-port=3000
--local-networks="10.0.0.0/24"
--dns-mode=1
--data-dir=/var/tmp/ntopng
--disable-autologout
--community
" > /etc/ntopng/ntopng.conf

	# Restarting ntopng sevice
	echo "Restarting ntopng ..."
	/etc/init.d/ntopng restart
}


# ---------------------------------------------------------
# Function to configure redsocks proxy server
# ---------------------------------------------------------
configure_redsocks()
{
        echo "Configuring redsocks ..."

        # Creating log file
        rm -rf /var/log/redsocks.log
        touch /var/log/redsocks.log

        # Creating configuretion file
cat << EOF > /opt/redsocks/redsocks.conf
	base {
       		log_debug = off;
        	log_info = on;
        	log = "file:/var/log/redsocks.log";
        	daemon = on;
        	redirector = iptables;
	}
	redsocks {
        	local_ip = 0.0.0.0;
        	local_port = 9051;
        	ip = 127.0.0.1;
        	port = 9050;
        	type = socks5;
	}
EOF
}


# ---------------------------------------------------------
# Function to start mailpile local service
# ---------------------------------------------------------
configure_mailpile()
{
echo "Configuring Mailpile local service ..."
export MAILPILE_HOME=.local/share/Mailpile
if [ -e $MAILPIEL_HOME/default/mailpile.cfg ]; then
echo "Configuration file does not exist. Exiting ..."
exit 6
fi

# Make Mailpile a service with upstart
echo "
description \"Mailpile Webmail Client\"
author      \"Sharon Campbell\"

start on filesystem or runlevel [2345]
stop on shutdown

script

echo \$\$ > /var/run/mailpile.pid
exec /usr/bin/screen -dmS mailpile_init /var/Mailpile/mp

end script

pre-start script
echo \"[\`date\`] Mailpile Starting\" >> /var/log/mailpile.log
end script

pre-stop script
rm /var/run/mailpile.pid
echo \"[\`date\`] Mailpile Stopping\" >> /var/log/mailpile.log
end script
" > /etc/init/mailpile.conf

echo "Starting Mailpile local service ..."
/usr/bin/screen -dmS mailpile_init /opt/Mailpile/mp
}


# ---------------------------------------------------------
# Function to configure modsecurity
# ---------------------------------------------------------
configure_modsecurity()
{
echo "Configuring modsecurity ..."
cp /usr/src/modsecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.conf
cp /usr/src/modsecurity/unicode.mapping /etc/nginx/

# Creating new directory for the ModSecurity audit log
mkdir -p /opt/modsecurity/var/audit/
chown -R www-data:www-data /opt/modsecurity/var/audit/

# Creating modsecurity configuration
cat << EOF >> /etc/nginx/modsecurity.conf
#DefaultAction
SecDefaultAction "log,deny,phase:1"

#If you want to load single rule /usr/loca/nginx/conf
#Include base_rules/modsecurity_crs_41_sql_injection_attacks.conf

#Load all Rule
Include base_rules/*.conf

#Disable rule by ID from error message (for my wordpress)
SecRuleRemoveById 981172 981173 960032 960034 960017 960010 950117 981004 960015
EOF
}


# ---------------------------------------------------------
# Function to configure nginx web server
# ---------------------------------------------------------
configure_nginx() 
{
echo "Configuring Nginx ..."

# Stop and change apache configuration
/etc/init.d/apache2 stop
sed -i s/*:80/*:88/g  /etc/apache2/sites-enabled/000-default.conf
sed -i s/80/88/g  /etc/apache2/ports.conf

mkdir -p /etc/ssl/nginx/
rm -rf /etc/nginx/sites-enabled/*
mkdir -p /etc/nginx/sites-enabled/

# Creating configuration file
cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
worker_connections 768;
# multi_accept on;
}

http {

##
# Basic Settings
##

sendfile on;
tcp_nopush on;
tcp_nodelay on;
keepalive_timeout 65;
types_hash_max_size 2048;
# server_tokens off;

# server_names_hash_bucket_size 64;
# server_name_in_redirect off;

include /etc/nginx/mime.types;
default_type application/octet-stream;

##
# Logging Settings
##

access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;

##
# Gzip Settings
##

gzip on;
gzip_disable "msie6";

# gzip_vary on;
# gzip_proxied any;
# gzip_comp_level 6;
# gzip_buffers 16 8k;
# gzip_http_version 1.1;
# gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

##
# nginx-naxsi config
##
# Uncomment it if you installed nginx-naxsi
##

#include /etc/nginx/naxsi_core.rules;

##
# nginx-passenger config
##
# Uncomment it if you installed nginx-passenger
##

#passenger_root /usr;
#passenger_ruby /usr/bin/ruby;

##
# Virtual Host Configs
##

include /etc/nginx/conf.d/*.conf;
include /etc/nginx/sites-enabled/*;
}
EOF

# Creating init script
cat << EOF > /etc/init.d/nginx
#! /bin/sh

### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    \$all
# Required-Stop:     \$all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the nginx web server
# Description:       starts nginx using start-stop-daemon
### END INIT INFO

PATH=/opt/bin:/opt/sbin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/nginx
NAME=nginx
DESC=nginx

test -x \$DAEMON || exit 0

# Include nginx defaults if available
if [ -f /etc/default/nginx ] ; then
. /etc/default/nginx
fi

set -e

case "\$1" in
start)
echo -n "Starting \$DESC: "
start-stop-daemon --start --quiet --pidfile /var/run/nginx.pid \
	--exec \$DAEMON -- \$DAEMON_OPTS
echo "\$NAME."
;;
stop)
echo -n "Stopping \$DESC: "
start-stop-daemon --stop --quiet --pidfile /var/run/nginx.pid \
	--exec \$DAEMON
echo "\$NAME."
;;
restart|force-reload)
echo -n "Restarting \$DESC: "
start-stop-daemon --stop --quiet --pidfile \
	/var/run/nginx.pid --exec \$DAEMON
sleep 1
start-stop-daemon --start --quiet --pidfile \
	/var/run/nginx.pid --exec \$DAEMON -- \$DAEMON_OPTS
echo "\$NAME."
;;
reload)
echo -n "Reloading \$DESC configuration: "
start-stop-daemon --stop --signal HUP --quiet --pidfile /var/run/nginx.pid \
  --exec \$DAEMON
echo "\$NAME."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$N {start|stop|restart|force-reload}" >&2
exit 1
;;
esac

exit 0
EOF

# Setting init file permission
chmod +x /etc/init.d/nginx

# Systemctl reload
systemctl daemon-reload


#--------php-handler----------#

# Creating virtual hosts
echo "upstream php-handler {
server 127.0.0.1:9000;
#server unix:/var/run/php5-fpm.sock;
}
" > /etc/nginx/sites-enabled/php-fpm


#----------defualt page----------#

#echo "server {
#listen 80 default_server;
#return 301 http://librerouter.librenet;
#}
#
#server {
#listen 80;
#server_name box.librenet;
#return 301 http://librerouter.librenet;
#}
#" > /etc/nginx/sites-enabled/default


#----------librerouter.librenet--------#

echo "server {
listen 10.0.0.1:80;
server_name librerouter.librenet;
root /var/www/html;
index index.html;

location /phpmyadmin {
       root /usr/share/;
       index index.php index.html index.htm;
       location ~ ^/phpmyadmin/(.+\.php)$ {
	       try_files \$uri =404;
	       root /usr/share/;
	       fastcgi_pass unix:/var/run/php5-fpm.sock;
	       fastcgi_index index.php;
	       fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	       include /etc/nginx/fastcgi_params;
       }
       location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
	       root /usr/share/;
       }
}
location /phpMyAdmin {
       rewrite ^/* /phpmyadmin last;
}
}
" > /etc/nginx/sites-enabled/librerouter


#------------search.librerouter.net-----------#

# Configuring Yacy virtual host
echo "Configuring Yacy virtual host ..."

# Getting Tor hidden service yacy hostname
SERVER_YACY="$(cat /var/lib/tor/hidden_service/yacy/hostname 2>/dev/null)"

# Creating certificate bundle
rm -rf /etc/ssl/nginx/search/search_bundle.crt
cat /etc/ssl/nginx/search/search_librerouter_net.crt /etc/ssl/nginx/search/search_librerouter_net.ca-bundle >> /etc/ssl/nginx/search/search_bundle.crt

# Creating Yacy virtual host configuration
echo "
# search.librerouter.net http server
server {
	listen 10.0.0.251:80;
	server_name search.librerouter.net;
	rewrite ^/search(.*) http://\$server_name/yacysearch.html?query=\$arg_q? last;
	location / {
		proxy_pass       http://127.0.0.1:8090;
		proxy_set_header Host      \$host;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}

# Redirect connections from 10.0.0.251 to search.librerouter.net
server {
	listen 10.0.0.251;
	server_name _;
	return 301 http://search.librerouter.net;
}

# search.librerouter.net https server
server {
	listen 10.0.0.251:443 ssl;
	server_name search.librerouter.net;
	ssl_certificate /etc/ssl/nginx/search/search_bundle.crt;
	ssl_certificate_key /etc/ssl/nginx/search/search_librerouter_net.key;
	rewrite ^/search(.*) http://\$server_name/yacysearch.html?query=\$arg_q? last;
	location / {
		proxy_pass       http://127.0.0.1:8090;
		proxy_set_header Host      \$host;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}
" > /etc/nginx/sites-enabled/yacy


#--------social.librerouter.net----------#

# Configuring Friendica virtual host
echo "Configuring Friendica virtual host ..."

# Getting Tor hidden service friendica hostname
SERVER_FRIENDICA="$(cat /var/lib/tor/hidden_service/friendica/hostname 2>/dev/null)"

# Creating certificate bundle
rm -rf /etc/ssl/nginx/social/social_bundle.crt
cat /etc/ssl/nginx/social/social_librerouter_net.crt /etc/ssl/nginx/social/social_librerouter_net.ca-bundle >> /etc/ssl/nginx/social/social_bundle.crt

# Creating friendica virtual host configuration
echo "
# Redirect connections from 10.0.0.252 to social.librerouter.net 
server {
listen 10.0.0.252:80;
server_name _;
return 301 http://social.librerouter.net;
}

# social.librerouter.net https server
server {
listen 10.0.0.252:80;
listen 10.0.0.252:443 ssl;
server_name social.librerouter.net;

ssl on;
ssl_certificate /etc/ssl/nginx/social/social_bundle.crt;
ssl_certificate_key /etc/ssl/nginx/social/social_librerouter_net.key;
ssl_session_timeout 5m;
ssl_protocols SSLv3 TLSv1;
ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
ssl_prefer_server_ciphers on;

index index.php;
charset utf-8;
root /var/www/friendica;
access_log /var/log/nginx/friendica.log;
# allow uploads up to 20MB in size
client_max_body_size 20m;
client_body_buffer_size 128k;
# rewrite to front controller as default rule
location / {
rewrite ^/(.*) /index.php?q=\$uri&\$args last;
}

# make sure webfinger and other well known services arent blocked
# by denying dot files and rewrite request to the front controller
location ^~ /.well-known/ {
allow all;
rewrite ^/(.*) /index.php?q=\$uri&\$args last;
}

# statically serve these file types when possible
# otherwise fall back to front controller
# allow browser to cache them
# added .htm for advanced source code editor library
location ~* \.(jpg|jpeg|gif|png|ico|css|js|htm|html|ttf|woff|svg)$ {
expires 30d;
try_files \$uri /index.php?q=\$uri&\$args;
}
# block these file types
location ~* \.(tpl|md|tgz|log|out)$ {
deny all;
}

# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
# or a unix socket
location ~* \.php$ {
try_files \$uri =404;

fastcgi_split_path_info ^(.+\.php)(/.+)$;

# With php5-cgi alone:
# fastcgi_pass 127.0.0.1:9000;

# With php5-fpm:
fastcgi_pass unix:/var/run/php5-fpm.sock;

include fastcgi_params;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}

# deny access to all dot files
location ~ /\. {
deny all;
}
}

server {
listen 10.0.0.252:80;
listen 10.0.0.252:443 ssl;
server_name $SERVER_FRIENDICA;

ssl on;
ssl_certificate /etc/ssl/nginx/social/social_bundle.crt;
ssl_certificate_key /etc/ssl/nginx/social/social_librerouter_net.key;
ssl_session_timeout 5m;
ssl_protocols SSLv3 TLSv1;
ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
ssl_prefer_server_ciphers on;

index index.php;
charset utf-8;
root /var/www/friendica;
access_log /var/log/nginx/friendica.log;
# allow uploads up to 20MB in size
client_max_body_size 20m;
client_body_buffer_size 128k;
# rewrite to front controller as default rule
location / {
rewrite ^/(.*) /index.php?q=\$uri&\$args last;
}

# make sure webfinger and other well known services arent blocked
# by denying dot files and rewrite request to the front controller
location ^~ /.well-known/ {
allow all;
rewrite ^/(.*) /index.php?q=\$uri&\$args last;
}

# statically serve these file types when possible
# otherwise fall back to front controller
# allow browser to cache them
# added .htm for advanced source code editor library
location ~* \.(jpg|jpeg|gif|png|ico|css|js|htm|html|ttf|woff|svg)$ {
	expires 30d;
	try_files \$uri /index.php?q=\$uri&\$args;
}
# block these file types
location ~* \.(tpl|md|tgz|log|out)$ {
	deny all;
}

# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
# or a unix socket
location ~* \.php$ {
	try_files \$uri =404;

	fastcgi_split_path_info ^(.+\.php)(/.+)$;

	# With php5-cgi alone:
	# fastcgi_pass 127.0.0.1:9000;

	# With php5-fpm:
	fastcgi_pass unix:/var/run/php5-fpm.sock;

	include fastcgi_params;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}

# deny access to all dot files
location ~ /\. {
	deny all;
}
}
" > /etc/nginx/sites-enabled/friendica 


#--------storage.librerouter.net----------#

# Configuring Owncloud virtual host
echo "Configuring Owncloud virtual host ..."

# Getting Tor hidden service owncloud hostname
SERVER_OWNCLOUD="$(cat /var/lib/tor/hidden_service/owncloud/hostname 2>/dev/null)"

# Creating certificate bundle
rm -rf /etc/ssl/nginx/storage/storage_bundle.crt
cat /etc/ssl/nginx/storage/storage_librerouter_net.crt /etc/ssl/nginx/storage/storage_librerouter_net.ca-bundle >> /etc/ssl/nginx/storage/storage_bundle.crt

# Creating Owncloud virtual host configuration
echo "
# Redirect connections from 10.0.0.253 to storage.librerouter.net
server {
	listen 10.0.0.253:80;
	server_name _;
	return 301 https://storage.librerouter.net;
}

# storage.librerouter.net https server
server {
	listen 10.0.0.253:443 ssl;
	ssl_certificate      /etc/ssl/nginx/storage/storage_bundle.crt;
	ssl_certificate_key  /etc/ssl/nginx/storage/storage_librerouter_net.key;
	server_name storage.librerouter.net;
	index index.php;
	root /var/www/owncloud;

	# set max upload size
	client_max_body_size 10G;
	fastcgi_buffers 64 4K;

	# rewrite rules
	rewrite ^/caldav(.*)\$ /remote.php/caldav\$1 redirect;
	rewrite ^/carddav(.*)\$ /remote.php/carddav\$1 redirect;
	rewrite ^/webdav(.*)\$ /remote.php/webdav\$1 redirect;

	# error pages paths
	error_page 403 /core/templates/403.php;
	error_page 404 /core/templates/404.php;

	location ~ \.php(?:\$|/) {
		fastcgi_split_path_info ^(.+\.php)(/.+)\$;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		fastcgi_param PATH_INFO \$fastcgi_path_info;
		fastcgi_param HTTPS on;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}


	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README){
		deny all;
	}

	location / {
		# The following 2 rules are only needed with webfinger
		rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
		rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;

		rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
		rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
	
		rewrite ^(/core/doc/[^\/]+/)\$ \$1/index.html;

		try_files \$uri \$uri/ /index.php;
	}

	# Optional: set long EXPIRES header on static assets
	location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|css|js|swf)\$ {
		expires 30d;
		# Optional: Dont log access to assets
		access_log off;
	}

}

# Main server for Tor hidden service owncloud
server {
	listen 10.0.0.253:80;
	server_name $SERVER_OWNCLOUD;
	index index.php;
	root /var/www/owncloud;

	# php5-fpm configuration
	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
	}
}
" > /etc/nginx/sites-enabled/owncloud


#--------email.librerouter.net----------#

# Configuring Mailpile virtual host
echo "Configuring Mailpile virtual host ..."

# Getting Tor hidden service mailpile hostname
SERVER_MAILPILE="$(cat /var/lib/tor/hidden_service/mailpile/hostname 2>/dev/null)"

# Creating certificate bundle
rm -rf /etc/ssl/nginx/email/email_bundle.crt
cat /etc/ssl/nginx/email/email_librerouter_net.crt /etc/ssl/nginx/email/email_librerouter_net.ca-bundle >> /etc/ssl/nginx/email/email_bundle.crt 

# Creating mailpile virtual host configuration
echo "
# Redirect connections from 10.0.0.254 to email.librerouter.net
server {
	listen 10.0.0.254;
	server_name _;
	return 301 http://email.librerouter.net;
}   

# email.librerouter.net http/https server
server {
# Mailpile Domain
	server_name email.librerouter.net;
	client_max_body_size 20m;

	# Nginx port 80 and 443
	listen 10.0.0.254:80;
	listen 10.0.0.254:443 ssl;

	# SSL Certificate File
	ssl_certificate      /etc/ssl/nginx/email/email_bundle.crt;
	ssl_certificate_key  /etc/ssl/nginx/email/email_librerouter_net.key;
	# Nginx Poroxy pass for mailpile
	location / {
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header Host \$http_host;
		proxy_set_header X-NginX-Proxy true;
		proxy_pass http://127.0.0.1:33411;
		proxy_read_timeout  90;
	}
} 

server {
	# Mailpile Domain
	server_name $SERVER_MAILPILE;
	client_max_body_size 20m;

	# Nginx port 80 and 443
	listen 10.0.0.254:80;
	listen 10.0.0.254:443 ssl;

	# SSL Certificate File
	ssl_certificate      /etc/ssl/nginx/email/email_bundle.crt;
	ssl_certificate_key  /etc/ssl/nginx/email/email_librerouter_net.key;
	# Nginx Poroxy pass for mailpile
	location / {
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header Host \$http_host;
		proxy_set_header X-NginX-Proxy true;
		proxy_pass http://127.0.0.1:33411;
		proxy_read_timeout  90;
	}
}
" > /etc/nginx/sites-enabled/mailpile


#--------webmin.librenet----------#

# Configuring Webmin virtual host
echo "Configuring Webmin virtual host ..."

# Generating certificates for webmin ssl connection
echo "Generating keys and certificates for webmin"
if [ ! -e /etc/ssl/nginx/webmin.key -o ! -e  /etc/ssl/nginx/webmin.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/webmin.key -out /etc/ssl/nginx/webmin.crt -subj '/CN=librerouter' -batch
fi

# Creating Webmin virtual host configuration
echo "
# Redirect connections from 10.0.0.245 to webmin.librenet
server {
listen 10.0.0.245;
server_name _;
return 301 https://webmin.librenet;
}

# Redirect connections to webmin running on 127.0.0.1:10000
server {
listen 10.0.0.245:443 ssl;
server_name webmin.librenet;

ssl on;
ssl_certificate /etc/ssl/nginx/webmin.crt;
ssl_certificate_key /etc/ssl/nginx/webmin.key;
ssl_session_timeout 5m;
ssl_protocols SSLv3 TLSv1;
ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
ssl_prefer_server_ciphers on;

location / {
proxy_pass       https://127.0.0.1:10000;
proxy_set_header Host      \$host;
proxy_set_header X-Real-IP \$remote_addr;
}

}
" > /etc/nginx/sites-enabled/webmin

# Configuring Kibana virtual host
echo "Configuring Kibana virtual host ..."

# Generating certificates for Kibana ssl connection
echo "Generating keys and certificates for Kibana"
if [ ! -e /etc/ssl/nginx/kibana.key -o ! -e  /etc/ssl/nginx/kibana.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/kibana.key -out /etc/ssl/nginx/kibana.crt -subj '/CN=librerouter' -batch
fi


#--------kibana.librenet----------#

# Creating Kibana virtual host configuration
#echo '
#server {
#listen 10.0.0.11;
#server_name _;
#return 301 https://kibana.librenet;
#}
#
#server {
#listen 80;
#listen 443 ssl;
#server_name kibana.librenet;
#
#ssl on;
#ssl_certificate /etc/ssl/nginx/kibana.crt;
#ssl_certificate_key /etc/ssl/nginx/kibana.key;
#ssl_session_timeout 5m;
#ssl_protocols SSLv3 TLSv1;
#ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
#ssl_prefer_server_ciphers on;
#access_log /var/log/nginx/kibana.access.log;
#error_log /var/log/nginx/kibana.error.log;
#
#location / {
#	proxy_pass       http://127.0.0.1:5601;
#	proxy_set_header Upgrade $http_upgrade;
#	proxy_set_header Host $host;
#	proxy_cache_bypass $http_upgrade;
#}
#}
#' > /etc/nginx/sites-enabled/kibana


#--------snorby.librenet----------#

# Configuring Snorby virtual host
#echo "Configuring Snorby virtual host ..."
#echo '
#server {
#listen 10.0.0.12:80;
#server_name snorby.librenet;
##	passenger_enabled on;
##	passenger_ruby /usr/bin/ruby2.1;
##	passenger_user  root;
##	passenger_group root;
#
#access_log /var/log/nginx/snorby.log;
#root /var/www/snorby/public;
#index index.html;
#
#location /snorby {
#	root /usr/www/snorby/public;
#	index index.html;
#	location ~ \.cgi$ {
#		try_files $uri =404;
#		include fastcgi_params;
#		fastcgi_pass unix:/var/run/fcgiwrap/fcgiwrap.sock;
#		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#		fastcgi_param REMOTE_USER $remote_user;
#	}
#
#	location ~ \.php$ {
#		try_files $uri =404;
#		include fastcgi_params;
#		fastcgi_pass 127.0.0.1:9000;
#		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#	}
#}
#}
#' > /etc/nginx/sites-enabled/snorby


#--------squidguard.librenet----------#

# Configuring squidguard virtual host
echo "Configuring squidguard virtual host ..."
echo '
# Redirect connections from 10.0.0.246 to squidguardmgr.librenet
server {
listen 10.0.0.246:80;
server_name _;
return 301 http://squidguard.librenet;
}

server {
listen 10.0.0.246:80;
server_name squidguard.librenet;

index squidguardmgr.cgi;
charset utf-8;
root /var/www/squidguardmgr;
access_log /var/log/nginx/squidguardmgr.log;

location ~ .cgi\$ {
include uwsgi_params;
uwsgi_modifier1 9;
uwsgi_pass 127.0.0.1:9000;
}
}
' > /etc/nginx/sites-enabled/squidguard

# Include passenger in nginx
sed -i -e 's@\t# include /etc/nginx/passenger.conf.*@\tinclude /etc/nginx/passenger.conf;@g' /etc/nginx/nginx.conf


#--------conference.librerouter.net----------#

# Configuring EasyRTC virtual host
echo "Configuring EasyRTC virtual host ..."

# Getting Tor hidden service EasyRTC hostname
SERVER_EASYRTC="$(cat /var/lib/tor/hidden_service/easyrtc/hostname 2>/dev/null)"

# Creating certificate bundle
rm -rf /etc/ssl/nginx/conference/conference_bundle.crt
cat /etc/ssl/nginx/conference/conference_librerouter_net.crt /etc/ssl/nginx/conference/conference_librerouter_net.ca-bundle >> /etc/ssl/nginx/conference/conference_bundle.crt

# Creating EasyRTC virtual host configuration
echo "
# Redirect connections from 10.0.0.250 to EasyTRC https 
server {
	listen 10.0.0.250;
	server_name _;
	return 301 https://conference.librerouter.net/demos/demo_multiparty.html;
}

# conference.librerouter.net https server 
server {
	listen 10.0.0.250:80;
	listen 10.0.0.250:443 ssl;
	server_name conference.librerouter.net;
	ssl_certificate /etc/ssl/nginx/conference/conference_bundle.crt;
	ssl_certificate_key /etc/ssl/nginx/conference/conference_librerouter_net.key;
	rewrite ^/$ /demos/demo_multiparty.html permanent;
	location / {
		proxy_pass       https://127.0.0.1:8443;
		proxy_set_header Host      \$host;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}

server {
	listen 10.0.0.250:80;
	listen 10.0.0.250:443 ssl;
	server_name $SERVER_EASYRTC;
        ssl_certificate /etc/ssl/nginx/conference/conference_bundle.crt;
        ssl_certificate_key /etc/ssl/nginx/conference/conference_librerouter_net.key;
	rewrite ^/$ /demos/demo_multiparty.html permanent;
	location / {
		proxy_pass       https://127.0.0.1:8443;
		proxy_set_header Host      \$host;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}
" > /etc/nginx/sites-enabled/easyrtc

# i2p.librenet virtual host configuration  

echo "
server {
listen 10.0.0.1:80;
server_name i2p.librenet;

location / {
proxy_pass       http://127.0.0.1:7657;
proxy_set_header Host      \$host;
proxy_set_header X-Real-IP \$remote_addr;
}
}
" > /etc/nginx/sites-enabled/i2p 


#--------tahoe.librenet----------#

# tahoe.librenet virtual host configuration

#echo "
#server {
#listen 10.0.0.1:80;
#server_name tahoe.librenet;
#
#location / {
#proxy_pass       http://127.0.0.1:3456;
#proxy_set_header Host      \$host;
#proxy_set_header X-Real-IP \$remote_addr;
#}
#}
#" > /etc/nginx/sites-enabled/tahoe


#--------trac.librenet-----------#
# trac.librenet virtual host configuration
echo "Configuring trac virtual host ..."

# Generating certificates for trac ssl connection
echo "Generating keys and certificates for trac"
if [ ! -e /etc/ssl/nginx/trac.key -o ! -e  /etc/ssl/nginx/trac.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/trac.key -out /etc/ssl/nginx/trac.crt -subj '/CN=librerouter' -batch
fi

# trac.librenet virtual host configuration
echo "
server {
	listen 10.0.0.248;
	server_name _;
	return 301 http://trac.librenet;
}

server {
	listen 10.0.0.248:80;
	listen 10.0.0.248:443 ssl;
	server_name trac.librenet;
	ssl_certificate /etc/ssl/nginx/trac.crt;
	ssl_certificate_key /etc/ssl/nginx/trac.key;
	location / {
		proxy_pass       http://127.0.0.1:8000;
		proxy_set_header Host      \$host;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}
" > /etc/nginx/sites-enabled/trac 


#----------redmine.librenet----------#
#
# Redmine.librenet virtual host configuration

# Generating certificates for redmine ssl connection
echo "Generating keys and certificates for redmine"
if [ ! -e /etc/ssl/nginx/redmine.key -o ! -e  /etc/ssl/nginx/redmine.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/redmine.key -out /etc/ssl/nginx/redmine.crt -subj '/CN=librerouter' -batch
fi

echo "
# Upstream Ruby process cluster for load balancing
upstream thin_cluster {
    server 127.0.0.1:8889;
}

server {
    listen       10.0.0.249:80;
    server_name  redmine.librenet;

    access_log  /var/log/nginx/redmine-proxy-access;
    error_log   /var/log/nginx/redmine-proxy-error;

#    include sites/proxy.include;
    root /opt/redmine/redmine-3.3.1/public;
    proxy_redirect off;

    # Send sensitive stuff via https
    rewrite ^/login(.*) https://redmine.librenet\$request_uri permanent;
    rewrite ^/my/account(.*) https://redmine.librenet\$request_uri permanent;
    rewrite ^/my/password(.*) https://redmine.librenet\$request_uri permanent;
    rewrite ^/admin(.*) https://redmine.librenet\$request_uri permanent;

    location / {
        try_files \$uri/index.html \$uri.html \$uri @cluster;
    }

    location @cluster {
        proxy_pass http://thin_cluster;
    }
}

server {
    listen       10.0.0.249:443 ssl;
    server_name  redmine.librenet;

    access_log  /var/log/nginx/redmine-ssl-proxy-access;
    error_log   /var/log/nginx/redmine-ssl-proxy-error;

    ssl on;

    ssl_certificate /etc/ssl/nginx/redmine.crt;
    ssl_certificate_key /etc/ssl/nginx/redmine.key;

#    include sites/proxy.include;
    proxy_redirect off;
    root /opt/redmine/redmine-3.3.1/public;

    # When were back to non-sensitive things, send back to http
    rewrite ^/\$ http://redmine.librenet\$request_uri permanent;

    # Examples of URLs we dont want to rewrite (otherwise 404 errors occur):
    # /projects/PROJECTNAME/archive?status=
    # /projects/copy/PROJECTNAME
    # /projects/PROJECTNAME/destroy

    # This should exclude those (tested here: http://www.regextester.com/ )
    if (\$uri !~* \"^/projects/.*(copy|destroy|archive)\") {
        rewrite ^/projects(.*) http://redmine.librenet\$request_uri permanent;
    }

    rewrite ^/guide(.*) http://redmine.librenet\$request_uri permanent;
    rewrite ^/users(.*) http://redmine.librenet\$request_uri permanent;
    rewrite ^/my/page(.*) http://redmine.librenet\$request_uri permanent;
    rewrite ^/logout(.*) http://redmine.librenet\$request_uri permanent;

    location / {
        try_files \$uri/index.html \$uri.html \$uri @cluster;
    }

    location @cluster {
        proxy_pass http://thin_cluster;
    }
}
" > /etc/nginx/sites-enabled/redmine

#----------------------ntop.librenet-----------------------#
#                       10.0.0.244                         #
############################################################
echo "
# Redirect connections from 10.0.0.244 to ntop.librenet
server {
	listen 10.0.0.244;
	server_name _;
	return 301 http://ntop.librenet;
}
server {
	listen 10.0.0.244:80;
	server_name ntop.librenet;
	location / {
		proxy_pass       http://127.0.0.1:3000;
		proxy_set_header Host      \$host;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}
" > /etc/nginx/sites-enabled/ntop

# Restarting Yacy php5-fpm and Nginx services 
echo "Restarting nginx ..."
service yacy restart
service php5-fpm restart
/etc/init.d/nginx start
}


# ---------------------------------------------------------
# Function to check interfaces
# ---------------------------------------------------------
check_interfaces()
{
# Preparing script file
touch /root/libre_scripts/check_interfaces.sh
chmod +x /root/libre_scripts/check_interfaces.sh


# Script to check interfaces
cat << EOF > /root/libre_scripts/check_interfaces.sh
#!/bin/bash
# Checking physical interfaces (eth0 and eth1)
if ip addr show eth1 | grep 'state UP'; then
if ip addr show eth0 | grep 'state UP'; then
# Checking virtual interfaces (ethx:1 ethx:2 ethx:3 ethx:4 ethx:5 ethx:6)
    if ping -c 1 10.0.0.245; then
	if ping -c 1 10.0.0.250; then
	    if ping -c 1 10.0.0.251; then
		if ping -c 1 10.0.0.252; then
		    if ping -c 1 10.0.0.253; then
			if ping -c 1 10.0.0.254; then
			    logger "Check Interfaces: Network is ok"
			else
			    #Make a note in syslog
			    logger "Check Interfaces: ethx:4 is down, restarting network ..."
			    /etc/init.d/networking restart
			    exit
			fi
		    else
			#Make a note in syslog
			logger "Check Interfaces: ethx:3 is down, restarting network ..."
			/etc/init.d/networking restart
			exit
		    fi
		else
		    #Make a note in syslog
		    logger "Check Interfaces: ethx:2 is down, restarting network ..."
		    /etc/init.d/networking restart
		    exit
		fi
	    else
		#Make a note in syslog
		logger "Check Interfaces: ethx:1 is down, restarting network ..."
		/etc/init.d/networking restart
		exit
	    fi
	else
	    #Make a note in syslog
	    logger "Check Interfaces: ethx:6 is down, restarting network ..."
	    /etc/init.d/networking restart
	    exit
	fi
    else
	#Make a note in syslog
	logger "Check Interfaces: ethx:5 is down, restarting network ..."
	/etc/init.d/networking restart
	exit
    fi
else
#Make a note in syslog
logger "Check Interfaces: eth0 is down, restarting network ..."
/etc/init.d/networking restart
exit
fi
else
#Make a note in syslog
logger "Check Interfaces: eth1 is down, restarting network ..."
/etc/init.d/networking restart
exit
fi
EOF


# Creating cron job
echo "@reboot sleep 20 && /root/libre_scripts/check_interfaces.sh" >> /root/libre_scripts/cron_jobs
crontab /root/libre_scripts/cron_jobs
}


# ---------------------------------------------------------
# Function to check services
# ---------------------------------------------------------
check_services()
{
# Preparing script file
rm -rf /root/libre_scripts/check_services.sh
touch /root/libre_scripts/check_services.sh
chmod +x /root/libre_scripts/check_services.sh


# Script to check services
cat << EOF > /root/libre_scripts/check_services.sh
#!/bin/bash
# Checking unbound
if /etc/init.d/unbound status | grep "active (running)"; then
logger "Check Services: Unbound is ok"
else
logger "Check Services: Unbound is not running. Restarting ..."
/etc/init.d/unbound restart
fi

# Checking isc-dhcp-server
if /etc/init.d/isc-dhcp-server status | grep "active (running)"; then
logger "Check Services: isc-dhcp-server is ok"
else
logger "Check Services: isc-dhcp-server is not running. Restarting ..."
/etc/init.d/isc-dhcp-server restart
fi

# Checking squid
if /etc/init.d/squid status | grep "active (running)"; then
logger "Check Services: squid is ok"
else
logger "Check Services: squid is not running. Restarting ..."
/etc/init.d/squid restart
fi

# Checking squid-tor
if /etc/init.d/squid-tor status | grep "active (running)"; then
logger "Check Services: squid-tor is ok"
else
logger "Check Services: squid-tor is not running. Restarting ..."
/etc/init.d/squid-tor restart
fi

# Checking squid-i2p
if /etc/init.d/squid-i2p status | grep "active (running)"; then
logger "Check Services: squid-i2p is ok"
else
logger "Check Services: squid-i2p is not running. Restarting ..."
/etc/init.d/squid-i2p restart
fi

# Checking clamav-daemon
if /etc/init.d/clamav-daemon status | grep "active (running)"; then
logger "Check Services: clamav-daemon is ok"
else
logger "Check Services: clamav-daemon is not running. Restarting ..."
/etc/init.d/clamav-daemon restart
fi

# Checking c-icap
if /etc/init.d/c-icap status | grep "active (running)"; then
logger "Check Services: c-icap is ok"
else
logger "Check Services: c-icap is not running. Restarting ..."
/etc/init.d/c-icap restart
fi

# Checking privoxy
if /etc/init.d/privoxy status | grep "active (running)"; then
logger "Check Services: privoxy is ok"
else
logger "Check Services: privoxy is not running. Restarting ..."
/etc/init.d/privoxy restart
fi

# Checking privoxy-tor
if /etc/init.d/privoxy-tor status | grep "active (running)"; then
logger "Check Services: privoxy-tor is ok"
else
logger "Check Services: privoxy-tor is not running. Restarting ..."
/etc/init.d/privoxy-tor restart
fi

# Checking nginx
if /etc/init.d/nginx status | grep "active (running)"; then
logger "Check Services: Nginx is ok"
else
logger "Check Services: Nginx is not running. Restarting ..."
/etc/init.d/nginx restart
fi
EOF


# Creating cron job
echo "@reboot sleep 40 && /root/libre_scripts/check_interfaces.sh" >> /root/libre_scripts/cron_jobs
crontab /root/libre_scripts/cron_jobs
}


# ---------------------------------------------------------
# Function to configure Suricata service
# ---------------------------------------------------------
configure_suricata()
{
echo "Configuring Suricata ..."

#prepare network interface to work with suricata
echo "peparing the network interfaces ..."
ethtool -K lo rx off tso off gso off sg off gro off lro off
ifconfig lo mtu 1400

# Suricata configuration
sed -i -e '/#HOME_NET:/d' /etc/suricata/suricata.yaml
sed -i -e 's@HOME_NET:.*$@HOME_NET: "[10.0.0.0/24]"@g' /etc/suricata/suricata.yaml
sed -i -e 's@  windows: \[.*\]@  windows: []@g' /etc/suricata/suricata.yaml
sed -i -e 's@  linux: \[.*\]@  linux: [0.0.0.0]@g' /etc/suricata/suricata.yaml
sed -i -e "s@  - interface: eth0@  - interface: lo@g" /etc/suricata/suricata.yaml

# Suricata logs
touch /var/log/suricata/eve.json
touch /var/log/suricata/fast.log
touch /var/log/suricata/stats.log
touch /var/log/suricata/suricata.log
chmod 644 /var/log/suricata/*.log
chmod -R 666 /var/log/suricata 

# Suricata service
cat << EOF > /etc/default/suricata
# Default config for Suricata

# set to yes to start the server in the init.d script
RUN=yes

# Configuration file to load
SURCONF=/etc/suricata/suricata.yaml

# Listen mode: pcap, nfqueue or af-packet
# depending on this value, only one of the two following options
# will be used (af-packet uses neither).
# Please note that IPS mode is only available when using nfqueue
LISTENMODE=af-packet

# Interface to listen on (for pcap mode)
IFACE=lo

# Queue number to listen on (for nfqueue mode)
NFQUEUE=0

# Pid file
PIDFILE=/var/run/suricata.pid
EOF
echo "Restarting suricata ..."
update-rc.d suricata defaults
service suricata stop

# Starting suricata in loopback 
kill -9 `cat /var/run/suricata.pid`
rm -rf /var/run/suricata.pid
suricata -D -c /etc/suricata/suricata.yaml -i lo 

# checking for ethernet card configuration
sleep 20
if grep "ethtool" /var/log/suricata/suricata.log; then 

	# Getting ethtools parameters
	PARAMS=`cat /var/log/suricata/suricata.log \
	| grep ethtool  | awk -F 'ethtool' '{print $2}'`

	# Configuring ethernet card
	ethtool $PARAMS

	# kill suricata process and run it again
	kill -9 `cat /var/run/suricata.pid`
	rm -rf /var/run/suricata.pid
	suricata -D -c /etc/suricata/suricata.yaml -i lo
fi
}


# ---------------------------------------------------------
# Function to configure logstash
# ---------------------------------------------------------
configure_logstash()
{

echo "Conifgureing logstash ..."

# Creating configuration file
mkdir -p /etc/logstash/conf.d
touch /etc/logstash/conf.d/logstash.conf
chmod a+rw /etc/logstash/conf.d/logstash.conf

# Logstash configuration
cat << EOF > /etc/logstash/conf.d/logstash.conf
input {
file {
path => "/var/log/suricata/eve.json"
start_position => beginning
ignore_older => 0
sincedb_path => ["/var/lib/logstash/sincedb"]
codec =>   json
type => "SuricataIDPS"
}
}
filter {
if [type] == "SuricataIDPS" {
date {
match => [ "timestamp", "ISO8601" ]
}
ruby {
code => "if event['event_type'] == 'fileinfo'; event['fileinfo']['type']=event['fileinfo']['magic'].to_s.split(',')[0]; end;"
}
}
if [src_ip]  {
geoip {
source => "src_ip"
target => "geoip"
#database => "/opt/logstash/vendor/geoip/GeoLiteCity.dat"
add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}"  ]
}
mutate {
convert => [ "[geoip][coordinates]", "float" ]
}
if ![geoip.ip] {
if [dest_ip]  {
geoip {
  source => "dest_ip"
  target => "geoip"
  #database => "/opt/logstash/vendor/geoip/GeoLiteCity.dat"
  add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
  add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}"  ]
}
mutate {
  convert => [ "[geoip][coordinates]", "float" ]
}
}
}
}
}
output {
elasticsearch {
hosts => [ "localhost:9200" ]
}
}
EOF
}


# ---------------------------------------------------------
# Function to configure Kibana
# ---------------------------------------------------------
configure_kibana()
{
echo "Configuring Kibana ..."

# Configure PAM limits
sed -i -e '/# End of file/d' /etc/security/limits.conf
echo 'elasticsearch hard memlock 102400' >> /etc/security/limits.conf
echo '# End of file' >> /etc/security/limits.conf
# Configure elastic
cat << EOF > /etc/default/elasticsearch
################################
# Elasticsearch
################################

ES_JAVA_OPTS="Des.insecure.allow.root=true"

# Elasticsearch home directory
ES_HOME=/usr/share/elasticsearch

# Elasticsearch configuration directory
CONF_DIR=/etc/elasticsearch

# Elasticsearch data directory
DATA_DIR=/var/lib/elasticsearch

# Elasticsearch logs directory
LOG_DIR=/var/log/elasticsearch

# Elasticsearch PID directory
PID_DIR=/var/run/elasticsearch

# Memory usage
ES_HEAP_SIZE=128m
MAX_LOCKED_MEMORY=102400
ES_JAVA_OPTS=-server

# The number of seconds to wait before checking if Elasticsearch started successfully as a daemon process
ES_STARTUP_SLEEP_TIME=15
EOF

# Elasticsearch configuration
sed -i -e 's/cluster.name.*/cluster.name: "LibreRouter"/g' /etc/elasticsearch/elasticsearch.yml


# Fix logstash permissions
sed -i -e 's/LS_GROUP=.*/LS_GROUP=root/g' /etc/init.d/logstash
systemctl daemon-reload

# Enable autostart
systemctl enable elasticsearch
echo "Restarting elasticsearch ..."
service elasticsearch restart
systemctl enable kibana
systemctl enable logstash

echo "Restarting logstash ..."
service logstash restart
echo "Applying Kibana dashboards ..."
sleep 20 && /opt/KTS/load.sh && echo ""
echo "Kibana dashboards were successfully configured"
echo "Restarting kibana ..."
service kibana restart
}


# ---------------------------------------------------------
# Function to configure gitlab
# ---------------------------------------------------------
configure_gitlab()
{
# Gitlab can only be installed on x86_64 (64 bit) architecture
# So we configure it if architecture is x86_64
if [ "$ARCH" == "x86_64" ]; then
	echo "Configuring Gitlab ..."

	# Changing configuration in gitlab.rb
	sed -i -e '/^[^#]/d' /etc/gitlab/gitlab.rb

	echo "
external_url 'http://gitlab.librenet'
gitlab_workhorse['auth_backend'] = \"http://localhost:8081\"
unicorn['port'] = 8081
nginx['redirect_http_to_https'] = true
nginx['listen_addresses'] = ['10.0.0.247']
" >> /etc/gitlab/gitlab.rb

	# Reconfiguring gitlab 
	gitlab-ctl reconfigure

	# Restarting gitlab server
	gitlab-ctl restart
else
	echo "Gitlab configuration is skipped as detected architecture: $ARCH"
fi
}


# ---------------------------------------------------------
# Function to configure snortbarn
# ---------------------------------------------------------
configure_snortbarn()
{
echo "Configuring Snort + Barnyard2"

# Configure Snort
sed -i -e 's@ipvar HOME_NET .*@ipvar HOME_NET 10.0.0.0/24@g' /etc/snort/snort.conf
sed -i -e 's@ipvar EXTERNAL_NET .*@ipvar EXTERNAL_NET any@g' /etc/snort/snort.conf
echo 'output unified2: filename snort.log, limit 128' >> /etc/snort/snort.conf
sed -i -e 's@# alert@alert@g' /etc/snort/rules/snort.rules

# Validate Snort configuration
snort -T -i $INT_INTERFACE -c /etc/snort/snort.conf
if [ $? -ne 0 ]; then
	echo "Error: invalid Snort configuration"
	exit 1
fi

# Configure Barnyard
sed -i -e 's/#config hostname:.*/config hostname: librerouter/g' /etc/snort/barnyard2.conf
sed -i -e "s/#config interface:.*/config interface: $INT_INTERFACE/g" /etc/snort/barnyard2.conf
echo "output database: log, mysql, user=root password=$MYSQL_PASS dbname=snorby host=localhost" >> /etc/snort/barnyard2.conf
touch /var/log/snort/barnyard2.waldo

# Create startup scripts
cat << EOF > /etc/init.d/snortbarn
#!/bin/sh
#
### BEGIN INIT INFO
#Provides: snortbarn
#Required-Start: \$remote_fs \$syslog mysql
#Required-Stop: \$remote_fs \$syslog
#Default-Start: 2 3 4 5
#Default-Stop: 0 1 6
#X-Interactive: true
#Short-Description: Start Snort and Barnyard
### END INIT INFO

. /lib/init/vars.sh
. /lib/lsb/init-functions

mysqld_get_param() {
/usr/sbin/mysqld --print-defaults | tr " " "\n" | grep -- "--\$1" | tail -n 1 | cut -d= -f2
}

do_start()
{
log_daemon_msg "Starting Snort and Barnyard" ""
# Make sure mysql has finished starting
ps_alive=0
while [ \$ps_alive -lt 1 ];
do
pidfile=\`mysqld_get_param pid-file\`
if [ -f "\$pidfile" ] && ps \`cat \$pidfile\` >/dev/null 2>&1; then ps_alive=1; fi
sleep 1
done

/usr/bin/snort -q -i $INT_INTERFACE -c /etc/snort/snort.conf -D
/usr/bin/barnyard2 -q -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.log -w /var/log/snort/barnyard2.waldo -D

log_end_msg 0
return 0
}

do_stop()
{
log_daemon_msg "Stopping Snort and Barnyard" ""
kill \$(pidof snort) 2> /dev/null
kill \$(pidof barnyard2) 2> /dev/null
log_end_msg 0
return 0
}

case "\$1" in
start)
do_start
;;
stop)
do_stop
;;
restart)
do_stop
do_start
;;
*)
echo "Usage: snort-barn {start|stop|restart}" >&2
exit 3
;;
esac
exit 0
EOF
chmod +x /etc/init.d/snortbarn
update-rc.d snortbarn defaults
insserv -f -v snortbarn
service snortbarn start

# Create cron job for pulledpork
echo '10 1 * * * root /usr/sbin/pulledpork.pl -c /etc/snort/pulledpork.conf' >> /etc/crontab
echo '25 1 * * * root service snortbarn restart' >> /etc/crontab
}


configure_snorby()
{
echo "Configuring Snorby"
cat << EOF > /var/www/snorby/config/snorby_config.yml
production:
domain: 'snorbi.librenet'
wkhtmltopdf: /usr/bin/wkhtmltopdf
ssl: false
mailer_sender: 'snorby@example.com'
geoip_uri: "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
rules:
- "/etc/snort/rules"
authentication_mode: database
timezone_search: true
EOF

cat << EOF > /var/www/snorby/config/database.yml
# Snorby Database Configuration
snorby: &snorby
adapter: mysql
username: root
password: "$MYSQL_PASS"
host: localhost

production:
database: snorby
<<: *snorby
EOF
cd /var/www/snorby
RAILS_ENV=production bundle exec rake snorby:setup
cd
mysql -u root --password=$MYSQL_PASS -e "grant all on snorby.* to root@localhost"
mysql -u root --password=$MYSQL_PASS -e "flush privileges"
# Create startup script
cat << EOF > /etc/init.d/snorby
#!/bin/sh
#
### BEGIN INIT INFO
#Provides: snorby
#Required-Start: \$remote_fs \$syslog mysql
#Required-Stop: \$remote_fs \$syslog
#Default-Start: 2 3 4 5
#Default-Stop: 0 1 6
#X-Interactive: true
#Short-Description: Restart Snorby worker
### END INIT INFO

. /lib/init/vars.sh
. /lib/lsb/init-functions

do_start()
{
log_daemon_msg "Starting Snorby worker" ""
cd /var/www/snorby
RAILS_ENV=production bundle exec rails r Snorby::Worker.start
log_end_msg 0
return 0
}

do_stop()
{
log_daemon_msg "Stopping Snorby worker" ""
cd /var/www/snorby
RAILS_ENV=production bundle exec rails r Snorby::Worker.stop
log_end_msg 0
return 0
}

case "\$1" in
start)
do_start
;;
stop)
do_stop
;;
restart)
do_stop
do_start
;;
*)
echo "Usage: snorby {start|stop|restart}" >&2
exit 3
;;
esac
exit 0
EOF
chmod +x /etc/init.d/snorby
update-rc.d snorby defaults
insserv -f -v snorby
service snorby restart
service snortbarn restart
}


# ---------------------------------------------------------
# Function to redirect yacy and prosody traffic to tor
# ---------------------------------------------------------
services_to_tor()
{
# Define a control group for the net_cls controller
mkdir /sys/fs/cgroup/net_cls/new_route
#cd /sys/fs/cgroup/net_cls/new_route
echo 0x00110011 > /sys/fs/cgroup/net_cls/new_route/net_cls.classid

# Use iptables to fwmark packets
iptables -t mangle -A OUTPUT -m cgroup --cgroup 0x00110011 -j MARK --set-mark 1

# Declare an additional routing table for policy routing
echo 11 new_route >> /etc/iproute2/rt_tables 
ip rule add fwmark 11 table new_route
ip route add default via 10.0.10.58 table new_route

# Find PID of Yacy 
YACY_PID=ps aux | grep yacy | grep /usr/bin/java | awk '{print $2}'
#cd /sys/fs/cgroup/net_cls/new_route
echo $YACY_PID > /sys/fs/cgroup/net_cls/new_route/tasks
}


# ---------------------------------------------------------
# Function to add warning pages for clamav and squidguard
# ---------------------------------------------------------
add_warning_pages()
{
echo "Configuring warning pages ..."
# Warning page for clamav
cat << EOF > /var/www/html/virus_warning_page.html
<!DOCTYPE html>
<html>
<head>
<style>
div.container {
width: 100%;
border: 1px solid red;
}
header, footer {
padding: 1em;
color: white;
background-color: red;
clear: left;
text-align: center;
}
article {
margin-left: 170px;
border-left: 1px solid red;
padding: 1em;
overflow: hidden;
}
</style>
</head>
<body>
<div class="container">
<header>
<h1>WARNING !!!</h1>
</header>
<article>
<h1>Visiting this site may harm your computer</h1>
<p>The website you are visiting appears to host malware - software that can hurt your computer or otherwise operate without your consent.</p>
<p>Just visiting a site that contains malware can infect your computer.</p>
</article>
<footer>LibreRouter</footer>
</div>
</body>
</html>
EOF

# Warning page for squidguard
cat << EOF > /var/www/html/squidguard_warning_page.html
<!DOCTYPE html>
<html>
<head>
<style>
div.container {
width: 100%;
border: 1px solid red;
}
header, footer {
padding: 1em;
color: white;
background-color: red;
clear: left;
text-align: center;
}
article {
margin-left: 170px;
border-left: 1px solid red;
padding: 1em;
overflow: hidden;
}
</style>
</head>
<body>
<div class="container">
<header>
<h1>WARNING !!!</h1>
</header>
<article>
<h1>Security risk blocked for your protection</h1>
<p>The website category is filtered.</p>
<p>Access to the web page you were trying to visit has been blocked in accordance with security policy.</p>
</article>
<footer>LibreRouter</footer>
</div>
</body>
</html>
EOF
}


# ---------------------------------------------------------
# Function to print info about services accessibility
# ---------------------------------------------------------
print_services()
{
rm -rf /var/box_services
touch /var/box_services
echo "Printing local services info ..."
echo ""
echo "------------------------------------------------------------------------------" \
| tee /var/box_services
echo "| Service Name |       Tor domain       |    Direct access    |  IP Address  |" \
| tee -a /var/box_services
echo "------------------------------------------------------------------------------" \
| tee -a /var/box_services
for i in $(ls /var/lib/tor/hidden_service/)
do
if [ $i == "easyrtc" ]; then
IP_ADD="10.0.0.250"
fi
if [ $i == "yacy" ]; then
IP_ADD="10.0.0.251"
fi
if [ $i == "friendica" ]; then
IP_ADD="10.0.0.252"
fi
if [ $i == "owncloud" ]; then
IP_ADD="10.0.0.253"
fi
if [ $i == "mailpile" ]; then
IP_ADD="10.0.0.254"
fi
if [ $i == "ssh" ]; then
IP_ADD="10.0.0.1"
fi
if [ $i == "gitlab" ]; then
IP_ADD="10.0.0.247"
fi
if [ $i == "trac" ]; then
IP_ADD="10.0.0.248"
fi
if [ $i == "redmine" ]; then
IP_ADD="10.0.0.249"
fi
hn="$(cat /var/lib/tor/hidden_service/$i/hostname 2>/dev/null )"
printf "|%12s  |%23s |%11s.librenet |%13s |\n" $i $hn $i $IP_ADD \
| tee -a /var/box_services
done
echo "------------------------------------------------------------------------------" \
| tee -a /var/box_services

# Print i2p
echo "" | tee -a /var/box_services
echo "----------------------------------------------------------------------------" | tee -a /var/box_services
echo "| Service   |                         i2p domain                           |" | tee -a /var/box_services
echo "----------------------------------------------------------------------------" | tee -a /var/box_services
echo -n "| easyrtc   | " | tee -a /var/box_services
echo -n `ls /var/lib/i2p/i2p-config/i2ptunnel-keyBackup/ | sed '2!d' | sed s/-.*//` | tee -a /var/box_services
echo " |" | tee -a /var/box_services
echo -n "| yacy      | " | tee -a /var/box_services
echo -n `ls /var/lib/i2p/i2p-config/i2ptunnel-keyBackup/ | sed '3!d' | sed s/-.*//` | tee -a /var/box_services
echo " |" | tee -a /var/box_services
echo -n "| friendica | " | tee -a /var/box_services
echo -n `ls /var/lib/i2p/i2p-config/i2ptunnel-keyBackup/ | sed '4!d' | sed s/-.*//` | tee -a /var/box_services
echo " |" | tee -a /var/box_services
echo -n "| owncloud  | " | tee -a /var/box_services
echo -n `ls /var/lib/i2p/i2p-config/i2ptunnel-keyBackup/ | sed '5!d' | sed s/-.*//` | tee -a /var/box_services
echo " |" | tee -a /var/box_services
echo -n "| mailpile  | " | tee -a /var/box_services
echo -n `ls /var/lib/i2p/i2p-config/i2ptunnel-keyBackup/ | sed '6!d' | sed s/-.*//` | tee -a /var/box_services
echo " |" | tee -a /var/box_services
echo "----------------------------------------------------------------------------" | tee -a /var/box_services

# Create services command
cat << EOF > /usr/sbin/services
#!/bin/bash
cat /var/box_services
EOF

chmod +x /usr/sbin/services

echo "You can print local services info by \"services\" command"
sleep 2
}


# ---------------------------------------------------------
# Function to reboot librerouter
# ---------------------------------------------------------
do_reboot()
{
echo "Configuration finished !!!"
echo "Librerouter needs to restart. Do restart now? [Y/N]"
LOOP_N=0
while [ $LOOP_N -eq 0 ]; do
read ANSWER
if [ "$ANSWER" = "Y" -o "$ANSWER" = "y" ]; then
LOOP_N=1
echo "Restarting ..."
reboot
elif [ "$ANSWER" = "N" -o "$ANSWER" = "n" ]; then
LOOP_N=1
echo "Exiting ..."
else
LOOP_N=0
echo "Please type \"Y\" or \"N\""
fi
done
}


# ---------------------------------------------------------
# ************************ MAIN ***************************
# This is the main function on this script
# ---------------------------------------------------------

# Block 1: Configuing Network Interfaces

check_root			# Checking user
#get_variables			# Getting variables
get_platform			# Getting platform info
get_hardware			# Getting hardware info
get_interfaces          	# Get external and internal interfaces
get_hdd				# Getting hdd info
configure_hosts			# Configurint hostname and /etc/hosts
#configure_bridges		# Configure bridges
configure_interfaces		# Configuring external and internal interfaces
configure_dhcp			# Configuring DHCP server 


# Block 2: Configuring services

configure_mysql			# Configuring mysql password
configure_banks_access		# Configuring banks access
configure_iptables		# Configuring iptables rules
configure_tor			# Configuring TOR server
configure_i2p			# Configuring i2p services
configure_unbound		# Configuring Unbound DNS server
configure_friendica		# Configuring Friendica local service
configure_easyrtc		# Configuring EasyRTC local service
configure_owncloud		# Configuring Owncloud local service
configure_mailpile		# Configuring Mailpile local service
configure_modsecurity		# Configuring modsecurity 
configure_nginx                 # Configuring Nginx web server
configure_privoxy		# Configuring Privoxy proxy server
configure_squid			# Configuring squid proxy server
configure_c_icap		# Configuring c-icap daemon
configure_squidclamav		# Configuring squidclamav service
configure_squidguard		# Configuring squidguard
configure_squidguardmgr		# Configuring squidguardmgr
configure_ecapguardian		# Configuring ecapguardian
configure_postfix		# Configuring postfix mail service
configure_trac			# Configuring trac service
configure_redmine		# Configuring redmine service
configure_ntopng		# Configuring ntop service
configure_redsocks		# Configure redsocks proxy server
check_interfaces		# Checking network interfaces
check_services			# Checking services 
#configure_suricata		# Configure Suricata service
#configure_logstash		# Configure logstash
#configure_kibana		# Configure Kibana service
configure_gitlab 		# Configure gitlab servies (only for amd64)
#configure_snortbarn		# Configure Snort and Barnyard services
#configure_snorby		# Configure Snorby
#services_to_tor                # Redirect yacy and prosody traffic to tor
add_warning_pages		# Added warning pages for clamav and squidguard
print_services			# Print info about service accessibility
do_reboot                       # Function to reboot librerouter

#configure_blacklists		# Configuring blacklist to block some ip addresses


