#!/bin/bash
echo $$
USERNAME=root
HOSTS="vmc-ssrc-rh29"
ssh -l ${USERNAME} ${HOSTS} '
	pid=`pgrep redis-server`
	echo "pid=$pid"
	if [[ -z   "$pid" ]]; then
		/common/AppFabricPackaging/nipuna/redis_install
        else
		echo "!!!!!!!Redis process is running"
        fi

# create a second instance for replication
        /opt/pivotal/pivotal-redis/util/redis-instance.sh -p 9011

#Edit the conf file for replication
	#sed -i "s/# slaveof <masterip> <masterport>/slaveof vmc-ssrc-rh28 6379/" /etc/opt/pivotal/pivotal-redis/redis-9011.conf 
	sed -i "s/# slaveof <masterip> <masterport>/slaveof vmc-ssrc-rh28 6379\n# slaveof <masterip> <masterport>/" /etc/opt/pivotal/pivotal-redis/redis-9011.conf

# Start redis 9011 server
        service pivotal-redis-9011 start
        service pivotal-redis-9011 status

# Login as p-redis and test command line

su -l p-redis  << EOF
whoami
cd /opt/pivotal/pivotal-redis/bin
./redis-cli

PING
set mykey "Test Replication"
get mykey
exit
EOF

su -l p-redis  << EOF
whoami
cd /opt/pivotal/pivotal-redis/bin
./redis-cli -p 9011

PING
set mykey "Test Replication"
get mykey
exit
EOF
'
