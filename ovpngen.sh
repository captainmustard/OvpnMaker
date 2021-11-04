#!/bin/bash

usage() {
  echo "Usage: $0 SERVER CA_CERT CLIENT_CERT CLIENT_KEY PORT PROTO"
  echo
  cat << EOF
  The first 4 tokens are required while the last are optional
  SERVER = Fully qualified domain name
  CA_CERT = Full path to the CA cert
  CLIENT_CERT = Full path to the client cert
  CLIENT_KEY = Full path to the client private key
  PORT = Port number (defaults to 1194 if left blank)
  PROTO = Protocol (defaults to udp if left blank)
EOF
  echo
  echo 'For example:'
  echo
  echo 'CLIENT=jason'
  echo "$0 my.openvpn-server.com \\"
  echo '   /etc/openvpn/server/ca.crt \'
  echo '   /etc/easy-rsa/pki/signed/$CLIENT.crt \'
  echo '   /etc/easy-rsa/pki/private/$CLIENT.key > $CLIENT.ovpn'
  exit 0
}

[[ -z "$1" ]] && usage

server=${1?"The server address is required"}
cacert=${2?"The path to the ca certificate file is required"}
client_cert=${3?"The path to the client certificate file is required"}
client_key=${4?"The path to the client private key file is required"}

# test for readable files
for i in "$cacert" "$client_cert" "$client_key"; do
  [[ -f "$i" ]] || {
  echo " I cannot find $i on the filesystem."
  echo " This could be due to permissions or that you did not define the full path correctly."
  echo " Check the path and try again."
  exit 1
}
[[ -r "$i" ]] || {
echo " I cannot read $i. Try invoking $0 as root."
exit 1
}
done
[[ -z "$6" ]] && port=1194 || port="$6"
[[ -z "$7" ]] && proto='udp' || proto="$7"

cat << EOF
client
dev tun
remote ${server} ${port} ${proto}
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
###
### optionally uncomment and change both the cipher and auth lines to EXACTLY
### match the values specified in ${server}
#cipher AES-256-CBC
#auth SHA512
###
### scroll down and optionally change the <tls-auth> tag set to <tls-crypt>
### to match how the server is configured since these options are mutually
### exclusive!
###
remote-cert-tls server
key-direction 1
<ca>
EOF
cat "${cacert}"
cat << EOF
</ca>
<cert>
EOF
cat "${client_cert}"
cat << EOF
</cert>
<key>
EOF
cat "${client_key}"
cat << EOF
</key>
EOF
