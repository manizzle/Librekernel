# setup a py envi
# Some documentation about how to install and create nodes and clients seems have been changed
# Use venv/bin/tahoe --help to check the actual commands and syntaxis

 mkdir /home/tahoe-lafs
 cd /home/tahoe-lafs
 virtualenv venv
 venv/bin/pip install -U pip setuptools   # required or no bzip is recognized
 venv/bin/pip install tahoe-lafs[tor,i2p] # required with TOR + I2P
 venv/bin/pip install pyOpenSSL           # required by version of pyopenssl

# Start the SAM bridge to allow non Java apps connects to i2p sock 7656 on localhost
java -cp /usr/share/i2p/lib/sam.jar net.i2p.sam.SAMBridge &

# Create Tahoe node en /usr/node_1
 introducer="pb://hckqqn4vq5ggzuukfztpuu4wykwefa6d@publictestgrid.twilightparadox.com:50213,publictestgrid.lukas-pirl.de:50213,publictestgrid.e271.net:50213,68.62.95.247:50213/introducer"
 introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"
 venv/bin/tahoe create-node --listen=tor,i2p --nickname=perico --introducer=$introducer --hide-ip /usr/node_1

# Start the node_1
 /home/tahoe-lafs/venv/bin/tahoe start /usr/node_1 

#curl https://geti2p.net/en/download/0.9.28/clearnet/https/download.i2p2.de/i2psource_0.9.28.tar.bz2 > i2psource_0.9.28.tar.bz2
#bunzip i2psource_0.9.28.tar.bz2
#tar xf i2psource_0.9.28.tar
#cd i2p-0.9.28
#ant buildSAM

 connecting to Tor (to allocate .onion address)..
Tor connection established
allocating .onion address (takes ~40s)..


i2p-messenger
 venv/bin/tahoe create-client
 cat /root/.tahoe/tahoe.cfg  | sed -e "s/nickname =/nickname =yonodealeatorio/g"  > /root/.tahoe/tahoe_1.cfg
 mkdir introducer_1
 cd introducer_1
 tahoe create-introducer /usr/node_1
 tahoe create-node --listen=tor,i2p



backup done, elapsed time: 0:51:50 106MB =~ 34.64 KBps =~ 277 Kbps

 You'll just have to trust me that https://matador.cloud/introducer.furl contains pb://qjmgcplkluki2dt2rg75tumudm7m4sai@104.196.145.255:3458/j7mxn3zbvfybn3r6zlwmussnbj4ugaib



For SFTP ( SSHFS ) server:
apt-get install sshfs libghc-hfuse-dev
cd /usr/node_1
ssh-keygen -f private/ssh_host_rsa_key

Edit tahoe.cfg
[sftpd]
enabled = true
port = tcp:8022:interface=127.0.0.1
host_pubkey_file = private/ssh_host_rsa_key.pub
host_privkey_file = private/ssh_host_rsa_key
accounts.file = private/accounts

BASEDIR/private/accounts
USERNAME, PASSWORD, ROOTCAP

sshfs root@127.0.0.1:/Archives -p 8022 /usr/tahoe < nenuko
 rsync -azvc /usr/src/dhcp-4.3.5.tar.gz /usr/tahoe/Archives/Joaquin/.
-c is required because tahoe stores with new timestamp the files even -azv are issued

Para que i2p no resulte error SSL routines:SSL23_READ:ssl handshake failure
En fichero /etc/java-7-openjdk/security/java.security comentar la siguiente linea:
#### security.provider.10=sun.security.pkcs11.SunPKCS11 ${java.home}/lib/security/nss.cfg



PORT      STATE SERVICE
22/tcp    open  ssh
25/tcp    open  smtp
80/tcp    open  http
143/tcp   open  imap
3000/tcp  open  ppp
3128/tcp  open  squid-http
3306/tcp  open  mysql
4444/tcp  open  krb524 <- i2p
4445/tcp  open  upnotifyp <- i2p
5222/tcp  open  xmpp-client
5269/tcp  open  xmpp-server
6668/tcp  open  irc
8000/tcp  open  http-alt
8022/tcp  open  oa-system
8080/tcp  open  http-proxy
8090/tcp  open  unknown
8888/tcp  open  sun-answerbook
9050/tcp  open  tor-socks
10024/tcp open  unknown
20000/tcp open  dnp


******************************************
chequear /var/lib/i2p/i2p-config/clients.config
clientApp.0.startOnLoad=true
clientApp.1.startOnLoad=true
clientApp.2.startOnLoad=true
clientApp.3.startOnLoad=true
clientApp.4.startOnLoad=false
clientApp.5.startOnLoad=false


Reconnecting in 9 seconds (last attempt 13s ago)

    i2p:3ueszh34dvwqsvqf273anjfn3hmv4zv5q4eafp6zr5dcmkpdiska.b32.i2p:3457 via i2p: negotiation failed: [('SSL routines', 'SSL23_READ', 'ssl handshake failure')]


Trying to connect

    i2p:3ueszh34dvwqsvqf273anjfn3hmv4zv5q4eafp6zr5dcmkpdiska.b32.i2p:3457 via i2p: connecting

Reconnecting in 0 seconds (last attempt 2s ago)

    i2p:3ueszh34dvwqsvqf273anjfn3hmv4zv5q4eafp6zr5dcmkpdiska.b32.i2p:3457 via i2p: connection refused


