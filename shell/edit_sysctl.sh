#!/bin/bash

# edit_sysctl.sh

# BHester 2014.01.24 - v0.1
#      Change OUR_VAL to use sed rather than awk with a FS of = which broke
#      when the value had multiple = signs because only $2 was being called
#      and there could be more than just one.
# BHester 2014.01.23 - v0

# The contents this script will be used in packages at post install time
# to edit values in the sysctl.conf file.

# Add parameters to the sysctl file if they do not exist.
# Simple integer parameter values are compared and we only update the file
# if our value is larger.
# Non-integer or multiple integer values are only added if the paramter does
# not already exist. No comparisons are made in the case of the paramter
# already existing, it is just skipped.

#SYSCTL=testctl.conf
SYSCTL=/etc/sysctl.conf

# Backup the sysctl.conf file before making changes
cp -p $SYSCTL ${SYSCTL}.greenplum-db-ce.`date +%Y%m%d%H%M`

# counter to track if we edit the sysctl.conf file
# If we do, we will add a text line into the sysctl file
WRITES=0


# Paramters with values that have multiple values must not have any spaces
# in them when in this PARAMS variable or it will treat each space as
# beginning a new parameter.
# Remove spaces around the equals sign and replace spaces that are between      # values with -+- which will be substituted with a space prior to writing       # to the file.

PARAMS="xfs_mount_options=rw,noatime,inode64,allocsize=16m
kernel.shmmax=500000000
kernel.shmmni=4096
kernel.shmall=4000000000
kernel.sem=250-+-512000-+-100-+-2048
kernel.sysrq=1
kernel.core_uses_pid=1
kernel.msgmnb=65536
kernel.msgmax=65536
kernel.msgmni=2048
net.ipv4.tcp_syncookies=1
net.ipv4.ip_forward=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_max_syn_backlog=4096
net.ipv4.conf.all.arp_filter=1
net.ipv4.ip_local_port_range=1025-+-65535
net.core.netdev_max_backlog=10000
vm.overcommit_memory=2"

for P in `echo $PARAMS`; do
   PARAM=`echo $P | awk -F'=' '{print $1}'`
  OUR_VAL=`echo $P | sed "s/$PARAM=//"`
   
   # Check if the value of the param is an integer as we will handle non
   # integers differently
   if [ "$OUR_VAL" -eq "$OUR_VAL" >& /dev/null ]; then
      # Check if the paramter already exists in the file
      if [ `grep -c ^$PARAM $SYSCTL` -gt "0" ]; then
         EXISTING_VAL=`grep ^$PARAM $SYSCTL | awk -F'=' '{print $2}'`
         # Check to see if our value is larger than the existing
         if [ "$OUR_VAL" -gt "$EXISTING_VAL" ]; then
            # we are assuming larger is better
            sed -i "/^$PARAM/ s/$EXISTING_VAL/ $OUR_VAL/" $SYSCTL
            (( WRITES++ ))  
         fi 
      else
         # parameter does not already exist, so add it
         sed -i "$ a\
         $PARAM = $OUR_VAL" $SYSCTL
         (( WRITES++ ))   
      fi
   else
      # Handled parameters with other than simple integer values simply
      # check if the param already exists in the file
      if [ `grep -c ^$PARAM $SYSCTL` -eq "0" ]; then
         # non-integer param does not already exist, add it
         # Change any -+- into spaces prior to inserting the param and value
         OUR_VAL_MOD=`echo $OUR_VAL | sed 's/-+-/ /g'`
         sed -i "$ a\
         $PARAM = $OUR_VAL_MOD" $SYSCTL
         (( WRITES++ )) 
      fi
   fi

done

# If we edited the sysctl.conf file add some text to show we were here
if [ "$WRITES" -gt "0" ]; then
   # Check that we are not going to write this line twice
   if [ `grep -c ^"# Edited by greenplum-db-ce RPM" $SYSCTL` -gt "0" ]; then
      sed -i '/^# Edited by greenplum-db-ce RPM.*$/d' $SYSCTL
   fi
   sed -i "$ a\
   # Edited by greenplum-db-ce RPM on `date`" $SYSCTL
fi



