#!/bin/bash

set -e

# enable IP forwarding
sysctl -w net.ipv4.ip_forward=1 > /dev/null

# configure firewall
iptables -t nat -A POSTROUTING -s 10.99.99.0/24 ! -d 10.99.99.0/24 -j MASQUERADE
iptables -A FORWARD -s 10.99.99.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
iptables -A INPUT -i ppp0 -j ACCEPT
iptables -A OUTPUT -o ppp0 -j ACCEPT
iptables -A FORWARD -i ppp0 -j ACCEPT
iptables -A FORWARD -o ppp0 -j ACCEPT


# Try to auto discover server IPs
[ -z "$PUBLIC_IP" ] && PUBLIC_IP=$(wget -t 3 -T 15 -qO- http://ipv4.icanhazip.com)

# configure user
if [ -z "$VPN_USER_CREDENTIAL_LIST" ]; then
  VPN_PASSWORD="$(< /dev/urandom tr -dc 'A-HJ-NPR-Za-km-z2-9' | head -c 16)"
  VPN_USER_CREDENTIAL_LIST="[{\"login\":\"vpnuser\",\"password\":\"$VPN_PASSWORD\"}]"
fi

if [ -z "$VPN_USER_CREDENTIAL_LIST" ]; then
  echo "VPN credentials must be specified. Edit your 'env' file and re-enter them."
  exit 1
fi

# Create VPN credentials
echo "$VPN_USER_CREDENTIAL_LIST" | jq -r '.[] | .login + " pptpd " + .password + " *"' > /etc/ppp/chap-secrets

CREDENTIALS_NUMBER=`echo "$VPN_USER_CREDENTIAL_LIST" | jq 'length'`

# Print detail
cat <<EOF

================================================

PPTP VPN server is now ready for use!
Connect to your new VPN with these details:
Server IP: $PUBLIC_IP
Users credentials :
EOF

for (( i=0; i<=$CREDENTIALS_NUMBER - 1; i++ ))
do
	VPN_USER_LOGIN=`echo "$VPN_USER_CREDENTIAL_LIST" | jq -r ".["$i"] | .login"`
	VPN_USER_PASSWORD=`echo "$VPN_USER_CREDENTIAL_LIST" | jq -r ".["$i"] | .password"`
	echo "Login : ${VPN_USER_LOGIN} Password : ${VPN_USER_PASSWORD}"
done

cat <<EOF
Write these down. You'll need them to connect!

================================================
EOF

exec "$@"
