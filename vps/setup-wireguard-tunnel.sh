#!/bin/bash


sudo ufw allow 51820/udp

sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo sysctl -p
sudo ip link delete wg0

docker-compose down
docker-compose up -d

sleep 10

docker exec wireguard bash -c "iptables -A FORWARD -i wg0 -j ACCEPT"
docker exec wireguard bash -c "iptables -A FORWARD -o wg0 -j ACCEPT"
docker exec wireguard bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"