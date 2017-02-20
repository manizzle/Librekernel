
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

