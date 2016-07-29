#!/bin/bash
# ---------------------------------------------
# Variables list
# ---------------------------------------------
PROCESSOR="Not Detected"   	# Processor type (ARM/Intel/AMD)
HARDWARE="Not Detected"    	# Hardware type (Board/Physical/Virtual)
PLATFORM="Not Detected"         # Platform type	(U12/U14/D7/D8/T7)
EXT_INTERFACE="Not Detected"	# External Interface (Connected to Internet) 
INT_INETRFACE="Not Detected"	# Internal Interface (Connected to local network)

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
# check_internet
# ----------------------------------------------
check_internet () 
{
	echo "Checking Internet access ..."
	if ! ping -c1 8.8.8.8 >/dev/null 2>/dev/null; then
		echo "You need internet to proceed. Exiting"
		exit 1
	fi
}

# ----------------------------------------------
# check_root
# ----------------------------------------------
check_root ()
{
	echo "Checking user root ..."
	if [ "$(whoami)" != "root" ]; then
		echo "You need to be root to proceed. Exiting"
		exit 2
	fi
}

# ----------------------------------------------
# configure_repositories
# ----------------------------------------------
configure_repositories () 
{
	echo "Configuring repositories ... "

	# Updating date and time
	# ntpdate time.nist.gov
	
	# echo "adding unauthenticated upgrade"
	apt-get  -y --force-yes --allow-unauthenticated upgrade

	echo "
Acquire::https::dl.dropboxusercontent.com::Verify-Peer \"false\";
Acquire::https::deb.nodesource.com::Verify-Peer \"false\";
        " > /etc/apt/apt.conf.d/apt.conf 

# Preparing repositories for Ubuntu 12.04 GNU/Linux 

	if [ $PLATFORM = "U12" ]; then
		# Configuring repositories for Ubuntu 12.04
		echo "Updating repositories in Ubuntu 12.04"
#        	echo "deb http://security.ubuntu.com/ubuntu precise-security main" >> /etc/apt/sources.list
 		echo "Installing apt-transport-https ..."
		apt-get install -y --force-yes apt-transport-https 2>&1 > /tmp/apt-get-install-aptth.log
		
		# Prepare owncloud repo
		echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/ /' > /etc/apt/sources.list.d/owncloud.list
		wget http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/Release.key -O- | apt-key add -

		# Preparing yacy repo
		echo 'deb http://debian.yacy.net ./' > /etc/apt/sources.list.d/yacy.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 03D886E7
		
		# preparing i2p repo 
        	echo 'deb http://deb.i2p2.no/ precise main' >/etc/apt/sources.list.d/i2p.list
        	echo 'deb-src http://deb.i2p2.no/ precise main' >>/etc/apt/sources.list.d/i2p.list

		# preparing tor repo 
		# preparing webmin repo 
       		echo 'deb http://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
        	echo 'deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib' >> /etc/apt/sources.list.d/webmin.list
        	wget  "http://www.webmin.com/jcameron-key.asc" -O- | apt-key add -

# Preparing repositories for Ubuntu 14.04 GNU/Linux 

	elif [ $PLATFORM = "U14" ]; then
		# Configuring repositories for Ubuntu 14.04
		echo "Updating repositories in Ubuntu 14.04"
#        	echo "deb http://security.ubuntu.com/ubuntu trusty-security main" >> /etc/apt/sources.list
        	#apt-get update 2>&1 > /tmp/apt-get-update-default.log
 		echo "Installing apt-transport-https ..."
		apt-get install -y --force-yes apt-transport-https 2>&1 > /tmp/apt-get-install-aptth.log
		
		# Prepare owncloud repo
		echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/ /' > /etc/apt/sources.list.d/owncloud.list
		wget http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/Release.key -O- | apt-key add -

		# Preparing yacy repo
		echo 'deb http://debian.yacy.net ./' > /etc/apt/sources.list.d/yacy.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 03D886E7
		
		# preparing i2p repo 
        	#echo 'deb http://deb.i2p2.no/ trusty main' >/etc/apt/sources.list.d/i2p.list
        	#echo 'deb-src http://deb.i2p2.no/ trusty main' >>/etc/apt/sources.list.d/i2p.list
                echo -ne '\n' | apt-add-repository ppa:i2p-maintainers/i2p

		# preparing tor repo 
		# preparing webmin repo 
       		echo 'deb http://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
        	echo 'deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib' >> /etc/apt/sources.list.d/webmin.list
        	wget "http://www.webmin.com/jcameron-key.asc" -O- | apt-key add -

# Preparing repositories for Debian 7 GNU/Linux 

	elif [ $PLATFORM = "D7" ]; then
		# Configuring repositories for Debian 7
		echo "deb http://ftp.us.debian.org/debian wheezy main non-free contrib" > /etc/apt/sources.list
		echo "deb http://ftp.debian.org/debian/ wheezy-updates main contrib non-free" >> /etc/apt/sources.list
		echo "deb http://security.debian.org/ wheezy/updates main contrib non-free" >> /etc/apt/sources.list

		# There is a need to install apt-transport-https 
		# package before preparing third party repositories
		echo "Updating repositories ..."
	        apt-get update 2>&1 > /tmp/apt-get-update-default.log
 		echo "Installing apt-transport-https ..."
		apt-get install -y --force-yes apt-transport-https 2>&1 > /tmp/apt-get-install-aptth.log
	
		# Prepare owncloud repo
		echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/ /' > /etc/apt/sources.list.d/owncloud.list
		wget http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/Release.key -O- | apt-key add -

		# Prepare prosody repo
		# echo 'deb http://packages.prosody.im/debian wheezy main' > /etc/apt/sources.list.d/prosody.list
		# wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
 
		# Prepare tahoe repo
		echo 'deb https://dl.dropboxusercontent.com/u/18621288/debian wheezy main' > /etc/apt/sources.list.d/tahoei2p.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 8CF6E896B3C01B09
		# W: GPG error: https://dl.dropboxusercontent.com wheezy Release: The following signatures were invalid: KEYEXPIRED 1460252357
				
		# Prepare yacy repo
		echo 'deb http://debian.yacy.net ./' > /etc/apt/sources.list.d/yacy.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 03D886E7

		# Prepare i2p repo
		echo 'deb http://deb.i2p2.no/ wheezy main' > /etc/apt/sources.list.d/i2p.list
		wget --no-check-certificate https://geti2p.net/_static/i2p-debian-repo.key.asc -O- | apt-key add -

		# Prepare tor repo
		echo 'deb http://deb.torproject.org/torproject.org wheezy main'  > /etc/apt/sources.list.d/tor.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 74A941BA219EC810

		# Prepare Webmin repo
		echo 'deb http://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
		if [ -e jcameron-key.asc ]; then
			rm -r jcameron-key.asc
		fi
		wget http://www.webmin.com/jcameron-key.asc
		apt-key add jcameron-key.asc 

# Preparing repositories for Debian 8 GNU/Linux 

	elif [ $PLATFORM = "D8" ]; then
		# Avoid macchanger asking for information
		export DEBIAN_FRONTEND=noninteractive

		# Configuring Repositories for Debian 8
		echo "deb http://ftp.es.debian.org/debian/ jessie main" > /etc/apt/sources.list
		echo "deb http://ftp.es.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
		echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list

		# There is a need to install apt-transport-https 
		# package before preparing third party repositories
		echo "Updating repositories ..."
       		apt-get update 2>&1 > /tmp/apt-get-update-default.log
 		echo "Installing apt-transport-https ..."
		apt-get install -y --force-yes apt-transport-https 2>&1 > /tmp/apt-get-install-aptth.log


		# Prepare owncloud repo
		echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_8.0/ /' > /etc/apt/sources.list.d/owncloud.list
		wget http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_8.0/Release.key -O- | apt-key add -
        

		# Prepare prosody repo
#		echo 'deb http://packages.prosody.im/debian wheezy main' > /etc/apt/sources.list.d/prosody.list
#		wget https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
 
		# Prepare tahoe repo
		echo 'deb https://dl.dropboxusercontent.com/u/18621288/debian wheezy main' > /etc/apt/sources.list.d/tahoei2p.list

		# Prepare yacy repo
		echo 'deb http://debian.yacy.net ./' > /etc/apt/sources.list.d/yacy.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 03D886E7

		# Prepare i2p repo
		echo 'deb http://deb.i2p2.no/ stable main' > /etc/apt/sources.list.d/i2p.list
		wget --no-check-certificate https://geti2p.net/_static/i2p-debian-repo.key.asc -O- | apt-key add -

		# Prepare tor repo
		echo 'deb http://deb.torproject.org/torproject.org wheezy main'  > /etc/apt/sources.list.d/tor.list
		gpg --keyserver 223.252.21.101 --recv 886DDD89
		gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
		
		# Prepare Webmin repo
		echo 'deb http://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
		if [ -e jcameron-key.asc ]; then
			rm -r jcameron-key.asc
		fi
		wget http://www.webmin.com/jcameron-key.asc
		apt-key add jcameron-key.asc 

# Preparing repositories for Trisquel GNU/Linux 7.0

	elif [ $PLATFORM = "T7" ]; then
		# Avoid macchanger asking for information
		export DEBIAN_FRONTEND=noninteractive
		
		# Configuring repositories for Trisquel 7
		echo "deb http://fr.archive.trisquel.info/trisquel/ belenos main" > /etc/apt/sources.list
		echo "deb-src http://fr.archive.trisquel.info/trisquel/ belenos main" >> /etc/apt/sources.list
		echo "deb http://fr.archive.trisquel.info/trisquel/ belenos-security main" >> /etc/apt/sources.list
		echo "deb-src http://fr.archive.trisquel.info/trisquel/ belenos-security main" >> /etc/apt/sources.list
		echo "deb http://fr.archive.trisquel.info/trisquel/ belenos-updates main" >> /etc/apt/sources.list
		echo "deb-src http://fr.archive.trisquel.info/trisquel/ belenos-updates main" >> /etc/apt/sources.list

		# There is a need to install apt-transport-https 
		# package before preparing third party repositories
		echo "Updating repositories ..."
   		apt-get update 2>&1 > /tmp/apt-get-update-default.log

		if [ $? -ne 0 ]; then
			echo "ERROR: UNABLE TO UPDATE REPOSITORIES"
			exit 10
		else
			echo "Updating done successfully"
		fi
	
 		echo "Installing apt-transport-https ..."
		apt-get install -y --force-yes apt-transport-https 2>&1 > /tmp/apt-get-install-aptth.log

		if [ $? -ne 0 ]; then
			echo "ERROR: UNABLE TO INSTALL PACKAGES: apt-transport-https"
			exit 11
		else 
			echo "Installation done successfully"
		fi

		echo "Preparing third party repositories ..."
		
		# Prepare yacy repo
		echo 'deb http://debian.yacy.net ./' > /etc/apt/sources.list.d/yacy.list
		apt-key advanced --keyserver pgp.net.nz --recv-keys 03D886E7

		# Prepare i2p repo
		echo 'deb http://deb.i2p2.no/ stable main' > /etc/apt/sources.list.d/i2p.list
		wget --no-check-certificate https://geti2p.net/_static/i2p-debian-repo.key.asc -O- | apt-key add -
	
		# Prepare tahoe repo
		echo 'deb https://dl.dropboxusercontent.com/u/18621288/debian wheezy main' > /etc/apt/sources.list.d/tahoei2p.list
		
		# Prepare tor repo
		echo 'deb http://deb.torproject.org/torproject.org wheezy main'  > /etc/apt/sources.list.d/tor.list
		gpg --keyserver 223.252.21.101 --recv 886DDD89
		gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

		# Prepare Webmin repo
		echo 'deb http://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
		if [ -e jcameron-key.asc ]; then
			rm -r jcameron-key.asc
		fi
		wget http://www.webmin.com/jcameron-key.asc
		apt-key add jcameron-key.asc 

	else 
		echo "ERROR: UNKNOWN PLATFORM" 
		exit 4
	fi
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

	EXT_BR_INT=`echo $EXT_INTERFACE | head -c 4`
       	INT_BR_INT=`echo $INT_INTERFACE | head -c 4`

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


# ----------------------------------------------
# install_packages
# ----------------------------------------------
install_packages () 
{
	echo "Updating repositories packages ... "
	apt-get update 2>&1 > /tmp/apt-get-update.log
	echo "Installing packages ... "

# Installing Packages for Debian 7 GNU/Linux

if [ $PLATFORM = "D7" ]; then
	apt-get install -y --force-yes privoxy nginx php5-common \
	php5-fpm php5-cli php5-json php5-mysql php5-curl php5-intl \
	php5-mcrypt php5-memcache php-xml-parser php-pear unbound owncloud \
	node npm apache2-mpm-prefork- apache2-utils- apache2.2-bin- \
	apache2.2-common- openjdk-7-jre-headless phpmyadmin php5 \
	mysql-server php5-gd php5-imap smarty3 git ntpdate macchanger \
	bridge-utils hostapd isc-dhcp-server hostapd bridge-utils \
	curl macchanger ntpdate tor bc sudo lsb-release dnsutils \
	ca-certificates-java openssh-server ssh wireless-tools usbutils \
	unzip debian-keyring subversion build-essential libncurses5-dev \
	i2p i2p-keyring yacy virtualenv pwgen \
        killyourtv-keyring  i2p-tahoe-lafs \
	c-icap clamav  clamav-daemon  gcc make libcurl4-gnutls-dev libicapapi-dev \
	deb.torproject.org-keyring u-boot-tools console-tools \
        gnupg openssl python-virtualenv python-pip python-lxml git \
        libjpeg62-turbo libjpeg62-turbo-dev zlib1g-dev python-dev webmin \
        postfix mailutils \
	2>&1 > /tmp/apt-get-install.log
 	
	# Setting MySQL password
	MYSQL_PASS=`pwgen 10 1`
	echo mysql-server mysql-server/root_password password $MYSQL_PASS \
	| debconf-set-selections
	echo mysql-server mysql-server/root_password_again password \
	$MYSQL_PASS | debconf-set-selections

	# Installing MySQL server package
 	apt-get install -y --force-yes mysql-server

# Installing Packages for Debian 8 GNU/Linux

elif [ $PLATFORM = "D8" ]; then
	apt-get install -y --force-yes privoxy nginx php5-common \
        php5-fpm php5-cli php5-json php5-mysql php5-curl php5-intl \
        php5-mcrypt php5-memcache php-xml-parser php-pear unbound owncloud \
	node npm apache2-mpm-prefork- apache2-utils- apache2.2-bin- \
	apache2.2-common- openjdk-7-jre-headless phpmyadmin php5 \
	php5-gd php5-imap smarty3 git ntpdate macchanger \
	bridge-utils hostapd isc-dhcp-server hostapd bridge-utils \
	curl macchanger ntpdate tor bc sudo lsb-release dnsutils \
	ca-certificates-java openssh-server ssh wireless-tools usbutils \
	unzip debian-keyring subversion build-essential libncurses5-dev \
	i2p i2p-keyring yacy virtualenv pwgen gcc make \
        killyourtv-keyring i2p-tahoe-lafs \
	c-icap clamav  clamav-daemon libcurl4-gnutls-dev libicapapi-dev \
	deb.torproject.org-keyring u-boot-tools php-zeta-console-tools \
        gnupg openssl python-virtualenv python-pip python-lxml git \
	libjpeg62-turbo libjpeg62-turbo-dev zlib1g-dev python-dev webmin \
        postfix mailutils squid3 \
	libssl-dev perl screen \
        libxml2-dev libxslt1-dev python-jinja2 python-pgpdump spambayes \
	2>&1 > /tmp/apt-get-install1.log

	# Setting MySQL password
	MYSQL_PASS=`pwgen 10 1`
	echo mysql-server mysql-server/root_password password $MYSQL_PASS \
	| debconf-set-selections
	echo mysql-server mysql-server/root_password_again password \
	$MYSQL_PASS | debconf-set-selections

	# Installing MySQL server package
 	apt-get install -y --force-yes mysql-server

# Installing Packages for Trisquel 7.0 GNU/Linux

elif [ $PLATFORM = "T7" ]; then
	apt-get install -y --force-yes privoxy nginx php5-common \
	php5-fpm php5-cli php5-json php5-mysql php5-curl php5-intl \
	php5-mcrypt php5-memcache php-xml-parser php-pear unbound owncloud \
	node npm apache2-mpm-prefork- apache2-utils- apache2.2-bin- \
	apache2.2-common- openjdk-7-jre-headless phpmyadmin php5 \
	php5-gd php5-imap smarty3 git ntpdate macchanger \
	bridge-utils hostapd isc-dhcp-server hostapd bridge-utils \
	curl macchanger ntpdate tor bc sudo lsb-release dnsutils \
	ca-certificates-java openssh-server ssh wireless-tools usbutils \
	unzip debian-keyring subversion build-essential libncurses5-dev \
	i2p i2p-keyring yacy virtualenv pwgen \
	killyourtv-keyring i2p-tahoe-lafs \
	c-icap clamav  clamav-daemon  gcc make libcurl4-gnutls-dev libicapapi-dev \
	deb.torproject.org-keyring u-boot-tools console-setup \
        gnupg openssl python-virtualenv python-pip python-lxml git \
        libjpeg62-turbo libjpeg62-turbo-dev zlib1g-dev python-dev \
        postfix mailutils \
	2>&1 > /tmp/apt-get-install.log

	# Setting MySQL password
	MYSQL_PASS=`pwgen 10 1`
	echo mysql-server mysql-server/root_password password $MYSQL_PASS \
	| debconf-set-selections
	echo mysql-server mysql-server/root_password_again password \
	$MYSQL_PASS | debconf-set-selections

	# Installing MySQL server package
 	apt-get install -y --force-yes mysql-server

# Installing Packages for Ubuntu 14.04 GNU/Linux

elif [ $PLATFORM = "U14" -o $PLATFORM = "U12" ]; then
	apt-get install -y --force-yes pwgen debconf-utils privoxy nginx php5-common \
	php5-fpm php5-cli php5-json php5-mysql php5-curl php5-intl \
	php5-mcrypt php5-memcache php-xml-parser php-pear unbound owncloud \
	node npm apache2-mpm-prefork- apache2-utils- apache2.2-bin- \
	apache2.2-common- openjdk-7-jre-headless phpmyadmin php5 \
	mysql-server-5.6 php5-gd php5-imap smarty3 git ntpdate macchanger \
	bridge-utils hostapd isc-dhcp-server hostapd bridge-utils \
	curl macchanger ntpdate tor bc sudo lsb-release dnsutils \
	ca-certificates-java openssh-server ssh wireless-tools usbutils \
	unzip debian-keyring subversion build-essential libncurses5-dev \
	i2p yacy tahoe-lafs \
	c-icap clamav  clamav-daemon  gcc make libcurl4-gnutls-dev libicapapi-dev \
	u-boot-tools console-tools* \
        gnupg openssl python-virtualenv python-pip python-lxml git \
         zlib1g-dev python-dev webmin \
        postfix mailutils \
	2>&1 > /tmp/apt-get-install.log
	
	# Setting MySQL password
	MYSQL_PASS=`pwgen 10 1`
	echo mysql-server mysql-server/root_password password $MYSQL_PASS \
	| debconf-set-selections
	echo mysql-server mysql-server/root_password_again password \
	$MYSQL_PASS | debconf-set-selections

	# Installing MySQL server package
 	apt-get install -y --force-yes mysql-server

fi
	if [ $? -ne 0 ]; then
		echo "ERROR: unable to install packages"
		exit 3
	fi

# Getting classified domains list from shallalist.de
if [ ! -e shallalist.tar.gz ]; then
	echo "Getting classified domains list ..."
	wget http://www.shallalist.de/Downloads/shallalist.tar.gz
	if [ $? -ne 0 ]; then
       		echo "Error: Unable to download domain list. Exithing"
       		exit 5
	fi
fi

# Getting Friendica 
echo "Getting Friendica ..."
if [ ! -e  /var/www/friendica ]; then
	cd /var/www
	git clone https://github.com/friendica/friendica.git
	cd friendica
	git clone https://github.com/friendica/friendica-addons.git addon

	chown -R www-data:www-data /var/www/friendica/view/smarty3
	chmod g+w /var/www/friendica/view/smarty3
	touch /var/www/friendica/.htconfig.php
	chown www-data:www-data /var/www/friendica/.htconfig.php
	chmod g+rwx /var/www/friendica/.htconfig.php
fi

}

# ----------------------------------------------
# This function checks hardware 
# Hardware can be.
# 1. ARM for odroid board.
# 2. INTEL or AMD for Physical/Virtual machine.
# Function gets Processor and Hardware types and saves
# them in PROCESSOR and HARDWARE variables.
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

        # Printing Processor and Hardware types     

	echo "Processor: $PROCESSOR"
        echo "Hardware: $HARDWARE"
}

