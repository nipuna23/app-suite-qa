#!/usr/bin/perl -w

use strict;
use File::Path;
use File::Copy;

my $debug = 1;

sub main {
#    my $stat=runCommand("netstat -na | egrep '8080|9090' | grep LISTEN");
    my $psOut=runCommand("ps -ef | grep Bootstrap | grep -v grep | awk '{print \$2}'");
    chomp($psOut);
    if ($psOut !~ '^\s*$') {
        my @pids = split /\n/, $psOut;
        for my $pid (@pids) {
            print "$pid\n";
            kill 9, $pid;
            print $pid;
        }
    }
    my $dirname ="/opt/vmware/";
    if (-d $dirname) {
        rmtree $dirname;
    }
    mkdir $dirname, 0755;
    chdir($dirname);
    my $file_name = "vfabric-tc-server-standard-2.9.3.RELEASE.zip";
    my $file_name2="insight-vfabric-tc-server-agent-1.9.2.SR2.zip";
    my $dirname1="$dirname/vfabric-tc-server-standard-2.9.3.RELEASE";
    my $dirname2="$dirname/insight-agent";
    my $pwd='pwd';
    #my $javaHome = $ENV{JAVA_HOME};
    $ENV{JAVA_HOME}="/s2qa/common/jdks/17/jdk1.7.0_11";
    my $dashboard="vmc-ssrc-rh28";
   runCommand('wget --no-check-certificate "https://dist.springsource.com/release/TCS/vfabric-tc-server-standard-2.9.3.RELEASE.zip"');
    runCommand("unzip $dirname/$file_name");
    runCommand('wget --no-check-certificate "https://private.maven.springsource.com/release/com/springsource/insight/dist/insight-vfabric-tc-server-agent/1.9.2.SR2/insight-vfabric-tc-server-agent-1.9.2.SR2.zip"');
    runCommand("unzip $dirname/$file_name2");
    runCommand("mv $dirname2  $dirname1/templates");
    chdir($dirname1);
    runCommand("$pwd");
    runCommand("./tcruntime-instance.sh create agent  -t insight-agent");
    runCommand("sed -ie 's/6969/6970/g' agent/conf/catalina.properties");
    runCommand("sed -ie 's/8080/9090/g' agent/conf/catalina.properties");
    runCommand("sed -ie 's/8443/9443/g' agent/conf/catalina.properties");
    runCommand("sed -ie 's/127.0.0.1/$dashboard/g' agent/insight/conf/insight.properties");
    runCommand("./tcruntime-ctl.sh agent  start");
    runCommand('wget --no-check-certificate "http://static.springsource.org/spring-webflow/resources/samples/swf-booking-faces.war"');
    runCommand('wget --no-check-certificate "http://static.springsource.org/spring-webflow/resources/samples/swf-booking-mvc.war"');
    runCommand("mv swf*  $dirname1/agent/webapps");
}

main();

sub runCommand($) {
    my ($cmd) = @_;
    print "$cmd\n" if $debug;
    my $rtn;
    open(CMD, "$cmd|");
    while (<CMD>) {
        $rtn .= $_;
    }
    close(CMD);
    return $rtn;
}
