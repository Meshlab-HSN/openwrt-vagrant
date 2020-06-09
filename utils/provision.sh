#!/usr/bin/expect -f

# based on: https://github.com/elventear/openwrt-in-vagrant
# vim: syntax=tcl

set prompt "root@OpenWrt:/#"
set socket [lindex $argv 0]

proc shell {cmd {timeout 10}} {
    global prompt    
    send -- "$cmd\n"
    expect -timeout $timeout $prompt
}

spawn socat UNIX-CONNECT:$socket STDOUT

expect -timeout -1 "Please press"

shell ""
shell "sed -i s/eth0/eth2/g /etc/config/network"
shell "sed -i s/eth1/eth0/g /etc/config/network"  
shell "sed -i s/eth2/eth1/g /etc/config/network"
shell "uci batch <<EOF 
    set firewall.@zone\[1\].input=ACCEPT
    set firewall.@zone\[1\].forward=ACCEPT
    commit
EOF"
shell "/etc/init.d/network reload"
expect -timeout -1 "eth0: link becomes ready"
shell "echo poweroff > /sbin/shutdown"
shell "chmod a+x /sbin/shutdown"
shell "echo -e \"root\nroot\" | (passwd root)"
shell "opkg update"
shell "opkg install sudo" -1
shell "poweroff"

expect -timeout -1 eof