# ----------------------------------------------
# This script checks requirements for Physical 
# Machines.
# 
#  Minimum requirements are:
#
#  * 2 Network Interfaces.
#  * 1 GB Physical Memory (RAM).
#  * 16 GB Free Space On Hard Drive.
#
# ----------------------------------------------
check_requirements()
{
	echo "Checking requirements ..."

        # This variable contains network interfaces quantity.  
	NET_INTERFACES=`ls /sys/class/net/ | grep -w 'eth0\|eth1\|wlan0\|wlan1' | wc -l`

        # This variable contains total physical memory size.
        MEMORY=`grep MemTotal /proc/meminfo | awk '{print $2}'`
	
	# This variable contains total free space on root partition.
	STORAGE=`df -h / | grep -w "/" | awk '{print $4}' | sed 's/[^0-9.]*//g'`
        
        # Checking network interfaces quantity.
	if [ $NET_INTERFACES -le 1 ]; then
        	echo "You need at least 2 network interfaces. Exiting"
		exit 4 
        fi
	
	# Checking physical memory size.
        if [ $MEMORY -le 900000 ]; then 
		echo "You need at least 1GB of RAM. Exiting"
                exit 5
        fi

	# Checking free space. 
	MIN_STORAGE=16
	STORAGE2=`echo $STORAGE | awk -F. {'print $1'}`
	if [ $STORAGE2 -lt $MIN_STORAGE ]; then
		echo "You need at least 16GB of free space. Exiting"
		exit 6
	fi
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
get_dhcp_and_Internet()
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

# ----------------------------------------------
# This scripts check odroid board to find out if
# it assembled or not.
# There are list of additional modules that need
# to be connected to board.
# Additional modules are.
# 	1. ssd 8gbc10
#	2. HDD 2TB
#	3. 2xWlan interfaces
#	4. TFT screen
# ----------------------------------------------
check_assemblance()
{
	echo "Checking assemblance ..."
	
	echo "Checking network interfaces ..."  
	# Script should detect 4 network 
	# interfaces.
	# 1. eth0
	# 2. eth1
	# 3. wlan0
	# 4. wlan1
	if   ! ls /sys/class/net/ | grep -w 'eth0'; then
		echo "Error: Interface eth0 is not connected. Exiting"
		exit 8
	elif ! ls /sys/class/net/ | grep -w 'eth1'; then
		echo "Error: Interface eth1 is not connected. Exiting"
		exit 9
	elif ! ls /sys/class/net/ | grep -w 'wlan0'; then
		echo "Error: Interface wlan0 is not connected. Exiting"
		exit 10
	elif ! ls /sys/class/net/ | grep -w 'wlan1'; then
		echo "Error: Interface wlan1 is not connected. Exiting"
		exit 11  
	fi
	echo "Network interfaces checking finished. OK"

	echo ""


}


# ----------------------------------------------
# Function to install mailpile package
# ----------------------------------------------
install_mailpile() {
git clone --recursive https://github.com/mailpile/Mailpile.git /opt/Mailpile
virtualenv -p /usr/bin/python2.7 --system-site-packages /opt/Mailpile/mailpile-env
source /opt/Mailpile/mailpile-env/bin/activate
pip install -r /opt/Mailpile/requirements.txt
}


# ----------------------------------------------
# Function to install EasyRTC package
# ----------------------------------------------
install_easyrtc() 
{
echo "Installing EasyRTC package ..."

# Creating home folder for EasyRTC 
if [ -e /opt/easyrtc ]; then
	rm -r /opt/easyrtc
fi
mkdir /opt/easyrtc

# Installing Node.js
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y --force-yes nodejs

# Getting EasyRTC files
wget --no-check-certificate https://easyrtc.com/assets/files/easyrtc_server_example.zip
unzip easyrtc_server_example.zip -d /opt/easyrtc
rm -r easyrtc_server_example.zip

# Downloading the required dependencies
cd /opt/easyrtc
npm install
cd
}


# ----------------------------------------------
# Function to install squid
# ----------------------------------------------
install_squid()
{
echo "Installing squid dependences ..."
aptitude build-dep squid

echo "Downloading squid ..."
wget -P /tmp/ http://www.squid-cache.org/Versions/v3/3.4/squid-3.4.13.tar.gz
tar zxvf /tmp/squid-3.4.13.tar.gz

echo "Building squid ..."
cd /root/squid-3.4.13
./configure --with-openssl --enable-ssl --enable-ssl-crtd --with-default-user=squid 
make
make install
cd
}


# ----------------------------------------------
# Function to install SquidClamav
# ----------------------------------------------
install_squidclamav()
{
echo "Downloading squidclamav ..."
wget -P /tmp/ http://downloads.sourceforge.net/project/squidclamav/squidclamav/6.15/squidclamav-6.15.tar.gz 
tar zxvf /tmp/squidclamav-6.15.tar.gz 
cd /root/squidclamav-6.15 

echo "Building squidclamav ..."
./configure --with-c-icap 
make
make install
cd

# Creating configuration file
if [ -e /etc/squidclamav.conf ]; then
rm -rf /etc/squidclamav.conf
fi
ln -s /etc/c-icap/squidclamav.conf /etc/squidclamav.conf 

}


# ----------------------------------------------
# This function saves variables in file, so
# parametization script can read and use these 
# values
# Variables to save are:
#   PLATFORM
#   HARDWARE
#   PROCESSOR
#   EXT_INTERFACE
#   INT_INTERFACE
# ----------------------------------------------  
save_variables()
{
        echo "Saving variables ..."
        echo -e \
"Platform: $PLATFORM\n\
Hardware: $HARDWARE\n\
Processor: $PROCESSOR\n\
Ext_interface: $EXT_INTERFACE\n\
Int_interface: $INT_INTERFACE\n\
DB_PASS: $MYSQL_PASS" \
                 > /var/box_variables
        if [ $? -ne  0 ]; then
                echo "Error: Unable to save variables. Exiting"
                exit 11
        fi
}



# ----------------------------------------------
# MAIN 
# ----------------------------------------------
# This is the main function of this script.
# It uses functions defined above to check user,
# Platform, Hardware, System requirements and 
# Internet connection. Then it downloads
# installs all neccessary packages.
# ----------------------------------------------
#
# ----------------------------------------------
# At first script will check
#
# 1. User      ->  Need to be root
# 2. Platform  ->  Need to be Debian 7 / Debian 8 / Ubuntu 12.04 / Ubuntu 14.04 
# 3. Hardware  ->  Need to be ARM / Intel or AMD
# ----------------------------------------------
check_root    	# Checking user 
get_platform  	# Getting platform info
get_hardware  	# Getting hardware info
# ----------------------------------------------
# If script detects Physical/Virtual machine
# then next steps will be
# 
# 4. Checking requirements
# 5. Get Internet access
# 6. Configure repositories
# 7. Download and Install packages
# ----------------------------------------------
if [ "$PROCESSOR" = "Intel" -o "$PROCESSOR" = "AMD" -o "$PROCESSOR" = "ARM" ]; then 
	check_internet          # Check Internet access
#	check_assemblance
#	check_requirements      # Checking requirements for 
	configure_bridges       # Configure bridge interfacers
				# Physical or Virtual machine
        get_dhcp_and_Internet  	# Get DHCP on eth0 or eth1 and 
				# connect to Internet
	configure_repositories	# Prepare and update repositories
	install_packages       	# Download and install packages	
	install_mailpile	# Install Mailpile package
	install_easyrtc		# Install EasyRTC package
	#install_squid		# Install squid package
	install_squidclamav	# install SquidClamav package
        save_variables	        # Save detected variables

# ---------------------------------------------
# If script detects odroid board then next 
# steps will be
#
# 4. Checking if board is assembled
# 5. Configure bridge interfaces
# 6. Check Internet Connection
# 7. Configure repositories
# 8. Download and Install packages
# ---------------------------------------------
#elif [ "$PROCESSOR" = "ARM" ]; then 
	#check_assemblance
	#configure_bridges      # Configure bridge interfacers
	#check_internet         # Check Internet access
        #get_dhcp_and_Internet  # Get DHCP on eth0 or eth1 and 
				# connect to Internet
	#configure_repositories # Prepare and update repositories
	#install_packages       # Download and install packages
	#install_mailpile	# Install Mailpile package
	#install_easyrtc	# Install EasyRTC package
	#install_squid		# Install squid package
	#install_squidclamav	# install SquidClamav package
	#save_variables	        # Save detected variables
fi

# ---------------------------------------------
# If script reachs to this point then it's done 
# successfully
# ---------------------------------------------
echo "Initialization done successfully"

exit 
