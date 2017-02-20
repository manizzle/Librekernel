

# Start nodes
/home/tahoe-lafs/venv/bin/tahoe stop /usr/public_node
/home/tahoe-lafs/venv/bin/tahoe stop /usr/node_1

/home/tahoe-lafs/venv/bin/tahoe start /usr/public_node
/home/tahoe-lafs/venv/bin/tahoe start /usr/node_1

# Wait until enough connections on both nodes
# because if not enough storage nodes the upload will be placed on few nodes and this
# affects performance 
connnode_1=0
connpubnod=0
while [ $connnode_1 -lt 7 ] || [ $connpubnod -lt 7 ]; do
connnode_1=$(curl http://127.0.0.1:3456/ 2> /dev/null| grep "Connected to tor" | wc -l)
connpubnod=$(curl http://127.0.0.1:9456/ 2> /dev/null| grep "Connected to tor" | wc -l)
echo "Node_1 cons: $connnode_1 P_node cons: $connpubnod"
done

# Mount points
if [ -e /root/.tahoe/node_1 ]; then
  umount /var/node_1
  user=$(cat /root/.tahoe/node_1 | cut -d \  -f 1)
  pass=$(cat /root/.tahoe/node_1 | cut -d \  -f 2)
  echo $pass | sshfs $user@127.0.0.1:  /var/node_1  -p 8022 -o no_check_root -o password_stdin
fi

if [ -e /root/.tahoe/public_node ]; then
  umount /var/public_node
  user=$(cat /root/.tahoe/public_node | cut -d \  -f 1)
  pass=$(cat /root/.tahoe/public_node | cut -d \  -f 2)
  echo $pass | sshfs $user@127.0.0.1:  /var/public_node  -p 8024 -o no_check_root -o password_stdin
fi


