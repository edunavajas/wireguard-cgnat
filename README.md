

chmod +x /opt/wireguard/entrypoint.sh


mkdir -p /opt/wireguard/config
cd /opt/wireguard/config
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
