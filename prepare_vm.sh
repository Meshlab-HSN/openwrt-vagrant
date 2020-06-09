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
#opkg install prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-netstat

#mkdir /data
#chmod 777 -R /data/ #bug workaround
#uci set prometheus.prometheus.web_listen_address='0.0.0.0:9090' #bug fix
#uci commit prometheus
#/etc/init.d/prometheus restart


#size limit: add to /etc/init.d/prometheus:
#procd_append_param command --storage.tsdb.retention.size=50MB 

# todo: add to /etc/promentheus.yml
#- job_name: 'node'                                                                  
#    static_configs:                                                                   
#    - targets: ['localhost:9100']

# for federation
# - job_name: 'federate'                                                              
#    scrape_interval: 15s                                                              
#
#    honor_labels: true                                                                
#    metrics_path: '/federate'                                                         
#
#    params:                                                                           
#      'match[]':                                                                      
#        - '{job="prometheus"}'                                                        
#        - '{__name__=~"job:.*"}'                                                      
#
#    static_configs:                                                                   
#      - targets:                                                                      
#        - '192.168.4.146:9090'

[ ! -d /etc/umdns ] && mkdir -p /etc/umdns
cat <<EOT > /etc/umdns/autodiscovery.json
{
"http_80": { "service": "_http._tcp.local", "port": 80, "txt": [ "daemon=uhttpd-mod-ubus"] }
}
EOT

uci add_list umdns.@umdns[-1].network="wan"
uci commit umdns
/etc/init.d/umdns reload

discoveryd=/usr/libexec/rpcd/discoveryd
if [ -f "$discoveryd" ]; then
    chmod +x $discoveryd
    /etc/init.d/rpcd reload
    cat <<EOT > /usr/share/rpcd/acl.d/discoveryd.json
{
	"discoveryd": {
		"description": "discoveryd configuration",
		"read": {
			"ubus": {
			    "discoveryd": ["*"]
			}
		}
	}
}
EOT

fi


cat <<EOT > /usr/share/rpcd/acl.d/remoteconfig.json
{
	"umdns": {
		"description": "umdns configuration",
		"read": {
			"ubus": {
			    "umdns": ["*"]
			}
		}
	}
}
EOT

cat <<EOT > /usr/share/rpcd/acl.d/uci.json
{
	"uci": {
		"description": "uci configuration",
		"read": {
			"ubus": {
			    "uci": ["*"]
			}
		},
		"write": {
			"ubus": {
				"uci": ["*"]
			}
		}
	}
}
EOT

cat <<EOT > /usr/share/rpcd/acl.d/file.json
{
	"file": {
		"description": "ubus file permissions",
		"read": {
			"ubus": {
				"file": ["*"]
			}
		},
		"write": {
			"ubus": {
				"file": ["*"]
			},
			"file": {
				"*": ["*"]
			}
		}
	}
}
EOT


simpleconfig=/usr/libexec/rpcd/simpleconfig
if [ -f "$simpleconfig" ]; then
    chmod +x $simpleconfig
    touch /etc/config/simpleconfig
    /etc/init.d/rpcd reload
cat <<EOT > /usr/share/rpcd/acl.d/simpleconfig.json
{
	"simpleconfig": {
		"description": "simpleconfig configuration",
		"read": {
			"ubus": {
				"simpleconfig": ["*"]
			}
		},
		"write": {
			"ubus": {
				"simpleconfig": ["*"]
			}
		}
	}
}
EOT

fi


uci set uhttpd.main.ubus_cors='1'
uci commit uhttpd
/etc/init.d/uhttpd reload


/etc/init.d/network restart



#if [ ! -z "$1" ]; then
#  uci set network.lan.ipaddr="$1"
#  uci commit network
#  /etc/init.d/network reload
#fi


#if [ ! -z "$1" ]; then
#  uci set network.lan.ipaddr="$1"
#  uci commit network
#  /etc/init.d/network reload
#fi

#if [ ! -z "$3" ]; then
#  uci set network.lan2='interface'
#  uci set network.lan2.proto="static"
#  uci set network.lan2.ifname='eth2'
#  uci set network.lan2.ipaddr="$3"
#  uci set network.lan2.netmask='255.255.255.0'
#  uci commit network
  
#  uci set dhcp.lan2='dhcp'
#  uci set dhcp.lan2.interface="lan2"
#  uci set dhcp.lan2.start='100'
#  uci set dhcp.lan2.limit='150'
 # uci set dhcp.lan2.leasetime='12h'
#  uci commit dhcp
  
#  /etc/init.d/network reload
#  /etc/init.d/dnsmasq restart 2>/dev/null
#  /etc/init.d/odhcpd restart

#fi

ubus call umdns reload
ubus call umdns update
