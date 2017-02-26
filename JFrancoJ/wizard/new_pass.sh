plain_pass="perico"



update_root_pass() {
  salt=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8})
  method_name="-msha-512"
  new_enc=$(mkpasswd $method_name $plain_pass $salt)
  echo $new_enc
  usermod -p "$new_enc" joa2
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

update_def()  {
  # cryptsetup luksOpen /dev/xvdc backup2

}
