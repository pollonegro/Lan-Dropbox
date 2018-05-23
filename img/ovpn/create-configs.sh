#!/bin/sh
 
# Modify /etc/config/network
  uci set network.vpnserver='interface'
  uci set network.vpnserver.proto='none'
  uci set network.vpnserver.ifname='ovpns0'
  uci set network.vpnserver.auto='1'
uci commit network
 
# Modify /etc/config/firewall
  uci add firewall rule
  uci set firewall.@rule[-1].name='Allow-OpenVPN-Inbound'
  uci set firewall.@rule[-1].target='ACCEPT'
  uci set firewall.@rule[-1].src='*'
  uci set firewall.@rule[-1].proto='tcpudp'
  uci set firewall.@rule[-1].dest_port='1194'
 
  uci add firewall zone
  uci set firewall.@zone[-1].name='vpnserver'
  uci set firewall.@zone[-1].input='ACCEPT'
  uci set firewall.@zone[-1].forward='REJECT'
  uci set firewall.@zone[-1].output='ACCEPT'
  uci set firewall.@zone[-1].masq='1'
  uci set firewall.@zone[-1].network='vpnserver'
 
  uci add firewall forwarding
  uci set firewall.@forwarding[-1].src='vpnserver'
  uci set firewall.@forwarding[-1].dest='wan'
 
  uci add firewall forwarding
  uci set firewall.@forwarding[-1].src='vpnserver'
  uci set firewall.@forwarding[-1].dest='lan'
uci commit firewall
 
# Modify /etc/config/openvpn
  uci set openvpn.vpnserver='openvpn'
  uci set openvpn.vpnserver.enabled='1'
  uci set openvpn.vpnserver.dev_type='tun'
  uci set openvpn.vpnserver.dev='ovpns0'
  uci set openvpn.vpnserver.port='1194'
  uci set openvpn.vpnserver.proto='udp'
  uci set openvpn.vpnserver.comp_lzo='yes'
  uci set openvpn.vpnserver.keepalive='10 120'
  uci set openvpn.vpnserver.persist_key='1'
  uci set openvpn.vpnserver.persist_tun='1'
  uci set openvpn.vpnserver.ca='/etc/openvpn/ca.crt'
  uci set openvpn.vpnserver.cert='/etc/openvpn/my-server.crt'
  uci set openvpn.vpnserver.key='/etc/openvpn/my-server.key'
  uci set openvpn.vpnserver.dh='/etc/openvpn/dh2048.pem'
  uci set openvpn.vpnserver.tls_auth='/etc/openvpn/tls-auth.key 0'
  uci set openvpn.vpnserver.mode='server'
  uci set openvpn.vpnserver.tls_server='1'
  uci set openvpn.vpnserver.server='192.168.200.0 255.255.255.0'
  uci set openvpn.vpnserver.topology='subnet'
  uci set openvpn.vpnserver.route_gateway='dhcp'
  uci set openvpn.vpnserver.client_to_client='1'
 
  uci add_list openvpn.vpnserver.push='comp-lzo yes'
  uci add_list openvpn.vpnserver.push='persist-key'
  uci add_list openvpn.vpnserver.push='persist-tun'
  uci add_list openvpn.vpnserver.push='topology subnet'
  uci add_list openvpn.vpnserver.push='route-gateway dhcp'
  uci add_list openvpn.vpnserver.push='redirect-gateway def1'
  uci add_list openvpn.vpnserver.push='route 192.168.200.0 255.255.255.0'
  uci add_list openvpn.vpnserver.push='dhcp-option DNS 192.168.13.1'
uci commit openvpn