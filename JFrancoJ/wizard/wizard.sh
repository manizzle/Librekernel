
prompt() {
      
  textmsg="\nUse an enough hard password with minimum 8 bytes and write down in a safe place.\n";
    
  if [ ${#errmsg} -gt 0 ]; then
    color='\033[0;31m'
    nocolor='\033[0m'
    textmsg="${nocolor}$textmsg ${color} $errmsg"
    errmsg=""
  fi

  if [ $interface = "dialog" ]; then
    dialog --colors --form "$textmsg" 0 0 3 "New Passwod:" 1 2 "" 1 20 20 20 "Repeat Password:" 2 2 "" 2 20 20 20 2> /tmp/inputbox.tmp
    credentials=$(cat /tmp/inputbox.tmp)
    rm /tmp/inputbox.tmp
    thiscounter=0
local IFS='
'
  for lines in $credentials; do
  #while IFS= read -r lines; do
    if [ $thiscounter = "0" ]; then
        myfirstpass="$lines"
    fi
    if [ $thiscounter = "1" ]; then
        mysecondpass="$lines"
    fi
    ((thiscounter++));
  done

  else
    echo -e $textmsg${nocolor}
    read -p "New Passwod:" -e myfirstpass
    read -p "Repeat Passwod:" -e mysecondpass
  fi

}



update_root_pass() {
  salt=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8})
  method_name="-msha-512"
  new_enc=$(mkpasswd $method_name $plain_pass $salt)
  echo $new_enc
  usermod -p "$new_enc" joa2
}


ofuscate () {
    thiscounter=0
    output=''
    while [ $thiscounter -lt 30 ]; do
        ofuscated=$ofuscated${myalias:$thiscounter:1}$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-4})
        ((thiscounter++));
    done
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
    check_inputs
  done

}





update_public_node_method1() {
  # creates PEM
  rm /tmp/ssh_keys*
  ssh-keygen -N $myfirstpass -f /tmp/ssh_keys 2> /dev/null
  openssl rsa  -passin pass:$myfirstpass -outform PEM  -in /tmp/ssh_keys -pubout > /tmp/rsa.pem.pub
    
  # create a key phrase for the private backup Tahoe node config and upload to public/$myalias file
  # the $phrase is the entry point to the private area (pb:/ from /usr/node_1/tahoe.cfg )
  # $phrase will be like "user pass URI:DIR2:guq3z6e68pf2bvwe6vdouxjptm:d2mvquow4mxoaevorf236cjajkid5ypg2dgti4t3wgcbunfway2a"
  #frase=$(/home/tahoe-lafs/venv/bin/tahoe manifest -u http://127.0.0.1:3456 node_1: | head -n 1)
  frase=$(cat /usr/node_1/private/accounts | head -n 1)
  echo $frase | openssl rsautl -encrypt -pubin -inkey /tmp/rsa.pem.pub  -ssl > /tmp/$myalias
  mv /tmp/$myalias /var/public_node/$myalias
  ofuscate
  cp /tmp/ssh_keys  /var/public_node/.keys/$ofuscated
}



update_public_node_method2() {
  serial_number=$(cat /root/libre_scripts/sn)
  salt=$(cat /etc/shadow | head -n 1 | cut -d \$ -f 3 | cut -d : -f 1)
  sne=$(mkpasswd  -msha-512 $serial_number $salt | tr / _ | tr \$ 1)
  echo $salt > /var/public_node/$serial_number
  p=$(cat /etc/shadow | head -n 1 | cut -d \$ -f 4 | cut -d : -f 1)
  rm /tmp/ssh_keys
  ssh-keygen -N $p -f /tmp/ssh_keys 2> /dev/null
  openssl rsa  -passin pass:$p -outform PEM  -in /tmp/ssh_keys -pubout > /tmp/rsa.pem.pub
  frase=$(cat /usr/node_1/private/accounts | head -n 1)
  echo $frase | openssl rsautl -encrypt -pubin -inkey /tmp/rsa.pem.pub  -ssl > /tmp/$sne
  mv /tmp/$sne /var/public_node/$sne
  cp /tmp/ssh_keys /var/public_node/.keys/$sne

}

update_def() {
  # cryptsetup luksOpen /dev/xvdc backup2
  # TODO add update def
  # cryptsetup luksChangeKey <target device> -S <target key slot number>
  echo "TODO: add update DEF"
}

check_internet() {
  processed=0
  (items=2;while [ $processed -le $items ]; do pct=$processed ; echo "Checking Internet..."   ;echo "$pct"; processed=$((processed+1)); sleep 0.1; done; ) | dialog --title "Librerouter Setup" --gauge "Checking Internet" 10 60 0
  if [ ! $(ntpdate -q hora.rediris.es | grep "no server") ]; then
    internet=1
    (items=25;while [ $processed -le $items ]; do pct=$processed ; echo "Checking Internet..."   ;echo "$pct"; processed=$((processed+1)); sleep 0.1; done; ) | dialog --title "Librerouter Setup " --gauge "Checking internet..." 10 60 0

  fi
  sleep 1
}

