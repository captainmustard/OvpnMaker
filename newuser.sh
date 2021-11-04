echo client name:

read name

./easyrsa gen-req $name nopass
sleep 1
./easyrsa sign-req client $name
sleep 1
mkdir clients/$name
cp pki/private/${name}.key clients/$name/
cp pki/issued/${name}.crt clients/$name/
cp clients/ca.crt clients/$name/ca.crt
echo copied client files to clients/$name/

./ovpngen.sh flexatorium.org clients/$name/ca.crt pki/issued/${name}.crt pki/private/${name}.key > $name.ovpn
