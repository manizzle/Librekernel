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
        ruby gem libapr1-dev libxslt1-dev checkinstall thin \
        libxml2-dev ruby-dev vim libmagickwand-dev imagemagick
        if [ $? -ne 0 ]; then
        	echo "Error: unable to install redmine. Exiting ..."
                exit
        fi

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
        bundle install --without development test
        if [ $? -ne 0 ]; then
                echo "Error: unable to install bundler. Exiting ..."
                exit
        fi

        # Generate secret token
        bundle exec rake generate_secret_token

        # Prepare DB and install all tables:
        RAILS_ENV=production bundle exec rake db:migrate
        RAILS_ENV=production bundle exec rake redmine:load_default_data
else
        echo "Skipping redmine installation. x86_64 Needed / Detected: $ARCH"
fi
}


# ---------------------------------------------------------
# Funtion to install ndpi package
# ---------------------------------------------------------
install_ndpi()
{
        echo "Installing ndpi ..."
        apt-get install -y --force-yes \
        autogen automake autoconf libtool make libpcap-dev gcc

        if [ ! -e nDPI ]; then
                echo "Downloading ndpi ..."
                git clone https://github.com/ntop/nDPI
                if [ $? -ne 0 ]; then
                        echo "Unable to download ndpi. Exiting ..."
                        exit 3
                fi
        fi

        # Compiling ndpi
        cd nDPI/
        ./autogen.sh
        ./configure
        make
        make install
        cd ../
        if [ $? -ne 0 ]; then
                echo "Unable to install ndpi. Exiting ..."
                exit 3
        fi
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
#   ARCH
# ----------------------------------------------  
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
	check_requirements      # Checking requirements for 
        get_interfaces  	# Get DHCP on eth0 or eth1 and 
	configure_repositories	# Prepare and update repositories
	install_packages       	# Download and install packages	
	install_modsecurity     # Install modsecurity package
	install_nginx		# Install nginx package
	install_mailpile	# Install Mailpile package
	install_easyrtc		# Install EasyRTC package
	install_owncloud	# Install Owncloud package
	install_libecap		# Install libecap package
	install_fg-ecap		# Install fg-ecap package
	install_squid		# Install squid package
	install_squidclamav	# Install SquidClamav package
	install_squidguard_bl	# Install Squidguard blacklists
	install_squidguardmgr	# Install Squidguardmgr (Manager Gui) 
	install_ecapguardian	# Inatall ecapguardian package
	install_suricata	# Install Suricata package
	install_gitlab		# Install gitlab packae
	install_trac		# Install trac package
	install_redmine		# Install redmine package
	install_ndpi		# Install ndpi package
	save_variables	        # Save detected variables
fi
# ---------------------------------------------
# If script reachs to this point then it's done 
# successfully
# ---------------------------------------------
exit
