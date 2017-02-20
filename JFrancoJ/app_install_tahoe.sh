
#====================================================



if [ -e /home/tahoe-lafs ]; then
    textmsg="Thee already installed, do you want to delete and re-install a new one [no/yes]?"
    read -p "$textmsg" -e install
    if [ "$install" != "yes" ]; then
       exit
    fi
fi


if [ ! -e /var/run/tor_tahoe ]; then
    # Crear instancia de Tor solo para Tahoe

    mkdir /var/run/tor_tahoe
    chown debian-tor.debian-tor /var/run/tor_tahoe
    cp -dpR /var/lib/tor /var/lib/tor_tahoe
    # ******* Crer fichero de configuracion y de arranque posterior de tor_tahoe *************
    cat <<EOT  | grep -v EOT>> /etc/tor/torrc_tahoe
DataDirectory /var/lib/tor_tahoe
PidFile /var/run/tor_tahoe/tahoe_tor.pid
RunAsDaemon 1
User debian-tor

ControlSocket /var/run/tor_tahoe/control GroupWritable RelaxDirModeCheck
ControlSocketsGroupWritable 1
SocksPort unix:/var/run/tor_tahoe/socks WorldWritable
SocksPort 9052

CookieAuthentication 1
CookieAuthFileGroupReadable 1
CookieAuthFile /var/run/tor_tahoe/control.authcookie

Log notice file /var/log/tor/tahoe_log
EOT


fi

/usr/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc -f /etc/tor/torrc_tahoe --RunAsDaemon 0 &


/home/tahoe-lafs/venv/bin/tahoe stop /usr/node_1
/home/tahoe-lafs/venv/bin/tahoe stop /usr/public_node
rm -rf /home/tahoe-lafs
rm -rf /usr/node_1
rm -rf /root/.tahoe
rm -rf /usr/public_node

ssh-keygen -f "/root/.ssh/known_hosts" -R [localhost]:8022
ssh-keygen -f "/root/.ssh/known_hosts" -R [localhost]:8024


# Setup new py env and install required packages if not existing

#if [ ! -x /home/tahoe-lafs]; then
    apt-get install sshpass
    apt-get install sshfs
    mkdir /home/tahoe-lafs
    cd /home/tahoe-lafs
    virtualenv venv
    venv/bin/pip install -U pip setuptools   # required or no bzip is recognized
    venv/bin/pip install tahoe-lafs[tor,i2p] # required with TOR + I2P
#fi


# VERY IMPORTANT. FIX a bug that causes max file uploadaed through sshfs/sftp 
# comes to zero size if size > 55 bytes. 
# This happens some times ( 50% aprox repeatable ) not only on inmutable but also on mutables

# The fix is /home/tahoe-lafs/venv/lib/python2.7/site-packages/allmydata/immutable/upload.py file line 1519 must:
# -URI_LIT_SIZE_THRESHOLD = 55
# +URI_LIT_SIZE_THRESHOLD = 55555 

#cd /home/tahoe-lafs/venv/lib/python2.7/site-packages/allmydata/immutable
#patching=$(sed -e "s/URI_LIT_SIZE_THRESHOLD = 55/URI_LIT_SIZE_THRESHOLD = 55/g" upload.py > /tmp/upload.py.patched)
#mv /tmp/upload.py.patched /home/tahoe-lafs/venv/lib/python2.7/site-packages/allmydata/immutable/upload.py
#cd /home/tahoe-lafs/venv/lib/python2.7/site-packages/allmydata/immutable; python -m py_compile upload.py


# python -m py_compile upload.py


# /usr/node_1 is used to store PRIVATE Tahoe node_1
# /usr/private_node is used to store ( shared ) common PUBLIC Tahoe node
# /var/node_1 is a mount point for node_1 FUSE
# /var/private_node is a mount point for node public_node FUSE

mkdir /root/.tahoe

# Create private node
# Prepare random user/pass for mount this node
random_user=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})
random_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})
echo "$random_user $random_pass" > /root/.tahoe/node_1

# Discover URI:DIR2 for the root
# This of course must be done AFTER the node is started and connected, so we will need
# to restart the node after update private/accounts

cd /home/tahoe-lafs 
nickname="liberouter_client1"
introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"


/home/tahoe-lafs/venv/bin/tahoe create-node --listen=tor --nickname=$nickname --introducer=$introducer --hide-ip --webport=tcp:3456:interface=127.0.0.1 --tor-control-port=unix:/var/run/tor_tahoe/control /usr/node_1
cd /usr/node_1
echo "$random_user $random_pass FALSE" > private/accounts
cat <<EOT  | grep -v EOT>> tahoe.cfg
[sftpd]
enabled = true
port = tcp:8022:interface=127.0.0.1
host_pubkey_file = private/ssh_host_rsa_key.pub
host_privkey_file = private/ssh_host_rsa_key
accounts.file = private/accounts
EOT
echo "Generamos keys para node_1"
ssh-keygen -q -N '' -f private/ssh_host_rsa_key
mkdir /var/node_1

