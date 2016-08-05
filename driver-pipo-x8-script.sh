#!/bin/bash
# This script fetch, compile, install and configure additional drivers
# needed by Pipo X8 with Debian 8 installed. Main reference to this
# work could be found on https://wiki.debian.org/InstallingDebianOn/PIPO/PIPO%20X8

# Global variables
ORIG_DIR="$(pwd)"

# Test if build tools are installed, if not, then installed
function _install_buildtools() {
	BUILD_ESSENTIAL_STATE=$(dpkg -l build-essential)
	# The package is known to the system
	if [ $? = 0 ]
	then
		# Checking if isn't installed
		echo "$BUILD_ESSENTIAL_STATE)" | grep ^ii -q
		if ! [ $? = 0 ] 
		then
			# install the package
			apt install build-essential linux-headers-$(uname -r) -y
		fi

	# The package is unknown to the system
	else 
		apt install build-essential linux-headers-$(uname -r) -y
		
	fi 	
}

function _install_package() {
	PACKAGE="$1"
	PACKAGE_STATE=$(dpkg -l $PACKAGE)
	# The package is known to the system
	if [ $? = 0 ]
	then
		# Checking if isn't installed
		echo "$PACKAGE_STATE)" | grep ^ii -q
		if ! [ $? = 0 ] 
		then
			# install the package
			apt install -y $PACKAGE
		fi

	# The package is unknown to the system
	else 
		apt install -y $PACKAGE
		
	fi 	
}

# Touchscreen, free driver
function _touchscreen() {
	# Check if needed packages are installed
	_install_package build-essential
	_install_package linux-headers-$(uname -r)

	# This module has to be compiled and patched	
	cd /usr/src
	mkdir driver-touchscreen
	cd driver-touchscreen
	wget "http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/plain/drivers/input/touchscreen/goodix.c"

	# BEGIN FIXME: this file have to be dowloaded from project repo, not from local dir
	cp "${ORIG_DIR}/driver-pipo-x8-script-files/0001-Input-goodix-add-changes-to-support-PIPO-X8.patch" .
	# wget https://github.com/Librerouter/Librekernel/blob/gh-pages/driver-pipo-x8-script-files/0001-Input-goodix-add-changes-to-support-PIPO-X8.patch" .
	# END FIXME
	cat 0001-Input-goodix-add-changes-to-support-PIPO-X8.patch | patch

	echo -e "obj-m += goodix.o\nall:\n\tmake -C /lib/modules/\$(shell uname -r)/build M=\$(PWD) modules\nclean:\n\tmake -C /lib/modules/\$(shell uname -r)/build M=\$(PWD) clean" > Makefile
	make
	#echo -n 'file gpiolib.c +p' > /sys/kernel/debug/dynamic_debug/control
	#echo -n 'file gpiolib-acpi.c +p' > /sys/kernel/debug/dynamic_debug/control
	#echo -n 'file property.c +p' > /sys/kernel/debug/dynamic_debug/control
	# Moving compiled module to proper path
	cp goodix.ko /lib/modules/$(uname -r)/kernel/drivers/input/touchscreen/
	# Running depmod to refresh modules dependency 
	depmod	
	modprobe goodix
}

# Internal Wireless NIC, non-free driver
function _wireless_internal() {
	echo do nothing
}

# Install just free drivers
function _free_drivers() {
	_touchscreen
}

function _non-free_drivers() {
	_wireless_internal
}

case $1 in
	free)
		_free_drivers
	;;

	non-free)
		_non-free_drivers
	;;
	
	all)
		_free_drivers
		_non-free_drivers

	;;

	*)
		echo "Usage:"
		echo " $0 free : Install just free drivers"
		echo " $0 non-free : Install just non-free drivers"
		echo " $0 all : Install free and non-free drivers"
	;;
esac
