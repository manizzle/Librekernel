#!/bin/sh
echo "script instalacion"
#echo "p" > /target/root/key2
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 18 >> /target/root/key2
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10 >> /target/root/passroot
printf "root:" >> /target/root/pass1
cat /target/root/passroot >> /target/root/pass1

#cat /target/root/pass1 | /target/usr/sbin/chpasswd
cat /target/root/key2 | cryptsetup luksAddKey /dev/sda5 -d=/target/root/key1 -S 6
cat /target/root/key1 | cryptsetup luksRemoveKey /dev/sda5 -S=1


mount -o remount,rw /cdrom
cp /target/root/key2 /cdrom/clave.$(date '+%Y-%m-%d_%H-%M')
cp /target/root/passroot /cdrom/passroot.$(date '+%Y-%m-%d_%H-%M')

#rm /target/root/*
#cat /target/root/key2
#chroot /target 
cat /target/root/pass1 | chroot /target chpasswd
#chroot target
#apt-get install ntpdate
echo "Fin script instalacion"
