#!/bin/bash
# Enable packet forwarding in the system
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Init  WireGuard
wg-quick up wg0

# Keep container alive
exec tail -f /dev/null
