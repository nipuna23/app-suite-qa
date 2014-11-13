#!/usr/bin/perl


use warnings;
use strict;



`curl  -u admin:insight http://vmc-ssrc-rh28:8080/insight/services/config/agent-download > /tmp/insight-agent.jar`;

#`curl  -u admin:insight -o /tmp/insight-agent.jar  http://vmc-ssrc-rh28:8080/insight/services/config/agent-download`;

