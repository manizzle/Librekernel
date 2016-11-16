#!/bin/bash
# ---------------------------------------------
# Variables list
# ---------------------------------------------
PROCESSOR="Not Detected"   	# Processor type (ARM/Intel/AMD)
HARDWARE="Not Detected"    	# Hardware type (Board/Physical/Virtual)
PLATFORM="Not Detected"         # Platform type	(U12/U14/D7/D8/T7)
EXT_INTERFACE="Not Detected"	# External Interface (Connected to Internet) 
INT_INTERFACE="Not Detected"	# Internal Interface (Connected to local network)


# ----------------------------------------------
# Env Variables
# ----------------------------------------------
export GIT_SSL_NO_VERIFY=true
export INSTALL_HOME=`pwd`
export DEBIAN_FRONTEND=noninteractive


#----------------------------------------------
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
	echo "Time sync ..."
	
	# Installing ntpdate package
	apt-get update > /dev/null
	apt-get -y --force-yes install ntpdate > /dev/null
	
	# Time synchronization
	/etc/init.d/ntp stop > /dev/null 2>&1
 	ntpdate -s ntp.ubuntu.com
	if [ $? -ne 0 ]; then
        	echo "Error: unable to set time"
                exit 3
        fi	
	/etc/init.d/ntp restart > /dev/null 2>&1
	echo "Date and time have been set"
	date	
	
	
	echo "Configuring repositories ... "

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
		if [ $? -ne 0 ]; then
			echo "Error: Unable to install apt-transport-https"
			exit 3
		fi
		
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
		if [ $? -ne 0 ]; then
			echo "Error: Unable to install apt-transport-https"
			exit 3
		fi
		
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
		if [ $? -ne 0 ]; then
			echo "Error: Unable to install apt-transport-https"
			exit 3
		fi
	
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
		#echo "deb http://ftp.es.debian.org/debian/ jessie main" > /etc/apt/sources.list
		#echo "deb http://ftp.es.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
		#echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
		cat << EOF >  /etc/apt/sources.list
deb http://ftp.debian.org/debian jessie main contrib non-free
deb http://ftp.debian.org/debian jessie-updates main contrib non-free
deb http://security.debian.org jessie/updates main contrib non-free
deb http://ftp.debian.org/debian jessie-backports main contrib non-free
deb-src http://ftp.debian.org/debian jessie main contrib non-free
deb-src http://ftp.debian.org/debian jessie-updates main contrib non-free
deb-src http://security.debian.org jessie/updates main contrib non-free
deb-src http://ftp.debian.org/debian jessie-backports main contrib non-free
EOF

		# There is a need to install apt-transport-https 
		# package before preparing third party repositories
		echo "Updating repositories ..."
       		apt-get update 2>&1 > /tmp/apt-get-update-default.log
 		echo "Installing apt-transport-https ..."
		apt-get install -y --force-yes apt-transport-https 2>&1 > /tmp/apt-get-install-aptth.log
		if [ $? -ne 0 ]; then
			echo "Error: Unable to install apt-transport-https"
			exit 3
		fi

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
		echo 'deb http://deb.torproject.org/torproject.org jessie main'  > /etc/apt/sources.list.d/tor.list
		gpg --keyserver pgp.net.nz --recv 886DDD89
		gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
		
		# Prepare Webmin repo
		echo 'deb http://download.webmin.com/download/repository sarge contrib' > /etc/apt/sources.list.d/webmin.list
		if [ -e jcameron-key.asc ]; then
			rm -r jcameron-key.asc
		fi
		wget http://www.webmin.com/jcameron-key.asc
		apt-key add jcameron-key.asc 

		# Prepare kibaba repo
		wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
		echo "deb https://packages.elastic.co/kibana/4.6/debian stable main" > /etc/apt/sources.list.d/kibana.list

		# Prepare lohstash repo
		wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
		echo "deb https://packages.elastic.co/logstash/2.4/debian stable main" > /etc/apt/sources.list.d/elastic.list

	
		# Prepare backports repo (suricata, roundcube)
#		echo 'deb http://ftp.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list

		# Prepare bro repo
#		wget http://download.opensuse.org/repositories/network:bro/Debian_8.0/Release.key -O- | apt-key add -
#		echo 'deb http://download.opensuse.org/repositories/network:/bro/Debian_8.0/ /' > /etc/apt/sources.list.d/bro.list

		# Prepare elastic repo
#		wget https://packages.elastic.co/GPG-KEY-elasticsearch -O- | apt-key add -
#		echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" > /etc/apt/sources.list.d/kibana.list
#		echo "deb https://packages.elastic.co/logstash/2.3/debian stable main" > /etc/apt/sources.list.d/logstash.list
#		echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elastic.list

		# Prepare passenger repo
#		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
#		echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main" > /etc/apt/sources.list.d/passenger.list

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
		gpg --keyserver pgp.net.nz --recv 886DDD89
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
# install_packages
# ----------------------------------------------
install_packages() 
{
	echo "Updating repositories packages ... "
	apt-get update 2>&1 > /tmp/apt-get-update.log
	echo "Installing packages ... "

# Installing Packages for Debian 7 GNU/Linux

if [ $PLATFORM = "D7" ]; then
	DEBIAN_FRONTEND=noninteractive 
	apt-get install -y --force-yes \
	privoxy nginx php5-common \
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
        killyourtv-keyring  i2p-tahoe-lafs squidguard \
	c-icap clamav  clamav-daemon  gcc make libcurl4-gnutls-dev libicapapi-dev \
	deb.torproject.org-keyring u-boot-tools console-tools \
        gnupg openssl python-virtualenv python-pip python-lxml git \
        libjpeg62-turbo libjpeg62-turbo-dev zlib1g-dev python-dev webmin \
        postfix mailutils aptitude \
	2>&1 > /tmp/apt-get-install.log

# Installing Packages for Debian 8 GNU/Linux

elif [ $PLATFORM = "D8" ]; then
	DEBIAN_FRONTEND=noninteractive
 	
	# libs and tools
	apt-get install -y --force-yes \
        php5-common php5-fpm php5-cli php5-json php5-mysql \
        php5-curl php5-intl php5-mcrypt php5-memcache \
        php-xml-parser php-pear phpmyadmin php5 mailutils \
        apache2- apache2-mpm-prefork- apache2-utils- apache2.2-bin- \
        apache2.2-common- openjdk-7-jre-headless uwsgi \
        php5-gd php5-imap smarty3 git ntpdate macchanger \
        bridge-utils hostapd hostapd bridge-utils librrd-dev \
        curl macchanger ntpdate bc sudo lsb-release dnsutils \
        ca-certificates-java openssh-server ssh wireless-tools usbutils \
        unzip debian-keyring subversion build-essential libncurses5-dev \
        i2p-keyring virtualenv pwgen gcc g++ make automake \
        killyourtv-keyring i2p-tahoe-lafs libcurl4-gnutls-dev \
        libicapapi-dev libssl-dev perl screen aptitude \
        deb.torproject.org-keyring u-boot-tools php-zeta-console-tools \
        gnupg openssl python-virtualenv python-pip python-lxml git \
        libjpeg62-turbo libjpeg62-turbo-dev zlib1g-dev python-dev \
        libxml2-dev libxslt1-dev python-jinja2 python-pgpdump spambayes \
        flex bison libpcap-dev libnet1-dev libpcre3-dev iptables-dev \
        libnetfilter-queue-dev libdumbnet-dev autoconf rails \
        roundcube-mysql roundcube-plugins ntop libndpi-bin \
        argus-server argus-client libnids-dev flow-tools libfixbuf3 \
        libgd-perl libgd-graph-perl rrdtool librrd-dev librrds-perl \
        libsqlite3-dev libtool elasticsearch conky ruby bundler \
        pmacct tomcat7 dpkg-dev devscripts javahelper openjdk-7-jdk ant \
        librrds-perl libapache2-mod-php5- apache2-prefork-dev \
        libmysqlclient-dev wkhtmltopdf libpcre3 mysql-server \
	mysql-client-5.5 \
        2>&1 > /tmp/apt-get-install_1.log

	# services
	apt-get install -y --force-yes \
        privoxy unbound owncloud isc-dhcp-server \
        yacy c-icap clamav clamav-daemon  squidguard postfix \
	tor i2p roundcube tinyproxy prosody \
        2>&1 > /tmp/apt-get-install_2.log

        #bro passenger logstash kibana nginx nginx-extras libcurl4-openssl-dev \

# Installing Packages for Trisquel 7.0 GNU/Linux

elif [ $PLATFORM = "T7" ]; then
	DEBIAN_FRONTEND=noninteractive 
	apt-get install -y --force-yes \
	privoxy nginx php5-common \
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
	killyourtv-keyring i2p-tahoe-lafs squidguard \
	c-icap clamav  clamav-daemon  gcc make libcurl4-gnutls-dev libicapapi-dev \
	deb.torproject.org-keyring u-boot-tools console-setup \
        gnupg openssl python-virtualenv python-pip python-lxml git \
        libjpeg62-turbo libjpeg62-turbo-dev zlib1g-dev python-dev \
        postfix mailutils aptitude \
	2>&1 > /tmp/apt-get-install.log

# Installing Packages for Ubuntu 14.04 GNU/Linux

elif [ $PLATFORM = "U14" -o $PLATFORM = "U12" ]; then
	DEBIAN_FRONTEND=noninteractive 
	apt-get install -y --force-yes \
	pwgen debconf-utils privoxy nginx php5-common \
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
	c-icap clamav  clamav-daemon  gcc make libcurl4-gnutls-dev \
	libicapapi-dev u-boot-tools console-tools* squidguard \
        gnupg openssl python-virtualenv python-pip python-lxml git \
         zlib1g-dev python-dev webmin \
        postfix mailutils aptitude \
	2>&1 > /tmp/apt-get-install.log
fi
	if [ $? -ne 0 ]; then
		echo "Error: unable to install packages"
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
	if [ $? -ne 0 ]; then
		echo "Error: unable to download friendica"
		exit 3
	fi
	cd friendica
	git clone https://github.com/friendica/friendica-addons.git addon
	if [ $? -ne 0 ]; then
		echo "Error: unable to download friendica addons"
		exit 3
	fi

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
	
	# Detecting Architecture
 	ARCH=`uname -m`

        # Printing Processor Hardware and Architecture types     

	echo "Processor: $PROCESSOR"
        echo "Hardware: $HARDWARE"
	echo "Architecture: $ARCH"

}


