# Setup and Use a Firewall on Linux

## Overview

Configured and tested basic firewall rules on Ubuntu Linux using UFW (Uncomplicated Firewall) to allow and block network traffic.

**Tool:** UFW 0.36.1 | **OS:** Ubuntu 24.04 | **Platform:** VirtualBox (NAT)

---

## Objective

Configure and test basic firewall rules to allow or block traffic.

---

## Steps Performed

### 1. Install & Enable UFW

```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

### 2. List Current Rules

```bash
sudo ufw status verbose
```

### 3. Block Port 23 (Telnet)

```bash
sudo ufw deny 23/tcp
sudo ufw status numbered
```

### 4. Test the Block Rule

```bash
nc -zv 127.0.0.1 23   # FAIL — Connection refused (port blocked)
nc -zv 127.0.0.1 22   # SUCCESS — Connection succeeded (SSH allowed)
```

### 5. Allow & Rate-Limit SSH

```bash
sudo ufw allow 22/tcp
sudo ufw limit ssh
```

### 6. Remove Test Rule & Restore State

```bash
sudo ufw status numbered
sudo ufw delete 8   # IPv6 rule for port 23
sudo ufw delete 4   # IPv4 rule for port 23
sudo ufw status numbered
```

---

## Final Firewall Rules

| Port       | Action   | Purpose            |
|------------|----------|--------------------|
| 22/tcp     | LIMIT IN | SSH (rate-limited) |
| 80/tcp     | ALLOW IN | HTTP               |
| 443/tcp    | ALLOW IN | HTTPS              |
| All others | DENY     | Default policy     |

---

## How Firewall Filters Traffic

UFW uses `iptables` under the hood and applies a **default-deny** posture:

- All inbound traffic is **blocked** unless explicitly allowed
- Rules are evaluated **top to bottom** — first match wins
- **Stateful inspection** — established connections' reply traffic is auto-allowed
- **Rate limiting** blocks brute-force attempts (6+ connections in 30 seconds triggers block)

---

## Why Block Port 23 (Telnet)?

Telnet transmits all data — including credentials — in **plaintext**, making it trivially interceptable via packet sniffing. It has been fully replaced by SSH, which encrypts all communication end-to-end. Blocking port 23 is a fundamental security hardening step on any system.

---

## Repository Structure

```
firewall-rules/
├── README.md             — This file
├── commands.sh           — All UFW commands used, in order
├── firewall_rules.txt    — Final UFW status output (saved config)
└── screenshots/          — Terminal screenshots of each step
```



