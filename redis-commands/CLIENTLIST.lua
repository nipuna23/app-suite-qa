#!/usr/bin/expect
send client list
send client setname "Test_Redis!"
send client getname
send client list
