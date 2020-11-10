cd /etc/openvpn/
/usr/share/easy-rsa/3.0.8/easyrsa init-pki
echo 'ras' | /usr/share/easy-rsa/3.0.8/easyrsa build-ca nopass
echo 'ras' | /usr/share/easy-rsa/3.0.8/easyrsa gen-req server nopass
echo 'yes' | /usr/share/easy-rsa/3.0.8/easyrsa sign-req server server
/usr/share/easy-rsa/3.0.8/easyrsa gen-dh
openvpn --genkey --secret ta.key
echo 'client' | /usr/share/easy-rsa/3/easyrsa gen-req client nopass
echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req client client
cat <<EOF > /etc/openvpn/server.conf
port 1194
proto udp4
dev tun
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
server 10.10.10.0 255.255.255.0
;route 192.168.10.0 255.255.255.0
;push "route 192.168.10.0 255.255.255.0"
ifconfig-pool-persist ipp.txt
;client-to-client
client-config-dir /etc/openvpn/client
keepalive 10 120
compress lz4-v2
push "compress lz4-v2"
persist-key
persist-tun
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
EOF
systemctl start openvpn@server
systemctl enable openvpn@server
