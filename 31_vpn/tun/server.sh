openvpn --genkey --secret /etc/openvpn/static.key
cat <<EOF > /etc/openvpn/server.conf
dev tap
ifconfig 10.10.10.1 255.255.255.0
topology subnet
secret /etc/openvpn/static.key
comp-lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
EOF
systemctl start openvpn@server
systemctl enable openvpn@server