check_ifaces() {
  options=""
  concat=" - "
  wireds=$(ls /sys/class/net) 
  for wired in $wireds ; do
   if [[ $wired =~ "eth" ]] || [[ $wired =~ "wlan" ]]; then
     ups=$(cat /sys/class/net/$wired/operstate)
     options="$options $wired $ups"
   fi

  done
}

no_internet() {
  # We have NOT internet connection, but we have detected wired and/or wlan devices
  # so we will ask user what device will be use for connect to his/her internet router
  # once selected :
  # if wlan : scanning, show AP, prompt for AP password, try to connect and dhclient
  # if eth: try dhclient
  # if dhclient fails : ask user to enter IP, mask and default gw IP for the selected interface ( any ) 
  # 

  if [ ! $inet_iface ]; then
    dialog --colors --title "Librerouter Setup" --menu "Please select the interface you are using to connect to internet router (wan): " 25 40 55 $options 2> /tmp/inet_iface
    retval=$?
    if [ $retval == "1" ]; then
      exit
    fi
    inet_iface=$(cat /tmp/inet_iface)
  fi
  if [[ $inet_iface =~ "wlan" ]]; then
    # Here the user have selected WAN interface
    # We need to offer available ESSID and prompt for AP password
    # Let's go to fetch all AP's ESSID  in the area and quality of each one
    ifconfig $inet_iface up
    scanning=$(iwlist $inet_iface scanning)
    essids=$(echo "$scanning" | grep ESSID | cut -d : -f 2 | cut -d '"' -f 2)
    qualities=$(echo "$scanning" | grep Quality | cut -d = -f 2 | cut -d / -f 1)
    o=0
    for q in $qualities; do
      quality[$o]=$q
      o=$((o+1))
    done

    o=0
    options=""
    for essid in $essids; do
      options="$options $essid ${quality[$o]}"
      o=$((o + 1))
    done
  
 
    dialog --colors --title "Librerouter Setup" --extra-button --extra-label "Re-scan" --menu "Please select your Access Point : " 25 40 55 $options 2> /tmp/essid
    retval=$?
    if [ $retval == "3" ]; then
      check_ifaces
      no_internet
    fi
    if [ $retval == "1" ]; then
      exit
    fi
    essid=$(cat /tmp/essid)

    while [ ${#wifi_pass} -lt 8 ]; do
    
      dialog --colors --title "Librerouter Setup" --extra-button --extra-label "Back" --form "Enter your WIFI Access Point password, minimun 8 characters" 0 0 1 "WIFI Password:" 1 2 "" 1 20 20 20 2> /tmp/wifipass
      retval=$?
      if [ $retval == "3" ]; then
        check_ifaces
        no_internet
      fi
      wifi_pass=$(cat /tmp/wifipass)
    done


    mkdir /etc/wpa 2> /dev/null
    echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=root\n" > /etc/wpa/_supplicant.conf
    wpa_passphrase $essid $wifi_pass >> /etc/wpa/_supplicant.conf

    # Conectamos al AP 
    while [[ $(ps auxwww) =~ "wpa_supplicant" ]]; do
       killall wpa_supplicant
       sleep 1
    done
    wpa_supplicant -B -c/etc/wpa/_supplicant.conf -Dwext -i$inet_iface
  fi

}




try_dhcp() {
    dialog --title "Librerouter Setup"  --infobox "Trying DHCP for interface $inet_iface ... Please wait" 0 0
    dhclient $inet_iface  1> /dev/null 2> /dev/null &
    sleep 5
    killall dhclient 1> /dev/null 2> /dev/null
}

set_ipmaskgw() {
    local IFS=$'\n'
    dialog --colors --title "Librerouter Setup" --extra-button --extra-label "Back" --form "$err\n\ZnEnter your network params for connect to internet router" 0 0 3 "IP:" 1 2 "$iface_ip" 1 20 20 20 "Mask:" 2 2 "255.255.255.0" 2 20 20 20 "Gateway:" 3 2 "$gw" 3 20 20 20 2> /tmp/network_ipmaskgw
    retval=$?
    if [ $retval == "3" ]; then
      check_ifaces
      no_internet
    fi
    if [ $retval == "1" ]; then
      exit
    fi
    ipmaskgw=$(cat /tmp/network_ipmaskgw)
    thiscounter=0
    for lines in $ipmaskgw; do
      if [ $thiscounter = "0" ]; then 
        iface_ip="$lines"
      fi
      if [ $thiscounter = "1" ]; then 
        mask="$lines"
      fi
      if [ $thiscounter = "2" ]; then 
        gw="$lines"
      fi
      ((thiscounter++))
    done
#    netcalc $iface_ip $mask
#    bcastcalc $iface_ip $mask
    check_gw $gw $mask
}


netcalc(){

    local IFS='.' ip i
    local -a oct msk
        
    read -ra oct <<<"$1"
    read -ra msk <<<"$2"

    for i in ${!oct[@]}; do
        ip+=( "$(( oct[i] & msk[i] ))" )
    done
    
    net="${ip[*]}"
    read -ra oct <<<"${ip[*]}"
    dec_net=$((256*256*256*oct[0]+256*256*oct[1]+256*oct[2]+oct[3]))
}

bcastcalc(){

    local IFS='.' ip i
    local -a oct msk
	
    read -ra oct <<<"$1"
    read -ra msk <<<"$2"

    for i in ${!oct[@]}; do
        ip+=( "$(( oct[i] + ( 255 - ( oct[i] | msk[i] ) ) ))" )
    done

    bcast="${ip[*]}"
    read -ra oct <<<"${ip[*]}"
    dec_bcast=$((256*256*256*oct[0]+256*256*oct[1]+256*oct[2]+oct[3]))
}

check_gw() {
    # Check if gw address is valid
    local IFS='.' ip i
    local -a oct msk
    read -ra oct <<<"$1"
    dec_gw=$((256*256*256*oct[0]+256*256*oct[1]+256*oct[2]+oct[3]))
    echo "Valores GW:$dec_gw NET:$dec_net BC:$dec_bcast"
    if [ ! $(expr "$gw" : "^[0-9.]*$") -gt 0 ];then
        err="\Z1\ZbError: Gateway $gw Invalid value.\ZB\Zn"
        set_ipmaskgw
    fi
    if [ ! $(expr "$iface_ip" : "^[0-9.]*$") -gt 0 ];then
        err="\Z1\ZbError: IP $iface_ip Invalid value.\ZB\Zn"
        set_ipmaskgw
    fi
    if [ ! $(expr "$mask" : "^[0-9.]*$") -gt 0 ];then
        err="\Z1\ZbError: Mask $mask Invalid value.\ZB\Zn"
        set_ipmaskgw
    fi

    netcalc $iface_ip $mask
    bcastcalc $iface_ip $mask

    if [ $dec_gw -lt $dec_net ] || [ $dec_bcast -lt $dec_gw ]; then
        err="\Z1\ZbError: Gateway $gw doesn't match Mask $mask GW:$dec_gw NET:$dec_net BC:$dec_bcast\ZB\Zn"
        set_ipmaskgw
    else
        ifconfig $inet_iface $iface_ip $mask 2> /dev/null
        route add default gw $gw 2> /dev/null
    fi
}


save_network() {
  if [[ $inet_iface =~ "eth" ]]; then
    networks=$(cat /etc/network/interfaces)
    # netcalc $iface_ip $mask
    if [[ $networks =~ "iface $inet_iface inet dhcp" ]]; then
      patching=$(sed -e "s/iface $inet_iface inet dhcp/        iface $inet_iface inet static
            address $iface_ip
            netmask $mask
            network $net
      /g" /etc/network/interfaces /tmp/interfaces)
    else
     echo -e "$networks" > /tmp/interfaces
     echo -e "\n        iface $inet_iface inet static\n            address $iface_ip\n            netmask $mask\n            network $net" >> /tmp/interfaces
    fi
    
  fi

  if [[ $inet_iface =~ "wlan" ]]; then
     cat <<EOT  | grep -v EOT> /etc/init.d/start_wifi_client
#!/bin/sh
### BEGIN INIT INFO
# Provides: librerouter_wifi_client
# Required-Start: $syslog
# Required-Stop: $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: wifi_client
# Description:
#
### END INIT INFO

# Start WIFI internet connection as client of AP

    while [[ \$(ps auxwww) =~ "wpa_supplicant" ]]; do
       killall wpa_supplicant
       sleep 1
    done
    wpa_supplicant -B -c/etc/wpa/_supplicant.conf -Dwext -i$inet_iface
  fi

EOT

      chmod u+x /etc/init.d/start_wifi_client
      update-rc.d start_wifi_client defaults
  fi
}






# This user interface will detect the enviroment and will chose a method based
# on this order : X no GTK, X with GTK , dialaog, none )

interface=0
if [ -x n/usr/bin/dialog ] || [ -x n/bin/dialog ]; then
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

check_internet
echo $internet
if [ $internet == "1" ]; then
  check_ifaces
  no_internet
  try_dhcp
  check_internet
  if [ $internet == "1" ]; then
    set_ipmaskgw
    check_internet
    if [ $internet == "0" ]; then
      dialog --title "Librerouter Setup"  --infobox "Something gone wrong. May be you entered wrong password for your WIFI, or may be you have not plugged the ethernet wire in the right slot" 0 0
      exit
    else
      save_network
    fi
  fi
fi


exit





prompt
check_inputs
update_root_pass
update_public_node_method1
#update_def
