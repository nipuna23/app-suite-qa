#!/usr/bin/perl


use warnings;
use strict;

#my $timestamp = localtime($^T);
my $timestamp = 20130408;
#print "$timestamp\n";


my $command="wget --no-check-certificate \"https://private.maven.springsource.com/snapshot/com/springsource/insight/dist/insight-vfabric-tc-server-agent/1.9.3-CI-SNAPSHOT/insight-vfabric-tc-server-agent-1.9.3-CI-$timestamp\.023220-19.zip\"";


#print "$command\n";
#system($command);


`curl -u admin:insight http://vmc-ssrc-rh28:8080/insight/services/config/agent-download > insight-agent.jar`;
