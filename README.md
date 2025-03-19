# Wireguard VPN Tunnel Setup Guide

This repository contains scripts and configuration files to set up a secure VPN tunnel between a VPS server and a Raspberry Pi client using Wireguard. This setup enables you to access your home network remotely through a secure connection.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [VPS Server Setup](#vps-server-setup)
- [Raspberry Pi Client Setup](#raspberry-pi-client-setup)
- [Testing the Connection](#testing-the-connection)
- [Additional Clients](#additional-clients)
- [Troubleshooting](#troubleshooting)

## Overview

This setup establishes a Wireguard VPN tunnel with the following features:
- Secure connection between your VPS and Raspberry Pi
- Access to your home network devices remotely
- Support for multiple clients connecting to the VPS
- Automatic key generation and configuration

## Requirements

### VPS Requirements
- Ubuntu 20.04 LTS or newer
- Docker and Docker Compose installed
- Public IP address or domain name
- Root or sudo access

### Raspberry Pi Requirements
- Raspberry Pi 3 or newer
- Raspberry Pi OS (formerly Raspbian) or Ubuntu for Raspberry Pi
- Docker and Docker Compose installed
- Internet connection
- Root or sudo access

## VPS Server Setup

1. **Clone the Repository**

    ```bash
    git clone https://github.com/yourusername/wireguard-cgnat.git
    cd wireguard-cgnat/vps
    ```

2. **Open Required Ports**

    Make sure the UDP port 51820 is open on your VPS firewall:

    ```bash
    sudo ufw allow 51820/udp
    sudo ufw status
    ```

3. **Start the Wireguard Server**

    Run the setup script to configure and start the Wireguard server:

    ```bash
    bash setup-wireguard-tunnel.sh
    ```

    This script will:
    - Enable IP forwarding
    - Start the Wireguard Docker container
    - Configure iptables for proper routing
    - Generate keys and client configurations automatically

4. **Modify Peer Configuration**

    Edit the automatically generated peer1 configuration to allow access to your home network:

    ```bash
    cd /config/wg_confs/
    nano wg0.conf
    ```

    Add or modify the following line in the server's configuration of peer1

    ```
    AllowedIPs = 10.69.69.2/32, 192.168.1.0/24
    ```

    This allows traffic to the client (10.69.69.2) and your home network (192.168.1.0/24).

5. **Copy peer1 config**

    Copy the config of peer1 to conect the raspberry pi:

    ```bash
    cat config/peer1/peer1.conf
    ```

## Raspberry Pi Client Setup

1. **Clone the Repository**

    ```bash
    git clone https://github.com/yourusername/wireguard-cgnat.git
    cd wireguard-cgnat/raspberry
    ```


2. **Configure Wireguard Client**

    Combine the existent conf with the peer1 conf (Add all keys copied from the peer1 in the vps)

    ```bash
    nano config/wg0.conf
    ```

    Combine the auto-generated peer1.conf content from the VPS with the following template:

    ```
    [Interface]
    PrivateKey = <PRIVATE_KEY>
    Address = 10.69.69.2/24
    DNS = 1.1.1.1
    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

    [Peer]
    PublicKey = <PUBLIC_KEY>
    Endpoint = <YOUR_VPS_IP_OR_DOMAIN>:51820
    PresharedKey = <KEY>
    AllowedIPs = 0.0.0.0/0
    PersistentKeepalive = 25
    ```

4. **Start the Wireguard Client**

    Run the setup script to configure and start the Wireguard client:

    ```bash
    bash setup-wireguard-client.sh
    ```

    This script will:
    - Enable IP forwarding
    - Start the Wireguard Docker container
    - Configure iptables for proper routing

## Testing the Connection

1. **Check Wireguard Status on VPS**

    ```bash
    docker exec wireguard wg show
    ```

    You should see your Raspberry Pi client connected.

2. **Check Wireguard Status on Raspberry Pi**

    ```bash
    docker exec wireguard-client wg show
    ```

    You should see the connection to your VPS server.

3. **Test Connectivity**

    From the VPS, try to ping your Raspberry Pi:

    ```bash
    ping 10.69.69.2
    ```

    From the Raspberry Pi, try to ping your VPS:

    ```bash
    ping 10.69.69.1
    ```

## Additional Clients

The VPS Wireguard configuration is set to support 4 clients by default. To connect additional devices:

1. Find the corresponding peer configuration in the VPS `config/peer2`, `config/peer3`, etc.
2. Follow the Raspberry Pi client setup steps using the specific peer configuration
3. Adjust the AllowedIPs on the server configuration for each peer as needed

## Troubleshooting

If you encounter connectivity issues:

1. **Check Firewall Settings**

    Make sure UDP port 51820 is open on your VPS:

    ```bash
    sudo ufw status
    ```

2. **Verify Interface Status**

    Check if the Wireguard interface is up on both sides:

    ```bash
    ip a show wg0
    ```

3. **Check Routing Tables**

    ```bash
    ip route
    ```

4. **Review Wireguard Logs**

    ```bash
    docker logs wireguard
    docker logs wireguard-client
    ```

5. **Restart Wireguard Services**

    ```bash
    # On VPS
    cd vps
    docker-compose down
    docker-compose up -d

    # On Raspberry Pi
    cd raspberry
    docker-compose down
    docker-compose up -d
    ```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Wireguard](https://www.wireguard.com/)
- [linuxserver/wireguard](https://github.com/linuxserver/docker-wireguard) for the Docker images

---

For more detailed information or support, please open an issue on this repository.