# Create public node ( common to all boxes ) with rw permisions

random_user=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})
random_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})
echo "$random_user $random_pass" > /root/.tahoe/public_node

cd /home/tahoe-lafs
nickname=public
introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"
/home/tahoe-lafs/venv/bin/tahoe create-node --listen=tor --nickname=$nickname --introducer=$introducer --hide-ip --webport=tcp:9456:interface=127.0.0.1 --tor-control-port=unix:/var/run/tor_tahoe/control /usr/public_node
cd /usr/public_node
echo "$random_user $random_pass FALSE" > private/accounts
cat <<EOT  | grep -v EOT>> tahoe.cfg
[sftpd]
enabled = true
port = tcp:8024:interface=127.0.0.1
host_pubkey_file = private/ssh_host_rsa_key.pub
host_privkey_file = private/ssh_host_rsa_key
accounts.file = private/accounts
EOT

ssh-keygen -q -N '' -f private/ssh_host_rsa_key
mkdir /var/public_node


# Now we need to start both nodes, to allow discoveing on URL:DIR2 for node_1
echo "Starting nodes to allow URL:DIR2 discovering for node_1" 
/home/tahoe-lafs/venv/bin/tahoe start /usr/node_1
/home/tahoe-lafs/venv/bin/tahoe start /usr/public_node
# this waiting time is required, otherwise sometimes nodes even started are not yet ready to create aliases and fails conneting with http with "500 Internal Server Error"
sleep 30;

# Extra check both nodes are OK and connected through Tor
# via tor: failed to connect: could not use config.SocksPort
connection_status_node_1=$(curl http://127.0.0.1:3456 | grep -v grep | grep "via tor: failed to connect: could not use config.SocksPort")
connection_status_public_node=$(curl http://127.0.0.1:9456 | grep -v grep | grep "via tor: failed to connect: could not use config.SocksPort")

if [ ${#connection_status_node_1} -gt 3 ] || [ ${#connection_status_public_node} -gt 3 ]; then 
   echo "Error: Can NOT connect to TOR. Please check tor configuration file. This is ussualy due to SocksPort 127.0.0.1:port, use just port "
   echo "Fix this issue, restart TOR and try again."
   exit;
fi

# Let's go to discover it
echo "Creating aliases for Tahoe..."
mkdir /root/.tahoe/private
/home/tahoe-lafs/venv/bin/tahoe create-alias -u http://127.0.0.1:3456 node_1:
/home/tahoe-lafs/venv/bin/tahoe create-alias -u http://127.0.0.1:9456 public_node:

echo "Fetching URL:DIR2 for node_1"
URI1=$(/home/tahoe-lafs/venv/bin/tahoe manifest -u http://127.0.0.1:3456 node_1: | head -n 1)
# URI2=$(/home/tahoe-lafs/venv/bin/tahoe manifest -u http://127.0.0.1:9456 public_node: | head -n 1)
echo "$URI1 fetched"

# Update the /private/accounts
echo -n $URI1 >> /usr/node_1/private/accounts
echo -n URI:DIR2:rjxappkitglshqppy6mzo3qori:nqvfdvuzpfbldd7zonjfjazzjcwomriak3ixinvsfrgua35y4qzq >> /usr/public_node/private/accounts
updatednode_1=$(sed -e "s/FALSE/ /g" /usr/node_1/private/accounts )
updatedpubic_node=$(sed -e "s/FALSE/ /g" /usr/public_node/private/accounts )
echo $updatednode_1 > /usr/node_1/private/accounts
echo $updatedpubic_node > /usr/public_node/private/accounts


# Local access funtions (SSH support or SSHFS )
echo "Host 127.0.0.1" >> /etc/ssh/ssh_config
echo "  HostName localhost"  >> /etc/ssh/ssh_config
echo "  Port 8022"  >> /etc/ssh/ssh_config
echo "  StrictHostKeyChecking no"  >> /etc/ssh/ssh_config
echo  >> /etc/ssh/ssh_config
echo "Host 127.0.0.1" >> /etc/ssh/ssh_config
echo "  HostName localhost"  >> /etc/ssh/ssh_config
echo "  Port 8024"  >> /etc/ssh/ssh_config
echo "  StrictHostKeyChecking no"  >> /etc/ssh/ssh_config
echo  >> /etc/ssh/ssh_config


# Done, now we can restart the nodes




