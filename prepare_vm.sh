#!/bin/sh

if [ ! -z "$1" ]; then
  uci set system.@system[0].hostname="$1"
  uci commit system
  /etc/init.d/system reload
fi


if [ ! -z "$2" ]; then
  if [ "$2" = "dhcp" ]; then
    uci set network.lan.proto="dhcp"
    uci set network.lan.ifname="eth0"
    uci set network.wan.ifname="eth1"
    uci set network.wan6.ifname="eth1"
    uci commit network
    /etc/init.d/network restart
    /etc/init.d/dnsmasq restart 2>/dev/null
    
    #uci add_list umdns.@umdns[-1].network="wan"
	#uci commit umdns
	#/etc/init.d/umdns reload
  else
    uci set network.lan.ipaddr="$2"
    uci commit network
    uci set dhcp.lan='dhcp'
    uci set dhcp.lan.interface="lan"
    uci set dhcp.lan.start='100'
    uci set dhcp.lan.limit='150'
    uci set dhcp.lan.leasetime='12h'
    uci commit dhcp
    /etc/init.d/network restart
    /etc/init.d/dnsmasq restart 2>/dev/null
  fi
fi

if [ ! -z "$3" ]; then
  uci set network.lan2='interface'
  uci set network.lan2.proto="static"
  uci set network.lan2.type="bridge"
  uci set network.lan2.ifname='eth2'
  uci set network.lan2.ipaddr="$3"
  uci set network.lan2.netmask='255.255.255.0'
  uci commit network
  
  uci set dhcp.lan2='dhcp'
  uci set dhcp.lan2.interface="lan2"
  uci set dhcp.lan2.start='100'
  uci set dhcp.lan2.limit='150'
  uci set dhcp.lan2.leasetime='12h'
  uci commit dhcp
  
  

  /etc/init.d/network restart
  /etc/init.d/dnsmasq restart 2>/dev/null
  /etc/init.d/odhcpd restart
  
  uci add_list firewall.@zone[0].network='lan2'
  uci commit firewall
  /etc/init.d/firewall reload 2>/dev/null

fi


opkg update
opkg install umdns uhttpd-mod-ubus kmod-mac80211-hwsim


[ ! -d /etc/umdns ] && mkdir -p /etc/umdns
cat <<EOT > /etc/umdns/autodiscovery.json
{
"http_80": { "service": "_http._tcp.local", "port": 80, "txt": [ "daemon=uhttpd-mod-ubus"] }
}
EOT

uci add_list umdns.@umdns[-1].network="wan"
uci commit umdns
/etc/init.d/umdns reload




uci set uhttpd.main.ubus_cors='1'
uci commit uhttpd
/etc/init.d/uhttpd reload


/etc/init.d/network restart


ubus call umdns reload
ubus call umdns update
