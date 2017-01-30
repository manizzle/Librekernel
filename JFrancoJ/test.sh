#!/bin/bash

# This scirpt will prompt user for ALIAS name and PASSWORD on clean installation.
# This clean ALIAS will be saved to Public tahoe area with contents an encrypted string
# The decrypted string will point to the Private tahoe area for this box
#
# This script must be launched AFTER app_install_tahoe.sh and AFTER app_start_tahoe.sh

#if [ -f /tmp/.X0-lock ];
#then
#Dialog=Xdialog
#else
#Dialog=dialog
#fi

# This user interface will detect the enviroment and will chose a method based
# on this order : X no GTK, X with GTK , dialaog, none )

if [ -x /usr/bin/dialog  | /bin/dialog ]; then
    interface=dialog
else 
    inteface=none
    if [ -f /tmp/.X0-lock ]; then
        interface=X
        if [ -x /usr/bin/gtk]; then
            inteface=Xdialog
        fi
    fi
fi

echo "INTERFACE $interface";


prompt() {

textmsg="Enter some easy to remember ID here. \nThis will be used in case you need to recover your full system configuration from backup\n\
This id may be public visible\n\n\
Use an enough hard password with minimum 8 bytes and write down in a safe place.\n\n";

if [ ${#errmsg} -gt 0 ]; then
    textmsg=$textmsg\\Z1$errmsg
    errmsg=""
fi



if [ $interface = "dialog" ]; then

dialog --colors \
--form "$textmsg" 0 0 3 \
"Enter your alias:" 1 2 "$myalias"  1 20 20 20 \
"Passwod:" 2 2 "" 2 20 20 20 \
"Repeat Password:" 3 2 "" 3 20 20 20 2> /tmp/inputbox.tmp

credentials=$(cat /tmp/inputbox.tmp)
rm /tmp/inputbox.tmp
thiscounter=0
local IFS='
'
for lines in $credentials; do
#while IFS= read -r lines; do
    if [ $thiscounter = "0" ]; then 
        myalias="$lines"
    fi
    if [ $thiscounter = "1" ]; then 
        myfirstpass="$lines"
    fi
    if [ $thiscounter = "2" ]; then 
        mysecondpass="$lines"
    fi
    ((thiscounter++));    
done 

else

read -p "Enter some easy to remember ID here. \nThis will be used in case you need to recover your full system configuration from backup\n\
This id may be public visible\n\n\
What is your username? " -e myalias

read -p "Use an enough hard password with minimum 8 bytes and write down in a safe place.\n\n
Passwod:" -e myfirstpass

read -p "Repeat Passwod:" -e mysecondpass

fi


}


check_inputs() {

errmsg="";
# Are valid all these inputs ?
if [ -z "${myalias##*" "*}" ]; then
    errmsg="Spaces are not allowed";
fi

strleng=${#myalias}
if [[ $strleng -lt 8 ]]; then
    errmsg="$myalias ${#myalias} Must be at least 8 characters long"
fi

if [ -z "${myfirstpass##*" "*}" ]; then
    errmsg="Spaces are not allowed";
fi

strleng=${#myfirstpass}
if [[ $strleng -lt 8 ]]; then
    errmsg="$myfirstpass ${#myalias} Must be at least 8 characters long"
fi

if [ $myfirstpass != $mysecondpass ]; then
    errmsg="Please repeat same password"
fi

while [ ${#errmsg} -gt 0 ]; do
    echo "ERROR: $errmsg$errmsg2"
    prompt
done
  
}


prompt
check_inputs
echo Your name is $myalias
echo Clave $myfirstpass
echo Clave $mysecondpass

# Convert this alias to encrypted key with pass=$myfirstpass and save as $myalias

# creates PEM 
ssh-keygen -N '$myfirstpass' -f /tmp/ssh_keys
openssl rsa  -passin pass:$myfirstpass -outform PEM  -in /tmp/ssh_keys -pubout > /tmp/rsa.pem.pub

# create a key phrase for the private backup Tahoe node config and upload to public/$myalias file
# the $phrase is the entry point to the private area (pb:/ from /usr/node_1/tahoe.cfg )
# $phrase will be like "URI:DIR2:guq3z6e68pf2bvwe6vdouxjptm:d2mvquow4mxoaevorf236cjajkid5ypg2dgti4t3wgcbunfway2a"
frase=$(/home/tahoe-lafs/venv/bin/tahoe manifest -u http://127.0.0.1:3456 node_1: | head -n 1)
echo $frase | openssl rsautl -encrypt -pubin -inkey /tmp/rsa.pem.pub  -ssl > /var/public_node/$myalias

# Decrypt will be used for restore only, and will discover the requied URI:DIR2 value for the private area node
# cat /var/public_node/$myalias | openssl rsautl -decrypt -inkey /tmp/ssh_keys # < Will prompt for password to decrypt it




exit


