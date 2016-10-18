#! /bin/sh
if [ `whoami` != root ]
then
	exec sudo su - root
else
	rm -f /etc/profile.d/zz-live-config_xinit.sh > /dev/null 2>&1
	. /usr/share/horus/scripts/horus-controller
fi
