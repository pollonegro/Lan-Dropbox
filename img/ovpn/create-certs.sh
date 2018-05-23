#!/bin/sh
 
printf "\n\n  # Creating Directory Structure #\n\n"
printf %b "------------------------------------------------------------\n"
 
  PKI_DIR="/etc/openvpn/ssl"
 
    [ -d ${PKI_DIR} ] && rm -rf ${PKI_DIR}
      mkdir -p ${PKI_DIR} && chmod -R 0600 ${PKI_DIR}
      cd ${PKI_DIR}
 
    touch index.txt && touch index && echo 1000 > serial
    cp /etc/ssl/openssl.cnf ${PKI_DIR}
 
printf "\n\n  # Customizing openssl.cnf #\n\n"
printf %b "------------------------------------------------------------\n\n"
 
  PKI_CNF=${PKI_DIR}/openssl.cnf
 
    sed -i '/^dir/   s:=.*:= /etc/openvpn/ssl:'                ${PKI_CNF}
    sed -i '/^new_certs_dir/   s:=.*:= /etc/openvpn/ssl:'      ${PKI_CNF}
    sed -i '/.*Name/ s:= match:= optional:'                    ${PKI_CNF}
    sed -i '/organizationName_default/    s:= .*:= WWW Ltd.:'  ${PKI_CNF}
    sed -i '/stateOrProvinceName_default/ s:= .*:= London:'    ${PKI_CNF}
    sed -i '/countryName_default/         s:= .*:= GB:'        ${PKI_CNF}
    sed -i '/default_days/   s:=.*:= 3650:'                    ${PKI_CNF}
    sed -i '/default_bits/   s:=.*:= 4096:'                    ${PKI_CNF}
 
    cat >> ${PKI_CNF} <<"EOF"
[ my-server ] 
  keyUsage = digitalSignature, keyEncipherment
  extendedKeyUsage = serverAuth
 
[ my-client ] 
  keyUsage = digitalSignature
  extendedKeyUsage = clientAuth
EOF
 
printf "\n\n  # Generating Server PSK and CA, Server, & Client Certs #\n\n"
printf %b "------------------------------------------------------------\n"
 
  printf "\n\n  ...Generating Certifcate Authority Cert & Key...\n"
  printf %b "------------------------------------------------------------\n\n"
    openssl req -batch -nodes -new -keyout "ca.key" -out "ca.crt" -x509 -config ${PKI_CNF} -days 3650
 
  printf "\n\n  ...Generating Server Cert & Key...\n"
  printf %b "------------------------------------------------------------\n\n"
    openssl req -batch -nodes -new -keyout "my-server.key" -out "my-server.csr" -subj "/CN=my-server" -config ${PKI_CNF}
 
  printf "\n\n  ...Signing Server Cert...\n\n"
    openssl ca  -batch -keyfile "ca.key" -cert "ca.crt" -in "my-server.csr" -out "my-server.crt" -config ${PKI_CNF} -extensions my-server
 
  printf "\n\n  ...Generating Client Cert & Key...\n"
  printf %b "------------------------------------------------------------\n\n"
    openssl req -batch -nodes -new -keyout "my-client.key" -out "my-client.csr" -subj "/CN=my-client" -config ${PKI_CNF}
 
  printf "\n\n  ...Signing Client Cert...\n"
  printf %b "------------------------------------------------------------\n\n"
    openssl ca  -batch -keyfile "ca.key" -cert "ca.crt" -in "my-client.csr" -out "my-client.crt" -config ${PKI_CNF} -extensions my-client     
 
  printf "\n\n  ...Generating OpenVPN TLS PSK...\n"
  printf %b "------------------------------------------------------------\n\n"
    openvpn --genkey --secret tls-auth.key
 
  printf "\n  ...Generating Diffie-Hellman Cert...\n"
  printf %b "------------------------------------------------------------\n\n"
    printf "    # May take a while to complete (~25m on WRT3200ACM) #\n\n\n"
    openssl dhparam -out dh2048.pem 2048
 
printf "\n\n  ...Correcting Permissions...\n"
printf %b "------------------------------------------------------------\n"
  chmod 0600 ca.key dh2048.pem my-server.key my-client.key tls-auth.key
 
printf "\n\n  # Copying Certs & Keys to /etc/openvpn/ #\n"
printf %b "------------------------------------------------------------\n"
  cp ca.crt my-server.* my-client.* dh2048.pem tls-auth.key /etc/openvpn
 
printf "\n\n  . . .  DONE  . . .  \n\n\n"