===================================================================================================
Lab scenario:

venv/bin/tahoe --version
tahoe-lafs: 1.12.0 [master: 0cea91d73706e20dddad13233123375ceeaa7f0a]
foolscap: 0.12.6
pycryptopp: 0.7.1.869544967005693312591928092448767568728501330214
zfec: 1.4.24
Twisted: 16.6.0
Nevow: 0.14.2
zope.interface: unknown
python: 2.7.9
platform: Linux-debian_8.6-x86_64-64bit_ELF
pyOpenSSL: 16.2.0
OpenSSL: 1.0.1t [ 3 May 2016]
simplejson: 3.10.0
pycrypto: 2.6.1
pyasn1: 0.1.9
service-identity: 16.0.0
characteristic: 14.3.0
pyasn1-modules: 0.0.8
cryptography: 1.7.1
cffi: 1.9.1
six: 1.10.0
enum34: 1.1.6
pycparser: 2.17
PyYAML: 3.12
setuptools: 33.1.1
constantly: 15.1.0 [according to pkg_resources]
incremental: 16.10.1 [according to pkg_resources]
attrs: 16.3.0 [according to pkg_resources]
ipaddress: 1.0.18 [according to pkg_resources]
shutilwhich: 1.1.0 [according to pkg_resources]
idna: 2.2 [according to pkg_resources]



venv/bin/tahoe create-introducer --basedir=/usr/introducer --listen=i2p --i2p-sam-port=tcp:127.0.0.1:7656

ACERCA DE AREA PUBLICA
================================================================================================================
Crear el nodo todos con los mismos datos y clonarlo a todas las box
Es necesario generar las keys claro, solo en el master con ssh-key-gen

# Setup new py env and install required packages
apt-get install sshpass
mkdir /home/tahoe-lafs
cd /home/tahoe-lafs
virtualenv venv
venv/bin/pip install -U pip setuptools   # required or no bzip is recognized
venv/bin/pip install tahoe-lafs[tor,i2p] # required with TOR + I2P


# /usr/node_1 is used to store PRIVATE Tahoe node_1
# /usr/private_node is used to store ( shared ) common PUBLIC Tahoe node
# /var/node_1 is a mount point for node_1 FUSE
# /var/private_node is a mount point for node public_node FUSE

# Get root pub rsa key
# The pub key must be used on the private/accounts
# The priv will be just the link added to /etc/ssh/ssh_config

echo"Host [127.0.0.1]" >> /etc/ssh/ssh_config
echo"  Port = 8022"    >> /etc/ssh/ssh_config
echo"  IdentityFile  = \"/root/.ssh/id_rsa\"" >> /etc/ssh/ssh_config
echo"  User = \"root\"" >> /etc/ssh/ssh_config

rootpubkey=$(cat /root/.ssh/id_rsa.pub | cut -d \  -f 1,2)

# Create private node
cd /home/tahoe-lafs 
nickname="liberouter_client1"
introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"
/home/tahoe-lafs/venv/bin/tahoe create-node --listen=tor --nickname=$nickname --introducer=$introducer --hide-ip --webport=tcp:3456:interface=127.0.0.1 /usr/node_1
echo "root $rootpubkey URI:DIR2:xywgxo *****DESCUBRIR***** 4q" > private/accounts
cd /usr/node_1
echo < EOT
[sftpd]
enabled = true
port = tcp:8022:interface=127.0.0.1
host_pubkey_file = private/ssh_host_rsa_key.pub
host_privkey_file = private/ssh_host_rsa_key
accounts.file = private/accounts
EOT >> tahoe.cfg
ssh-keygen -f private/ssh_host_rsa_key
mkdir /var/node_1


# Create public node ( common to all boxes ) with rw permisions
cd /home/tahoe-lafs
nickname=public
introducer="pb://hootxde72nklvu2de3n57a3szfkbazrd@tor:3h3ap6f4b62dvh3m.onion:3457/7jho3gaqpsarnvieg7iszqm7zsffvzic"
/home/tahoe-lafs/venv/bin/tahoe create-node --listen=tor --nickname=$nickname --introducer=$introducer --hide-ip --webport=tcp:9456:interface=127.0.0.1 /usr/public_node
echo "root $rootpubkey URI:DIR2:xywgxowwjey7d67ijjgvcmepmi:537ficpuwshi7gzxquqotswlv52pe6sft2f5qhkq6nbmlcl6aj4q" > private/accounts 
cd /usr/public_node
echo < EOT
[sftpd]
enabled = true
port = tcp:8024:interface=127.0.0.1
host_pubkey_file = private/ssh_host_rsa_key.pub
host_privkey_file = private/ssh_host_rsa_key
accounts.file = private/accounts
EOT >> tahoe.cfg
ssh-keygen -f private/ssh_host_rsa_key
mkdir /var/public_node

# Now prepare to bypass sshfs password and ssh password when mount these partitions on INI_SCRIPT
# take the priv key /root/.ssh/id_rsa and place as pass column into /usr/public_node/private/accounts



# INIT_SCRIPT to start these TWO nodes and mount FUSE
/home/tahoe-lafs/venv/bin/tahoe start /usr/private_node
/home/tahoe-lafs/venv/bin/tahoe start /usr/node_1

sshfs root@127.0.0.1:/Archives -p 8022 /var/node_1 < nenuko
sshfs root@127.0.0.1:/Archives -p 8024 /var/public_node < pamplina
