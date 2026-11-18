# Day 02: Network Configuration and Static IP Addressing on Ubuntu

**Date:** 18 November 2026  
**Category:** Linux Administration / Networking  
**Environment:** Ubuntu Desktop running on Oracle VirtualBox

## 1. Objective

The objective of this lab was to understand Linux network interfaces, VirtualBox networking modes, and how to configure a static IPv4 address on Ubuntu using Netplan.

The exercise also involved exploring Linux network management services and troubleshooting Netplan configuration warnings.

## 2. Tools and Technologies

- Ubuntu Linux
- Oracle VirtualBox
- Netplan
- NetworkManager
- systemd-networkd
- Linux terminal
- YAML configuration

## 3. Understanding Network Interfaces

I started by examining the network interfaces available on Ubuntu.

Command:

```bash
ip addr
```

I identified two interfaces:

| Interface | IP Address | Description |
|---|---|---|
| enp0s3 | 10.0.2.15/24 (initially) | Virtual Ethernet interface |
| lo | 127.0.0.1/8 | Loopback interface |

The loopback interface allows the operating system to communicate with itself.

## 4. Changing VirtualBox Network Mode

Initially, Ubuntu was configured to use NAT networking.

I changed the VirtualBox network adapter from NAT to Bridged Adapter.

This allowed Ubuntu to obtain an IP address from the physical network rather than using VirtualBox's default NAT network.

### Network configuration after bridging

| Device | IP Address |
|---|---|
| Ubuntu VM | 172.24.78.145 |
| Windows Host | 172.24.78.249 |
| Default Gateway | 172.24.78.159 |

Both Ubuntu and Windows shared the same default gateway.

### Key concept: Bridged Networking

Bridged networking allows a virtual machine to appear as an independent device on the physical network.

Unlike NAT, which translates traffic through the host machine, bridged networking allows direct communication with other devices on the LAN, subject to network and firewall restrictions.

## 5. Understanding Netplan

I explored Netplan, Ubuntu's network configuration utility.

Netplan uses YAML files stored in:

```bash
/etc/netplan/
```

I inspected the existing configuration:

```bash
ls -l /etc/netplan/
```

The original configuration specified:

```yaml
network:
  version: 2
  renderer: NetworkManager
```

This indicated that NetworkManager was configured as the network management backend.

I decided to replace the existing configuration with a new YAML configuration.

## 6. Creating a Static IP Configuration

I created a new configuration file:

```bash
sudo nano /etc/netplan/01-static-ip.yaml
```

The intended configuration was:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 172.24.78.145/24
      routes:
        - to: default
          via: 172.24.78.159
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

**Note:** The `/24` prefix was used in the proposed configuration but still requires confirmation against the actual bridged network subnet.

### Understanding the configuration

- `version: 2` — Specifies the Netplan configuration version.
- `renderer: networkd` — Specifies systemd-networkd as the backend.
- `enp0s3` — Identifies the network interface.
- `dhcp4: false` — Disables automatic IPv4 configuration through DHCP.
- `addresses` — Defines the manually assigned IP address.
- `routes` — Defines the default gateway.
- `nameservers` — Specifies DNS servers.

## 7. Network Management Services

I explored the difference between NetworkManager and systemd-networkd.

NetworkManager is commonly used for desktop network management, while systemd-networkd provides network configuration and management through systemd.

I stopped and disabled NetworkManager while attempting to transition to systemd-networkd.

This introduced additional service-related troubleshooting.

## 8. Troubleshooting Netplan

During configuration validation and application, I encountered several warnings.

### Issue 1: File permissions too open

Netplan reported:

```text
Permissions for /etc/netplan/01-static-ip.yaml
are too open.
Netplan configuration should NOT be accessible by others.
```

**Cause:**

The configuration file had permissions that allowed users other than root to access it.

**Solution:**

```bash
sudo chmod 600 /etc/netplan/01-static-ip.yaml
```

This restricts access to the file owner.

Expected permissions:

```text
-rw-------
```

### Issue 2: gateway4 deprecation

Netplan reported that `gateway4` was deprecated.

The recommended approach is to define the default gateway under the `routes` section.

Example:

```yaml
routes:
  - to: default
    via: 172.24.78.159
```

### Issue 3: Network backend service

I also encountered a systemd-networkd/DBus service-related error.

This highlighted the importance of ensuring that the selected Netplan renderer is supported by an active network management service.

Further troubleshooting was required.

## 9. Commands Practised

| Command | Purpose |
|---|---|
| `ip addr` | Display network interfaces and IP addresses |
| `ip route` | Display routing table |
| `ls /etc/netplan/` | List Netplan configuration files |
| `sudo nano` | Edit configuration files |
| `sudo chmod 600` | Restrict file permissions |
| `sudo netplan generate` | Generate backend configuration |
| `sudo netplan apply` | Apply network configuration |
| `sudo netplan try` | Test configuration with automatic rollback if not confirmed |
| `systemctl status` | Inspect service status |

## 10. Lessons Learned

1. The difference between NAT and Bridged Adapter networking in VirtualBox.
2. How virtual machines obtain IP addresses from physical networks.
3. The purpose of loopback and Ethernet network interfaces.
4. How Netplan manages network configuration on Ubuntu.
5. The distinction between NetworkManager and systemd-networkd.
6. How to configure IPv4 addresses, default routes and DNS servers.
7. Why Linux configuration files require appropriate permissions.
8. How to identify and troubleshoot Netplan warnings.

## 11. Outstanding Tasks

- Confirm the actual subnet prefix of the bridged network.
- Correct the Netplan file permissions.
- Ensure systemd-networkd is installed and running.
- Confirm that the selected renderer is functioning correctly.
- Verify that the static IP does not conflict with the DHCP allocation range.
- Confirm that the static IP persists after reboot.
- Test connectivity between Ubuntu and Windows.
- Test DNS resolution and internet connectivity.

## Conclusion

This exercise provided practical exposure to Linux network administration, virtual networking, IPv4 configuration and network management services.

Although the static IP configuration encountered some service and permission-related warnings, the troubleshooting process provided useful insight into how Ubuntu manages network interfaces through Netplan.
