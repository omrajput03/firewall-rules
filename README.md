# Task 4 — Setup and Use a Firewall on Linux

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

---

## Interview Q&A

**1. What is a firewall?**  
A firewall is a network security system that monitors and controls incoming and outgoing traffic based on predefined rules. It acts as a barrier between trusted internal networks and untrusted external ones.

**2. Difference between stateful and stateless firewall?**  
A *stateful* firewall tracks the state of active connections and can make decisions based on context (e.g., allowing reply traffic for an established session). A *stateless* firewall evaluates each packet independently against fixed rules, with no memory of past packets.

**3. What are inbound and outbound rules?**  
*Inbound rules* control traffic coming into the system. *Outbound rules* control traffic leaving the system. UFW's default is deny-inbound / allow-outbound.

**4. How does UFW simplify firewall management?**  
UFW provides a user-friendly command-line interface on top of `iptables`, which has complex syntax. UFW abstracts low-level iptables commands into simple directives like `ufw allow 22/tcp`.

**5. Why block port 23 (Telnet)?**  
Telnet sends all data including passwords in cleartext. It is a legacy protocol with no encryption, making it a serious security risk. SSH (port 22) is its secure replacement.

**6. What are common firewall mistakes?**  
- Setting default-allow instead of default-deny  
- Leaving unused ports open  
- Not logging dropped packets  
- Forgetting IPv6 rules alongside IPv4  
- Over-permissive outbound rules  

**7. How does a firewall improve network security?**  
It reduces the attack surface by blocking unauthorized access, prevents port scanning results from being useful, limits blast radius of compromises, and can rate-limit brute-force attempts.

**8. What is NAT in firewalls?**  
NAT (Network Address Translation) maps private internal IP addresses to a public IP. Firewalls often perform NAT to allow multiple internal hosts to share one public IP, while also hiding internal network topology from the outside.

---

*ElevateLabs Cyber Security Internship — Task 4*
