
#====================================================

# Setup new py env and install required packages if not existing

#if [ ! -x /home/tahoe-lafs]; then
    apt-get install sshpass
    mkdir /home/tahoe-lafs
    cd /home/tahoe-lafs
    virtualenv venv
    venv/bin/pip install -U pip setuptools   # required or no bzip is recognized
    venv/bin/pip install tahoe-lafs[tor,i2p] # required with TOR + I2P
#fi

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

# Create private node
cd /home/tahoe-lafs 
nickname="liberouter_client1"
introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"
/home/tahoe-lafs/venv/bin/tahoe create-node --listen=tor --nickname=$nickname --introducer=$introducer --hide-ip --webport=tcp:3456:interface=127.0.0.1 /usr/node_1
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


random_user=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})
random_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12})
echo "$random_user $random_pass" > /root/.tahoe/public_node

# Create public node ( common to all boxes ) with rw permisions
cd /home/tahoe-lafs
nickname=public
introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"
/home/tahoe-lafs/venv/bin/tahoe create-node --listen=tor --nickname=$nickname --introducer=$introducer --hide-ip --webport=tcp:9456:interface=127.0.0.1 /usr/public_node
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


# Now we need to start both nodes, to allow discoveing on URL:DIR2 for each

/home/tahoe-lafs/venv/bin/tahoe start /usr/node_1
/home/tahoe-lafs/venv/bin/tahoe start /usr/public_node
sleep 5;

# Let's go to discover it
mkdir /root/.tahoe/private
/home/tahoe-lafs/venv/bin/tahoe create-alias -u http://127.0.0.1:3456 node_1:
/home/tahoe-lafs/venv/bin/tahoe create-alias -u http://127.0.0.1:9456 public_node:

URI1=$(/home/tahoe-lafs/venv/bin/tahoe manifest -u http://127.0.0.1:3456 node_1: | head -n 1)
URI2=$(/home/tahoe-lafs/venv/bin/tahoe manifest -u http://127.0.0.1:9456 public_node: | head -n 1)

# Update the /private/accounts
echo -n $URI1 >> /usr/node_1/private/accounts
echo -n URI:DIR2:rjxappkitglshqppy6mzo3qori:nqvfdvuzpfbldd7zonjfjazzjcwomriak3ixinvsfrgua35y4qzq >> /usr/public_node/private/accounts
updatednode_1=$(sed -e "s/FALSE/ /g" /usr/node_1/private/accounts )
updatedpubic_node=$(sed -e "s/FALSE/ /g" /usr/public_node/private/accounts )
echo $updatednode_1 > /usr/node_1/private/accounts
echo $updatedpubic_node > /usr/public_node/private/accounts


# Local access funtions (SSH support or SSHFS )
ssh-keyscan -H -p 8022 127.0.0.1 | grep \|1\| |grep -v "no hostkey" |grep -v Twisted >> /root/.ssh/known_hosts
ssh-keyscan -H -p 8024 127.0.0.1 | grep \|1\| |grep -v "no hostkey" |grep -v Twisted >> /root/.ssh/known_hosts




# Done, now we can restart the nodes