# ----------------------------------------------
# This script checks requirements for Physical 
# Machines.
# 
#  Minimum requirements are:
#
#  * 2 Network Interfaces.
#  * 4 GB Physical Memory (RAM).
#  * 16 GB Free Space On Hard Drive.
#
# ----------------------------------------------
check_requirements()
{
	echo "Checking requirements ..."

        # This variable contains network interfaces quantity.  
	# NET_INTERFACES=`ls /sys/class/net/ | grep -w 'eth0\|eth1\|wlan0\|wlan1' | wc -l`

        # This variable contains total physical memory size.
	echo -n "Physical memory size: "
        MEMORY=`grep MemTotal /proc/meminfo | awk '{print $2}'`
	echo "$MEMORY KB"	

	# This variable contains total free space on root partition.
	echo -n "Root partition size: "
	STORAGE=`df / | grep -w "/" | awk '{print $4}'`
	echo "$STORAGE KB" 	
       
        # Checking network interfaces quantity.
	# if [ $NET_INTERFACES -le 1 ]; then
        #	echo "You need at least 2 network interfaces. Exiting"
        #	exit 4 
        # fi
	
	# Checking physical memory size.
        if [ $MEMORY -le 3600000 ]; then 
		echo "You need at least 4GB of RAM. Exiting"
                exit 5
        fi

	# Checking free space. 
	MIN_STORAGE=12000000
	STORAGE2=`echo $STORAGE | awk -F. {'print $1'}`
	if [ $STORAGE2 -lt $MIN_STORAGE ]; then
		echo "You need at least 16GB of free space. Exiting"
		exit 6
	fi
	sleep 1
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
# Function to install libressl
# ----------------------------------------------
install_libressl()
{
        echo "Installing libressl ..."

        if [ ! -e libressl-2.4.2 ]; then
        echo "Downloading libressl ..."
        cd $INSTALL_HOME
        wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.4.2.tar.gz
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download libressl"
                        exit 3
                fi
        tar -xzf libressl-2.4.2.tar.gz
        fi

        echo "Building libressl ..."
        cd $INSTALL_HOME

        cd libressl-2.4.2/
        ./configure
        make &&  make install 

        if [ $? -ne 0 ]; then
                echo "Error: unable to install libressl. Exiting ..."
                exit 3
        fi
        cd ../

        # Cleanup
        rm -rf libressl-2.4.2.tar.gz
}


# ----------------------------------------------
# Function to install modsecurity
# ----------------------------------------------
install_modsecurity()
{
        echo "Installing modsecurity ..."

        if [ ! -e /usr/src/modsecurity ]; then
        echo "Downloading modsecurity ..."
        cd /usr/src/
        git clone https://github.com/SpiderLabs/ModSecurity.git modsecurity
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download modsecurity. Exiting ..."
                        exit 3
                fi
        fi

        echo "Building modsecurity ..."
        cd /usr/src/modsecurity

        ./autogen.sh
        ./configure --enable-standalone-module --disable-mlogc
        make

        if [ $? -ne 0 ]; then
                echo "Error: unable to install modsecurity. Exiting ..."
                exit 3
        fi

        # Downloading the OWASP Core Rule Set
        cd /usr/src/
        git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
        cd owasp-modsecurity-crs
        cp -R base_rules/ /etc/nginx/

        cd $INSTALL_HOME
}


# -----------------------------------------------
# Function to install ssl certificates
# -----------------------------------------------
install_certificates()
{
        echo "Installing certificates ..."
        if [ ! -e certs ]; then
                echo "Downloading certificates ..."
                svn co https://github.com/Librerouter/Librekernel/trunk/certs
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download certificates. Exiting ..."
                        exit 3
                fi
        fi

        # Moving certificates to nginx directory
        rm -rf /etc/ssl/nginx/*
        mv certs/* /etc/ssl/nginx/

        # Cleanup
        rm -rf certs
}


# ----------------------------------------------
# Function to install nginx
# ----------------------------------------------
install_nginx()
{
        echo "Installing nginx ..."

        if [ ! -e nginx-1.8.0 ]; then
        echo "Downloading nginx ..."
        cd $INSTALL_HOME
        wget http://nginx.org/download/nginx-1.8.0.tar.gz
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download nginx. Exiting ..."
                        exit 3
                fi
        tar -xzf nginx-1.8.0.tar.gz
        fi

        echo "Building nginx ..."
        cd $INSTALL_HOME
	
	mkdir /etc/nginx/
	mkdir /var/log/nginx
	touch /var/run/nginx.lock
	touch /var/run/nginx.pid
	touch /var/log/nginx/error.log
	touch /var/log/nginx/access.log
	touch /etc/nginx/nginx.conf	

        cd nginx-1.8.0/
	./configure \
	  --prefix=/etc/nginx \
	  --pid-path=/var/run/nginx.pid \
	  --conf-path=/etc/nginx/nginx.conf \
	  --lock-path=/var/run/nginx.lock \
	  --sbin-path=/usr/sbin/nginx \
	  --error-log-path=/var/log/nginx/error.log \
	  --http-log-path=/var/log/nginx/access.log \
	  --with-http_gzip_static_module \
	  --with-http_stub_status_module \
	  --user=www-data \
	  --group=www-data \
	  --with-debug \
	  --with-http_ssl_module \
	  --add-module=/usr/src/modsecurity/nginx/modsecurity
        make &&  make install

        if [ $? -ne 0 ]; then
                echo "Error: unable to install nginx. Exiting ..."
                exit 3
        fi
        cd ../

        # Cleanup
        rm -rf nginx-1.8.0.tar.gz 

# systemd script for Nginx
cat << EOF > /lib/systemd/system/nginx.service
[Service]
Type=forking
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
KillStop=/usr/local/nginx/sbin/nginx -s stop

KillMode=process
Restart=on-failure
RestartSec=42s

PrivateTmp=true
LimitNOFILE=200000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
}


# ----------------------------------------------
# Function to install mailpile package
# ----------------------------------------------
install_mailpile() 
{
	echo "Installing Mailpile ..."
 	if [ ! -e /opt/Mailpile ]; then
                echo "Downloading mailpile ..." 
        	git clone --recursive \
		https://github.com/mailpile/Mailpile.git /opt/Mailpile
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download Mailpile. Exiting ..."
                        exit 3
                fi

	fi
	virtualenv -p /usr/bin/python2.7 --system-site-packages /opt/Mailpile/mailpile-env
	source /opt/Mailpile/mailpile-env/bin/activate
	pip install -r /opt/Mailpile/requirements.txt
	if [ $? -ne 0 ]; then
		echo "Error: unable to install Mailpile. Exiting ..."
		exit 3
	fi
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
	
	# Installing Node.js
	curl -sL https://deb.nodesource.com/setup | bash -
	apt-get install -y --force-yes nodejs
	if [ $? -ne 0 ]; then
		echo "Error: unable to install Node"
		exit 3
	fi

	# Getting EasyRTC 
	if [ ! -e easyrtc ]; then
		echo "Downloading EasyRTC ..."
		git clone --recursive \
       		https://github.com/priologic/easyrtc 
	        if [ $? -ne 0 ]; then
                echo "Error: Unable to download EasyRTC. Exiting ..."
                exit 3
 	        fi
	fi
	
	# Moving server_example to /opt
	cp -r easyrtc /opt/
	
	# Downloading the required dependencies
	cd /opt/easyrtc
	npm install
	cd /opt/easyrtc/server_example/
	npm install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install EasyRTC. Exiting"
		exit 3
	fi
	cd $INSTALL_HOME
}


# ---------------------------------------------------------
# Function to install hublin
# ---------------------------------------------------------
install_hublin()
{
        echo "installing hublin ..."

        # Install nvm
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

        source ~/.bashrc

        # Install node 0.10
        nvm install 0.10
        nvm use 0.10

        if [ ! -e meetings ]; then
                echo "Downloading hublin ..."
                git clone --recursive https://ci.open-paas.org/stash/scm/meet/meetings.gi
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download hublin. Exiting ..."
                        exit 3
                fi

        fi

        # Installing mongodb
        echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' > /etc/apt/sources.list.d/mongodb.list
        apt-get install -y --force-yes mongodb-org=2.6.5 mongodb-org-server=2.6.5 mongodb-org-shell=2.6.5 mongodb-org-mongos=2.6.5 mongodb-org-tools=2.6.5
    service mongod start

        # Installing radis-server
        apt-get -y --force-yes  install redis-server

        # Installing hublin dependencies
        npm install -g mocha grunt-cli bower karma-cli

        cd meetings/modules/hublin-easyrtc-connector
        npm install

        cd ../../
        npm install
        if [ $? -ne 0 ]; then
               echo "Error: unable to install hublin. Exiting ..."
               exit 3
        fi

        cd ../
}


# -----------------------------------------------
# Function to install owncloud 
# -----------------------------------------------            
install_owncloud()
{
	echo "Installing owncloud ..."
	
	# Deleting previous packages
	rm -rf /var/www/owncloud
	
	if [ ! -e  owncloud-9.1.1.tar.bz2 ]; then
		echo "Downloading owncloud ..."
		wget https://download.owncloud.org/community/owncloud-9.1.1.tar.bz2
                if [ $? -ne 0 ]; then
	                echo "Error: Unable to download owncloud. Exiting ..."
       		        exit 3
                fi
		
	fi

	tar xf owncloud-9.1.1.tar.bz2
	mv owncloud /var/www/owncloud

	# Installing ojsxc xmpp client
	if [ ! -e ojsxc-3.0.1.zip ]; then
		echo "Downlouding ojsxc ..."
		wget https://github.com/owncloud/jsxc.chat/releases/download/v3.0.1/ojsxc-3.0.1.zip
		if [ $? -ne 0 ]; then 
                        echo "Error: Unable to download ojsxc. Exiting ..."
                        exit 3
                fi
	fi

	unzip ojsxc-3.0.1.zip
	mv ojsxc /var/www/owncloud/apps

	chown -R www-data /var/www/owncloud
}


# -----------------------------------------------
# Function to install libecap 
# -----------------------------------------------
install_libecap()
{
        echo "Installing libecap ..."

        if [ ! -e libecap-1.0.0 ]; then
        echo "Downloading libecap ..."
        wget http://www.measurement-factory.com/tmp/ecap/libecap-1.0.0.tar.gz
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download libecap"
                        exit 3
                fi
		tar xzf libecap-1.0.0.tar.gz
        fi

        echo "Building libecap ..."
        
	cd libecap-1.0.0/
	
	./configure 
	make &&  make install

        if [ $? -ne 0 ]; then
                echo "Error: unable to install libecap"
                exit 3
        fi
        cd ../

	# Cleanup
	rm -rf libecap-1.0.0.tar.gz
}


# -----------------------------------------------
# Function to install fg-ecap
# -----------------------------------------------
install_fg-ecap()
{
        echo "Installing fg-ecap ..."

        if [ ! -e fg_ecap ]; then
        echo "Downloading fg-ecap ..."
        git clone https://github.com/androda/fg_ecap $INSTALL_HOME/fg_ecap
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download fg-ecap. Exitingi ..."
                        exit 3
                fi
        fi

        echo "Building fg-ecap ..."

        cd fg_ecap

	chmod +x autogen.sh
        ./autogen.sh
        ./configure 
        make && make install
        if [ $? -ne 0 ]; then
                echo "Error: unable to install fg-ecap"
                exit 3
        fi
        cd ../
}


# -----------------------------------------------
# Function to install squid
# -----------------------------------------------
install_squid()
{
	echo "Installing squid dependences ..."
	aptitude -y build-dep squid

	echo "Installing squid ..."
	if [ ! -e /tmp/squid-3.5.21.tar.gz ]; then
		echo "Downloading squid ..."
		wget -P /tmp/ http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.21.tar.gz
	fi

	if [ ! -e squid-3.5.21 ]; then
		echo "Extracting squid ..."
		tar zxvf /tmp/squid-3.5.21.tar.gz
	fi

	echo "Building squid ..."
	cd squid-3.5.21
	./configure --prefix=/usr --localstatedir=/var \
		--libexecdir=/lib/squid --datadir=/usr/share/squid \
		--sysconfdir=/etc/squid --with-logdir=/var/log/squid \
		--with-pidfile=/var/run/squid.pid --enable-icap-client \
		--enable-linux-netfilter --enable-ssl-crtd --with-openssl \
		--enable-ltdl-convenience --enable-ssl \
		--enable-ecap PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install squid"
		exit 3
	fi
	cd ../

	# Getting squid startup script
	if [ ! -e /etc/squid/squid3.rc ]; then
		wget -P /etc/squid/ https://raw.githubusercontent.com/grosskur/squid3-deb/master/debian/squid3.rc
	fi

	# squid adservers
	curl -sS -L --compressed \
	"http://pgl.yoyo.org/adservers/serverlist.php?mimetype=plaintext" \
		> /etc/squid/squid.adservers

	# squid adzapper
	wget http://adzapper.sourceforge.net/scripts/squid_redirect
	chmod +x ./squid_redirect
	mv squid_redirect /usr/bin/
	
	# Adding library path
	echo "include /usr/local/lib" >> /etc/ld.so.conf 
	ldconfig
}


# ----------------------------------------------
# Function to install SquidClamav
# ----------------------------------------------
install_squidclamav()
{
	echo "Installing squidclamav ..."
	if [ ! -e /tmp/squidclamav-6.15.tar.gz ]; then
		echo "Downloading squidclamav ..."
		wget -P /tmp/ http://downloads.sourceforge.net/project/squidclamav/squidclamav/6.15/squidclamav-6.15.tar.gz
	fi

	if [ ! -e squidclamav-6.15 ]; then
		echo "Extracting squidclamav ..."
		tar zxvf /tmp/squidclamav-6.15.tar.gz
	fi

	echo "Building squidclamav ..."
	cd squidclamav-6.15
	./configure --with-c-icap
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install squidclamav"
		exit 3
	fi
	cd ../

	# Creating configuration file
	ln -sf /etc/c-icap/squidclamav.conf /etc/squidclamav.conf
}


# ----------------------------------------------
# Function to install squidguard blacklists
# ----------------------------------------------
install_squidguard_bl()
{
	echo "Installing squidguard blacklists ..."

#	# squidguard-adblock
#	echo "Downloading squidguard-adblock ..."
#	git clone https://github.com/jamesmacwhite/squidguard-adblock.git
#	if [ $? -ne 0 ]; then
#		echo "Error: unable to download squidguard-adblock"
#		exit 3
#	fi
#	cd squidguard-adblock
#	mkdir -p /etc/squid/squidguard-adblock
#	cp get-easylist.sh /etc/squid/squidguard-adblock/
#	cp patterns.sed /etc/squid/squidguard-adblock/
#	cp urls.txt /etc/squid/squidguard-adblock/
#	chmod +x /etc/squid/squidguard-adblock/get-easylist.sh
#	cd ..

	# Getting MESD blacklists
	if [ ! -e blacklists.tgz ]; then
	wget http://squidguard.mesd.k12.or.us/blacklists.tgz
	fi
	# Getting ads blacklists
        if [ ! -e serverlist.php ]; then
        wget https://pgl.yoyo.org/as/serverlist.php
	fi
	# Getting urlblacklist blacklists
	if [ ! -e urlblacklist ]; then
	wget http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download\\&file=bigblacklist -O urlblacklist.tar.gz
	rm -rf blacklistdomains
	mkdir blacklistdomains
	cd blacklistdomains
	tar xvzf urlblacklist.tar.gz
	cd ../
        fi
       
	# Making squidGuard blacklists directory
	mkdir -p /usr/local/squidGuard/db 
	# Extracting blacklists
        cp blacklists.tgz /usr/local/squidGuard/db
        tar xfv /usr/local/squidGuard/db/blacklists.tgz \
        -C /usr/local/squidGuard/db/
        # ads blacklists
        sed -n '57,2418p' < serverlist.php > /usr/local/squidGuard/db/blacklists/ads/domains
        # urlblacklist blacklists
        cat blacklistdomains/blacklists/ads/domains >> /usr/local/squidGuard/db/blacklists/ads/domains 
	# Shalalist domains
        cat BL/adv/domains >> /usr/local/squidGuard/db/blacklists/ads/domains
        cat BL/adv/urls >> /usr/local/squidGuard/db/blacklists/ads/urls
	# Cleanup
        rm -rf /usr/local/squidGuard/db/blacklists.tar
#	rm -rf squidguard-adblock
}


# ---------------------------------------------------------
# Function to install squidguardmgr (Manager Gui)
# ---------------------------------------------------------
install_squidguardmgr()
{
        echo "Installing squidguardmgr ..."
        if [ ! -e squidguardmgr ]; then
                echo "Downloading squidguardmgr ..."
                git clone https://github.com/darold/squidguardmgr
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download quidguardmgr"
                        exit 3
                fi
        fi

        echo "Building quidguardmgr ..."
        cd squidguardmgr
        perl Makefile.PL \
        CONFFILE=/etc/squidguard/squidGuard.conf \
        SQUIDUSR=root SQUIDGRP=root \
        SQUIDCLAMAV=off \
        QUIET=1

        make
        make install
        cd ../

        chmod a+rw /etc/squidguard/squidGuard.conf
}


# ----------------------------------------------
# Function to install e2guardian
# ----------------------------------------------
install_e2guardian()
{
	echo "Installing e2guardian ..."

	if [ ! -e e2guardian ]; then
		echo "Downloading e2guardian ..."
		git clone https://github.com/e2guardian/e2guardian
		if [ $? -ne 0 ]; then
			echo "Error: unable to download e2guardian"
			exit 3
		fi
	fi

	echo "Building e2guardian ..."
	cd e2guardian

	# Adding ssl options
	echo "
	#define __SSLMITM
	#define __SSLCERT
	" > dgconfig.h
	sed  -i '/LIBS = -lz/c\LIBS = -lz -lcrypto -lssl' Makefile

	./autogen.sh
	./configure --prefix=/usr --enable-clamd=yes --enable-fancydm=no
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install e2guardian"
		exit 3
	fi
	cd ../

	# Cleanup
	rm -rf ./e2guardian
}


# ----------------------------------------------
# Function to install ecapguardian
# ----------------------------------------------
install_ecapguardian()
{
	echo "Installing ecapguardian ..."
        
        if [ ! -e ecapguardian ]; then
	echo "Downloading ecapguardian ..."
	git clone https://github.com/androda/ecapguardian
		if [ $? -ne 0 ]; then
			echo "Error: unable to download ecapguardian"
			exit 3
		fi
	fi

	echo "Building ecapguardian ..."

	cd ecapguardian

	# Adding subdir for automake
        sed -i '/AM_INIT_AUTOMAKE/c\AM_INIT_AUTOMAKE([subdir-objects])' configure.ac

	./autogen.sh
	./configure '--prefix=/usr' '--enable-clamd=yes' '--with-proxyuser=e2guardian' '--with-proxygroup=e2guardian' '--sysconfdir=/etc' '--localstatedir=/var' '--enable-icap=yes' '--enable-commandline=yes' '--enable-email=yes' '--enable-ntlm=yes' '--enable-trickledm=yes' '--mandir=${prefix}/share/man' '--infodir=${prefix}/share/info' 'CXXFLAGS=-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security' 'LDFLAGS=-Wl,-z,relro' 'CPPFLAGS=-D_FORTIFY_SOURCE=2' 'CFLAGS=-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security' '--enable-pcre=yes' '--enable-locallists=yes' 
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install ecapguardian"
		exit 3
	fi
	cd ../

	# Cleanup
	# rm -rf ./ecapguardian
}


# ----------------------------------------------
# Function to install Suricata
# ----------------------------------------------
install_suricata()
{
        echo "Installing suricata ..."

        # Installing dependencies
        apt-get install -y --force-yes ethtool oinkmaster

        apt-get install -y -t jessie-backports ethtool suricata
        if [ $? -ne 0 ]; then
                echo "Error: unable to install suricata. Exiting ..."
                exit 3
        fi

        echo "Downloading rules ..."

        # Creating oinkmaster configuration
        echo "
skipfile local.rules
skipfile deleted.rules
skipfile snort.conf 
        " > /etc/oinkmaster.conf
        echo "url = https://rules.emergingthreats.net/open/suricata-3.1/emerging.rules.tar.gz" \
        >> /etc/oinkmaster.conf 
        oinkmaster -C /etc/oinkmaster.conf -o /etc/suricata/rules
        if [ $? -ne 0 ]; then
                echo "Error: unable to install suricata rules. Exiting ..."
                exit 3
        fi
}


# -----------------------------------------------
# Install kibana, elasticsearch and logstash
# -----------------------------------------------
install_kibana()
{
	echo "Installing kibana ..."
	apt-get install -y --force-yes kibana elasticsearch logstash \
        2>&1 > /dev/null
	if [ $? -ne 0 ]; then
                echo "Error: unable to install kibaba. Exiting ..."
                exit 3
        fi

	# Enabling kibana daemon
	/bin/systemctl daemon-reload
	/bin/systemctl enable kibana.service

	# installing plugins
	/usr/share/elasticsearch/bin/plugin install license
	/usr/share/elasticsearch/bin/plugin install marvel-agent
	/opt/kibana/bin/kibana plugin --install elasticsearch/marvel/latest
}


# ----------------------------------------------
# Function to install scirius package
# ----------------------------------------------
install_scirius()
{
	echo "Installing scirius ..."

	echo "Downloading scirius ..."
	git clone https://github.com/StamusNetworks/scirius /opt/scirius
	if [ $? -ne 0 ]; then
		echo "Error: unable to download scirius"
		exit 3
	fi

	echo "Installing scirius ..."
	pip install -r /opt/scirius/requirements.txt && pip install pyinotify
	if [ $? -ne 0 ]; then
		echo "Error: unable to install scirius dependencies"
		exit 3
	fi
	python /opt/scirius/manage.py syncdb --noinput
	if [ $? -ne 0 ]; then
		echo "Error: unable to install scirius"
		exit 3
	fi
}


# ----------------------------------------------
# Function to install Snort
# ----------------------------------------------
install_snort()
{
	echo "Installing snort ..."

	# DAQ
	echo "Downloading daq ..."
	URL="https://www.snort.org/downloads/archive/snort"
	PKG="daq-2.0.6.tar.gz"
	wget -P /tmp/ $URL/$PKG
	tar xvf /tmp/$PKG
	rm -rf /tmp/$PKG

	echo "Building daq ..."
	cd daq-2.0.6
	./configure --prefix=/usr
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install daq"
		exit 3
	fi
	cd ../

	# Snort
	echo "Downloading snort ..."
	URL="https://www.snort.org/downloads/archive/snort"
	PKG="snort-2.9.8.3.tar.gz"
	wget -P /tmp/ $URL/$PKG
	tar xvf /tmp/$PKG
	rm -rf /tmp/$PKG

	echo "Building snort ..."
	cd snort-2.9.8.3
	./configure --prefix=/usr --enable-sourcefire \
		--enable-flexresp --enable-dynamicplugin \
		--enable-perfprofiling --enable-reload
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install snort"
		exit 3
	fi

	# Copy config files
	mkdir -p /etc/snort/preproc_rules /var/log/snort /etc/snort/rules
	mkdir -p /usr/lib/snort_dynamicrules
	cp ./etc/*.conf* ./etc/*.map /etc/snort/
	# Create Snort directories
	touch /etc/snort/rules/white_list.rules
	touch /etc/snort/rules/black_list.rules
	touch /etc/snort/rules/local.rules
	cd ../

	# Pulled Pork
	echo "Downloading pulledpork ..."
	git clone https://github.com/shirkdog/pulledpork.git
	if [ $? -ne 0 ]; then
		echo "Error: unable to download pulledpork"
		exit 3
	fi
	cd pulledpork
	cp pulledpork.pl /usr/bin/
	chmod +x /usr/bin/pulledpork.pl
	cp ./etc/*.conf /etc/snort/
	cd ../
	mkdir -p /etc/snort/rules/iplists
	touch /etc/snort/rules/iplists/default.blacklist

	echo "Updating Snort rules ..."
	# Comment current includes
	sed -i -e 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf
	# Fix pulledpork configuration
	sed -i -e 's/^\(rule_url.*<oinkcode>\)/#\1/g' /etc/snort/pulledpork.conf
	sed -i -e 's@/usr/local/lib/@/usr/lib/@g' /etc/snort/pulledpork.conf
	sed -i -e 's@/usr/local/@/@g' /etc/snort/pulledpork.conf
	# Fix Snort configuration
	sed -i -e 's@/usr/local/lib/@/usr/lib/@g' /etc/snort/snort.conf
	sed -i -e 's@var RULE_PATH .*@var RULE_PATH /etc/snort/rules@g' /etc/snort/snort.conf
	sed -i -e 's@var SO_RULE_PATH .*@var SO_RULE_PATH /etc/snort/rules/so_rules@g' /etc/snort/snort.conf
	sed -i -e 's@var PREPROC_RULE_PATH .*@var PREPROC_RULE_PATH /etc/snort/rules/preproc_rules@g' /etc/snort/snort.conf
	sed -i -e 's@var WHITE_LIST_PATH .*@var WHITE_LIST_PATH /etc/snort/rules@g' /etc/snort/snort.conf
	sed -i -e 's@var BLACK_LIST_PATH .*@var BLACK_LIST_PATH /etc/snort/rules@g' /etc/snort/snort.conf
	echo 'include $RULE_PATH/local.rules' >> /etc/snort/snort.conf
	echo 'include $RULE_PATH/snort.rules' >> /etc/snort/snort.conf
	# Download rules
	pulledpork.pl -c /etc/snort/pulledpork.conf -l
	if [ $? -ne 0 ]; then
		echo "Error: unable to update Snort rules"
		exit 3
	fi

	# Cleanup
	rm -rf daq-2.0.6
	rm -rf snort-2.9.8.3
	rm -rf pulledpork
}


# ----------------------------------------------
# Function to install Barnyard2
# ----------------------------------------------
install_barnyard()
{
	echo "Installing Barnyard ..."

	echo "Downloading Barnyard ..."
	git clone https://github.com/firnsy/barnyard2.git
	if [ $? -ne 0 ]; then
		echo "Error: unable to download Barnyard"
		exit 3
	fi

	cd barnyard2
	echo "Building Barnyard ..."
	./autogen.sh
	./configure --prefix=/usr --with-mysql CFLAGS='-g -O2 -DHAVE_DUMBNET_H' \
		--with-mysql-libraries=/usr/lib/x86_64-linux-gnu/
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install Barnyard"
		exit 3
	fi
	mv /usr/etc/barnyard2.conf /etc/snort/
	mkdir -p /var/log/barnyard2
	cd ..

	# Cleanup
	rm -rf barnyard2
}


# ----------------------------------------------
# Function to install vortex-ids package
# ----------------------------------------------
install_vortex_ids()
{
	echo "Installing vortex-ids ..."

	echo "Downloading vortex-ids ..."
	git clone https://github.com/lmco/vortex-ids
	if [ $? -ne 0 ]; then
		echo "Error: unable to download vortex-ids"
		exit 3
	fi

	cd vortex-ids
	echo "Building libbsf ..."
	gcc -Wall -fPIC -shared libbsf/libbsf.c -o libbsf.so
	if [ $? -ne 0 ]; then
		echo "Error: unable to build libbsf"
		exit 3
	fi
	cp libbsf/bsf.h /usr/include/ && cp libbsf.so /usr/lib/

	echo "Building vortex ..."
	gcc vortex/vortex.c -lpcap -lnids -lpthread -lbsf -Wall -DWITH_BSF -o vortex.bin -O2
	if [ $? -ne 0 ]; then
		echo "Error: unable to build vortex"
		exit 3
	fi
	cp vortex.bin /usr/bin/vortex

	echo "Building xpipes ..."
	gcc xpipes/xpipes.c -lpthread -Wall -o xpipes.bin -O2
	if [ $? -ne 0 ]; then
		echo "Error: unable to build xpipes"
		exit 3
	fi
	cp xpipes.bin /usr/bin/xpipes
	cd ../

	# Cleanup
	rm -rf vortex-ids
}


# ----------------------------------------------
# Function to install openwips-ng package
# ----------------------------------------------
install_openwips_ng()
{
	echo "Installing openwips-ng ..."

	echo "Downloading openwips-ng ..."
	git clone https://github.com/aircrack-ng/OpenWIPS-ng.git
	if [ $? -ne 0 ]; then
		echo "Error: unable to download openwips-ng"
		exit 3
	fi

	echo "Building openwips-ng ..."
	cd OpenWIPS-ng
	# disable Werror flag
	sed -i -e 's/-Werror//g' ./common.mak

	make LIBS+="-lpcap -lssl -lz -lcrypto -ldl -lm -lpthread -lsqlite3" &&
	make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install openwips-ng"
		exit 3
	fi
	cd ../

	# Cleanup
	rm -rf OpenWIPS-ng
}


# ----------------------------------------------
# Function to install hakabana
# ----------------------------------------------
install_hakabana()
{
	echo "Installing hakabana ..."

	echo "Downloading hakabana ..."
	URL="https://github.com/haka-security/hakabana/releases/download/0.2.1"
	PKG="hakabana_0.2.1_all.deb"
	wget -P /tmp/ $URL/$PKG

	echo "Installing hakabana ..."
	dpkg -i /tmp/$PKG && apt-get install -f
	if [ $? -ne 0 ]; then
		echo "Error: unable to install hakabana"
		exit 3
	fi

	# Cleanup
	rm -rf /tmp/$PKG
}


# ----------------------------------------------
# Function to install FlowViewer
# ----------------------------------------------
install_flowviewer()
{
	echo "Installing FlowViewer ..."

	echo "Downloading SiLK ..."
	URL="http://tools.netsa.cert.org/releases"
	PKG="silk-3.12.2.tar.gz"
	wget -P /tmp/ $URL/$PKG
	tar xvf /tmp/$PKG
	rm -rf /tmp/$PKG

	cd silk-3.12.2
	./configure --prefix=/usr --with-python --with-libfixbuf --enable-ipv6
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install SiLK"
		exit 3
	fi
	cd ../

	echo "Downloading FlowViewer ..."
	URL="https://sourceforge.net/projects/flowviewer/files"
	PKG="FlowViewer_4.6.tar"
	wget -P /tmp/ $URL/$PKG
	tar xvf /tmp/$PKG
	if [ $? -ne 0 ]; then
		echo "Error: unable to download FlowViewer"
		exit 3
	fi
	mv FlowViewer_4.6 /opt/FlowViewer

	# Cleanup
	rm -rf /tmp/$PKG
	rm -rf silk-3.12.2
}


# ----------------------------------------------
# Function to install pmgraph
# ----------------------------------------------
install_pmgraph()
{
	echo "Installing pmgraph ..."

	echo "Downloading pmgraph ..."
	git clone https://github.com/aptivate/pmgraph
	if [ $? -ne 0 ]; then
		echo "Error: unable to download pmgraph"
		exit 3
	fi

	echo "Building pmgraph ..."
	cd pmgraph
	sed -i -e 's/tomcat6/tomcat7/g' \
		Installer/pmGraphInstaller.sh debian/pmgraph.postinst \
		debian/pmgraph.postrm debian/control
	sed -i -e 's/pmacct restart/pmacctd restart/g' \
		Installer/pmGraphInstaller.sh debian/pmgraph.postinst \
		debian/pmgraph.postrm debian/control
	sed -i -e 's/ | tomcat5.5//g' debian/control
	sed -i -e 's/openjdk-6-jdk/openjdk-7-jdk/g' debian/control
	sed -i -e 's/java-6-sun/java-7-openjdk-amd64/g' debian/rules

	debuild -us -uc
	if [ $? -ne 0 ]; then
		echo "Error: unable to pack pmgraph"
		exit 3
	fi
	DEBIAN_FRONTEND=noninteractive dpkg -i ../pmgraph_1.2.3_all.deb && 
	DEBIAN_FRONTEND=noninteractive apt-get install -f
	if [ $? -ne 0 ]; then
		echo "Error: unable to install pmgraph"
		exit 3
	fi
	cd ../

	# Cleanup
	rm -rf ./pmgraph
	rm -rf ./pmgraph_1.2.3*
}


# ----------------------------------------------
# Function to install nfsen
# ----------------------------------------------
install_nfsen()
{
	echo "Installing nfsen ..."

	# nfdump
	echo "Downloading nfdump ..."
	URL="https://sourceforge.net/projects/nfdump/files/stable/nfdump-1.6.13"
	PKG="nfdump-1.6.13.tar.gz"
	wget -P /tmp/ $URL/$PKG
	tar xvf /tmp/$PKG
	rm -rf /tmp/$PKG

	echo "Building nfdump ..."
	cd nfdump-1.6.13
	./configure --enable-nfprofile
	make && make install
	if [ $? -ne 0 ]; then
		echo "Error: unable to install nfdump"
		exit 3
	fi
	cd ../

	# nfsen
	echo "Downloading nfsen ..."
	URL="https://sourceforge.net/projects/nfsen/files/stable/nfsen-1.3.6p1"
	PKG="nfsen-1.3.6p1.tar.gz"
	wget -P /tmp/ $URL/$PKG
	tar xvf /tmp/$PKG
	rm -rf /tmp/$PKG

	echo "Building nfsen ..."
	cd nfsen-1.3.6p1
	# Fix broken input
	sed -i -e 's@import Socket6@Socket6->import(qw(pack_sockaddr_in6 unpack_sockaddr_in6 inet_pton getaddrinfo))@g' \
		libexec/AbuseWhois.pm libexec/Lookup.pm
	# Fix configuration
	cp ./etc/nfsen-dist.conf ./etc/nfsen.conf
	sed -i -e 's@^\$BASEDIR.*$@$BASEDIR = "/var/nfsen";@g' ./etc/nfsen.conf
	sed -i -e 's@^\$USER.*$@$USER = "www-data";@g' ./etc/nfsen.conf
	sed -i -e 's@^\$WWWUSER.*$@$WWWUSER = "www-data";@g' ./etc/nfsen.conf
	sed -i -e 's@^\$WWWGROUP.*$@$WWWGROUP = "www-data";@g' ./etc/nfsen.conf
	sed -i -e '/^.*peer[12].*$/d' ./etc/nfsen.conf
	# Disable interactive mode
	sed -i -e '/chomp(\$ans = <STDIN>);/d' ./install.pl
	perl ./install.pl ./etc/nfsen.conf
	if [ $? -ne 0 ]; then
		echo "Error: unable to install nfsen"
		exit 3
	fi
	cd ../

	# Cleanup
	rm -rf nfdump-1.6.13
	rm -rf nfsen-1.3.6p1
}


# ----------------------------------------------
# Function to install evebox package
# ----------------------------------------------
install_evebox()
{
        echo "Installing EveBox ..."

        if [ ! -e evebox-0.6.0dev-linux-amd64 ]; then
        echo "Downloading EveBox ..."
        wget --no-check-certificat \
        https://bintray.com/jasonish/evebox-development/download_file?file_path=evebox-latest-linux-amd64.zip
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download EveBox. Exiting ..."
                        exit 3
                fi
        mv download_file?file_path=evebox-latest-linux-amd64.zip evebox-latest-linux-amd64.zip
        unzip evebox-latest-linux-amd64.zip
        fi

	# Moving bin 
	sudo mv evebox-0.6.0dev-linux-amd64/evebox /sbin/

        # Cleanup
        rm -rf evebox-latest-linux-amd64.zip
}


# ----------------------------------------------
# Function to install SELKS GUI
# ----------------------------------------------
install_selks()
{
	echo "Installing SELKS ..."

	echo "Installing timelion plugin ..."
	touch /opt/kibana/config/kibana.yml
	/opt/kibana/bin/kibana plugin -i elastic/timelion
	if [ $? -ne 0 ]; then
		echo "Error: unable to install timelion plugin"
		exit 3
	fi

	echo "Downloading KTS ..."
	git clone https://github.com/StamusNetworks/KTS.git
	if [ $? -ne 0 ]; then
		echo "Error: unable to download KTS"
		exit 3
	fi

	echo "Patching Kibana ..."
	patch -p1 -d /opt/kibana/ < KTS/patches/kibana-integer.patch &&
	patch -p1 -d /opt/kibana/ < KTS/patches/timelion-integer.patch
	if [ $? -ne 0 ]; then
		echo "Error: unable to patch Kibana"
		exit 3
	fi
	mv KTS /opt/

	echo "Downloading SELKS Scripts ..."
	git clone https://github.com/StamusNetworks/selks-scripts.git
	if [ $? -ne 0 ]; then
		echo "Error: unable to download SELKS Scripts"
		exit 3
	fi
	cd selks-scripts
	# Fix conky
	sed -i -e 's/lightgey/lightgrey/g' \
		Scripts/Configs/Conky/etc/conky/conky.conf
	sed -i -e "s@\(-F\\\\\)'@\1\\\"@g" \
		Scripts/Configs/Conky/etc/conky/conky.conf

	#'" this comment fix formatting

	echo "Installing SELKS configuration ..."
	cp Scripts/Configs/Conky/etc/conky/conky.conf /etc/conky/conky.conf
	cp Scripts/Configs/Elasticsearch/etc/elasticsearch/elasticsearch.yml \
		/etc/elasticsearch/elasticsearch.yml
	cp Scripts/Configs/Logrotate/etc/logrotate.d/suricata /etc/logrotate.d/
	cp Scripts/Configs/Logstash/etc/logstash/conf.d/logstash.conf \
		/etc/logstash/conf.d/

	cd ../

	# Cleanup
	rm -rf selks-scripts
}


# ----------------------------------------------
# Function to install Snorby
# ----------------------------------------------
install_snorby()
{
	echo "Installing Snorby ..."

	echo "Downloading Snorby ..."
	git clone https://github.com/Snorby/snorby.git
	if [ $? -ne 0 ]; then
		echo "Error: unable to download Snorby"
		exit 3
	fi
	cd snorby
	echo "Installing Gem dependencies ..."
	bundle install --system
	if [ $? -ne 0 ]; then
		echo "Error: unable to install dependencies"
		exit 3
	fi
	cp config/snorby_config.yml.example config/snorby_config.yml
	cp config/database.yml.example config/database.yml
	# Fix worker pid
	sed -i -e 's@Snorby::Process.new(`ps -o ruser,pid,%cpu,%mem,vsize,rss,tt,stat,start,etime,command -p #{Worker.pid} |grep delayed_job |grep -v grep`.chomp.strip)@Snorby::Process.new("www   -1   0.0  0.0 0  0  ??  S    00:00PM        00:00 ruby: delayed_job (ruby)")@g' lib/snorby/worker.rb
	cd ../
	mv snorby /var/www/
}


# ---------------------------------------------------------
# Function to install glype proxy server
# ---------------------------------------------------------
install_glype()
{
	echo "Installing glype ..."

	# Downloading glype-1.4.15
	if [ ! -e glype-1.4.15.zip ]; then
	    wget http://netix.dl.sourceforge.net/project/free-proxy-server/glype-1.4.15%20%281%29.zip
	    if [ $? -ne 0 ]; then
	        echo "Error: unable to download e2guardian"
	        exit 3
	    fi
	    mv glype-1.4.15\ \(1\).zip glype-1.4.15.zip
	fi

	unzip glype-1.4.15.zip -d glype-1.4.15
	rm -rf /var/www/glype

	# Creating glype home
	mkdir /var/www/glype
	cp -R glype-1.4.15/* /var/www/glype

	# Cleanup
	rm -rf glype-1.4.15
}


# ---------------------------------------------------------
# Function to install gitlab package
# ---------------------------------------------------------
install_gitlab()
{
# Gitlab can only be installed on x86_64 (64 bit) architecture
if [ "$ARCH" == "x86_64" ]; then

	echo "Installing gitlab ..."

	# Check if gitlab is installed or not 
	which gitlab-ctl > /dev/null 2>&1
	if [ $? -ne 0 ]; then 
		# Install the necessary dependencies
		apt-get install -y --force-yes curl openssh-server ca-certificates postfix

	        if [ ! -e gitlab-ce_8.12.7-ce.0_amd64.deb ]; then
	        echo "Downloading Gitlab ..."
	        wget --no-check-certificat -O gitlab-ce_8.12.7-ce.0_amd64.deb \
		https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/wheezy/gitlab-ce_8.12.7-ce.0_amd64.deb/download 
	
	                if [ $? -ne 0 ]; then
	                        echo "Error: unable to download Gitlab. Exiting ..."
	                        exit 3
	                fi
	        fi
        
		# Install gitlab 
		dpkg -i gitlab-ce_8.12.7-ce.0_amd64.deb
	        if [ $? -ne 0 ]; then
	                echo "Error: unable to install Gitlab. Exiting ..."
	                exit 3
	        fi

		# Installing from packages for dependencies
		curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
		bash script.deb.sh
		apt-get install -y --force-yes gitlab-ce
	fi
else
	echo "Skipping gitlab installation. x86_64 Needed / Detected: $ARCH"
fi
}


# ---------------------------------------------------------
# Function to install trac server
# ---------------------------------------------------------
install_trac()
{
        if [ "$ARCH" == "x86_64" ]; then
                echo "Installing trac ..."
                apt-get -y --force-yes install trac
                if [ $? -ne 0 ]; then
                        echo "Error: unable to install trac. Exiting ..."
                        exit 3
                fi
        else
                echo "Skipping trac installation. x86_64 Needed / Detected: $ARCH"
        fi
}

# ---------------------------------------------------------
# Function to install redmine server
# ---------------------------------------------------------
install_redmine()
{
if [ "$ARCH" == "x86_64" ]; then
	echo "Installing redmine ..."
        apt-get -y --force-yes install \
        mysql-server mysql-client libmysqlclient-dev \
        gcc build-essential zlib1g zlib1g-dev zlibc \
        ruby-zip libssl-dev libyaml-dev libcurl4-openssl-dev \
        ruby ruby2.1 gem libapr1-dev libxslt1-dev checkinstall \
        libxml2-dev ruby-dev vim libmagickwand-dev imagemagick
        if [ $? -ne 0 ]; then
        	echo "Error: unable to install redmine. Exiting ..."
                exit
        fi

	rm -rf /opt/redmine
        mkdir /opt/redmine
        chown -R www-data /opt/redmine
        cd /opt/redmine

	if [ ! -e redmine-3.3.1 ]; then
                echo "Downloading redmine ..."
                wget http://www.redmine.org/releases/redmine-3.3.1.tar.gz
                if [ $? -ne 0 ]; then
                        echo "Error: unable to download redmine. Exiting ..."
                        exit
                fi
                tar xzf redmine-3.3.1.tar.gz
	fi
        cd redmine-3.3.1

        # Install bundler
        gem install bundler
        if [ $? -ne 0 ]; then
                echo "Error: unable to install bundler. Exiting ..."
                exit 3
        fi
	
	# Install thin
        gem install thin 
        if [ $? -ne 0 ]; then
                echo "Error: unable to install thin. Exiting ..."
                exit 3
        fi
	
	echo "gem 'thin'" > Gemfile.local
	bundle install --without development test
	thin install

        # Generate secret token
        bundle exec rake generate_secret_token

        # Prepare DB and install all tables:
        #RAILS_ENV=production bundle exec rake db:migrate
        #RAILS_ENV=production bundle exec rake redmine:load_default_data
else
        echo "Skipping redmine installation. x86_64 Needed / Detected: $ARCH"
fi
}


# ---------------------------------------------------------
# Funtion to install ndpi and ndpi-netfilter package
# ---------------------------------------------------------
install_ndpi()
{
        echo "Installing ndpi ..."

	# Installing dependencies
	apt-get install -y --force-yes \
	autogen automake make gcc \
	linux-source libtool autoconf pkg-config subversion \
	libpcap-dev iptables-dev linux-headers-amd64
	
	# Removing old source
	rm -rf /usr/src/ndpi-netfilter

	if [ ! -e ndpi-netfilter ]; then
		echo "Downloading ndpi ..."
		git clone https://github.com/betolj/ndpi-netfilter
                if [ $? -ne 0 ]; then
                        echo "Unable to download ndpi. Exiting ..."
                        exit 3
                fi
	fi
	cp -r ndpi-netfilter /usr/src/
	
	# Extracting nDPI
	cd /usr/src/ndpi-netfilter
	tar xvfz nDPI.tar.gz
	cd nDPI

	# Building nDPI
	./autogen.sh
	./configure --with-pic
	make
	make install
        if [ $? -ne 0 ]; then
                echo "Unable to install ndpi. Exiting ..."
                exit 3
        fi

	# Building nDPI-netfilter
	cd ..
	NDPI_PATH=/usr/src/ndpi-netfilter/nDPI make
	make modules_install
        if [ $? -ne 0 ]; then
                echo "Unable to install ndpi-netfilter. Exiting ..."
                exit 3
        fi

	# Connecting to xtables
	cp /usr/src/ndpi-netfilter/ipt/libxt_ndpi.so /lib/xtables/

	cd $INSTALL_HOME
}


# ----------------------------------------------
# Function to install redsocks package
# ----------------------------------------------
install_redsocks()
{
        echo "Installing redsocks ..."

        # Installing dependencies
        apt-get install -y --force-yes \
        iptables git-core libevent-2.0-5 libevent-dev

        # Removing old source
	cd /opt/
        rm -rf redsocks

        if [ ! -e redsocks ]; then
                echo "Downloading redsocks..."
                git clone https://github.com/darkk/redsocks
                if [ $? -ne 0 ]; then
                        echo "Unable to download redsocks. Exiting ..."
                        exit 3
                fi
        fi

        # Building nDPI
        cd redsocks/
        make
        if [ $? -ne 0 ]; then
                echo "Unable to install redsocks. Exiting ..."
                exit 3
        fi

	cd $INSTALL_HOME
}


# -----------------------------------------------
# Function to install ntopng
# -----------------------------------------------
install_ntopng()
{
        echo "Installing ntopng ..."
        sudo apt-get -y --force-yes install ntopng
        if [ $? -ne 0 ]; then
                echo "Error: Unable to install ntopng. Exiting"
                exit 3
        fi      
}


# -----------------------------------------------
# This function saves variables in file, so
# parametization script can read and use these 
# values
# Variables to save are:
#   PLATFORM
#   HARDWARE
#   PROCESSOR
#   EXT_INTERFACE
#   INT_INTERFACE
#   ARCH
# -----------------------------------------------  
save_variables()
{
        echo "Saving variables ..."
	if [ -e /var/box_variables ]; then
		if grep "DB_PASS" /var/box_variables > /dev/null 2>&1; then
 	               MYSQL_PASS=`cat /var/box_variables | grep "DB_PASS" | awk {'print $2'}`
		       echo -e \
"Platform: $PLATFORM\n\
Hardware: $HARDWARE\n\
Processor: $PROCESSOR\n\
Architecture: $ARCH\n\
Ext_interface: $EXT_INTERFACE\n\
Int_interface: $INT_INTERFACE\n\
DB_PASS: $MYSQL_PASS" \
		 > /var/box_variables
		else
	               echo -e \
"Platform: $PLATFORM\n\
Hardware: $HARDWARE\n\
Processor: $PROCESSOR\n\
Architecture: $ARCH\n\
Ext_interface: $EXT_INTERFACE\n\
Int_interface: $INT_INTERFACE" \
                 > /var/box_variables
		fi
	else
		touch /var/box_variables	
        	echo -e \
"Platform: $PLATFORM\n\
Hardware: $HARDWARE\n\
Processor: $PROCESSOR\n\
Architecture: $ARCH\n\
Ext_interface: $EXT_INTERFACE\n\
Int_interface: $INT_INTERFACE" \
                 > /var/box_variables
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
	check_requirements      # Checking requirements for 
        get_interfaces  	# Get DHCP on eth0 or eth1 and 
				# connect to Internet
	configure_repositories	# Prepare and update repositories
	install_packages       	# Download and install packages	
#	install_libressl	# Install Libressl package
	install_modsecurity     # Install modsecurity package
	install_certificates	# Install ssl certificates
	install_nginx		# Install nginx package
	install_mailpile	# Install Mailpile package
	install_easyrtc		# Install EasyRTC package
#	install_hublin		# Install hublin package
	install_owncloud	# Install Owncloud package
	install_libecap		# Install libecap package
	install_fg-ecap		# Install fg-ecap package
	install_squid		# Install squid package
	install_squidclamav	# Install SquidClamav package
	install_squidguard_bl	# Install Squidguard blacklists
	install_squidguardmgr	# Install Squidguardmgr (Manager Gui) 
	install_ecapguardian	# Inatall ecapguardian package
#	install_e2guardian	# Inatall e2guardian package
	install_suricata	# Install Suricata package
#	install_kibana		# Install Kibana,elasticsearch,logstash packages
#	install_scirius		# Install Scirius package
#	install_snort		# Install Snort package
#	install_barnyard	# Install Barnyard package
#	install_vortex_ids	# Install Vortex-ids package
#	install_openwips_ng	# Install Openwips-ng package
#	install_hakabana	# Install hakabana package
#	install_flowviewer	# Install FlowViewer package
#	install_pmgraph		# Install pmgraph package
#	install_nfsen		# Install nfsen package
#	install_evebox		# Install EveBox package
#	install_selks		# Install SELKS GUI
#	install_snorby		# Install Snorby package
#	install_glype		# Install glype proxy
	install_gitlab		# Install gitlab packae
	install_trac		# Install trac package
	install_redmine		# Install redmine package
	install_ndpi		# Install ndpi package
	install_redsocks	# Install redsocks package
	install_ntopng		# Install ntopng package
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
        #get_interfaces		# Get DHCP on eth0 or eth1 and 
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
#echo "Initialization done successfully"

exit 
