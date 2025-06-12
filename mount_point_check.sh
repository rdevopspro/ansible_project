#!/bin/bash

hosts='kworker01 kworker02'
Pre_DIR="/home/ravirc/pre-check"
Post_DIR="/home/ravirc/post-check"

echo "====== PHASE 1: Pre-check and Rebooting all hosts ======"

for host in $hosts; do

 echo " Connecting $host Copying mount point "
   ssh "$host" "mkdir -p $Pre_DIR && df -Th > $Pre_DIR/mount_point.txt"
   echo "Copied mount point in $host:$Pre_DIR/mount_point.txt"
   echo "############"
   echo "rebooting $host"
   ssh "$host" "sudo reboot" &
   
done

   wait
###### All host is rebooting waiting for 60 sec#####
   sleep 60

echo "====== PHASE 2: Post-check and Comparison ======"

for host in $hosts; do

   echo "-----Connecting $host after reboot-----"
   ssh "$host" "mkdir -p $Post_DIR && df -Th > $Post_DIR/mount_point.txt"

   ##### comparing both pre-check & post-check mount point file ############

    ssh "$host" "
       if cmp -s $Pre_DIR/mount_point.txt $Post_DIR/mount_point.txt; then
	       echo " All Filesystem looking good no need to mount "
       else
	       echo "File system is missing, Now Mounting on $host"
	       sudo mount -a
       fi
       "
done


