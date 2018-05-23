#!/bin/sh
 
source /lib/functions/network.sh
network_find_wan wanIf
network_get_ipaddrs wanIP $wanIf
# wanIP="dynamic.dns.name"
 
OVPN_FILE="/etc/openvpn/my-server.ovpn"
 
cat >> ${OVPN_FILE} <<EOF
  client
  dev tun
  proto udp
  fast-io
  remote $wanIP 1194
  remote-cert-tls server
  nobind
  persist-key
  persist-tun
  comp-lzo no
  verb 3
  key-direction 1
EOF
 
echo '<ca>'    >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < /etc/openvpn/ca.crt        
echo '</ca>'   >> ${OVPN_FILE}
 
echo '<cert>'  >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < /etc/openvpn/my-client.crt 
echo '</cert>' >> ${OVPN_FILE}
 
echo '<key>'   >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < /etc/openvpn/my-client.key 
echo '</key>'  >> ${OVPN_FILE}
 
echo '<tls-auth>'   >> ${OVPN_FILE}
cat            >> ${OVPN_FILE} < /etc/openvpn/tls-auth.key 
echo '</tls-auth>'  >> ${OVPN_FILE}
 
# Display the generated OVPN_FILE
  printf "----- Generated .ovpn file ------\n\n"
  cat ${OVPN_FILE}
 
printf "\n\n\n  . . .  DONE  . . .  \n\n\n"