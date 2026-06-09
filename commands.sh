#!/bin/bash

# ══════════════════════════════════════════════════════════
# Firewall Setup using UFW on Ubuntu Linux
# OS: Ubuntu 24.04 | Tool: UFW 0.36.1 | Platform: VirtualBox (NAT)
# ══════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
# STEP 1: Install and Enable UFW
# ─────────────────────────────────────────────

sudo apt update
sudo apt install ufw -y

# Set default policies: deny all inbound, allow all outbound
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Enable the firewall
sudo ufw enable

# ─────────────────────────────────────────────
# STEP 2: List Current Rules
# ─────────────────────────────────────────────

sudo ufw status verbose

# ─────────────────────────────────────────────
# STEP 3: Allow HTTP and HTTPS
# ─────────────────────────────────────────────

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# ─────────────────────────────────────────────
# STEP 4: Block Port 23 (Telnet)
# ─────────────────────────────────────────────

sudo ufw deny 23/tcp

# Verify rule was added
sudo ufw status numbered

# ─────────────────────────────────────────────
# STEP 5: Test the Block Rule
# ─────────────────────────────────────────────

# Install required testing tools
sudo apt install openssh-server netcat-openbsd telnet -y
sudo systemctl start ssh
sudo systemctl enable ssh

# Port 23 should FAIL (blocked by UFW rule)
nc -zv 127.0.0.1 23

# Port 22 should SUCCEED (SSH is allowed)
nc -zv 127.0.0.1 22

# ─────────────────────────────────────────────
# STEP 6: Allow and Rate-Limit SSH (Port 22)
# ─────────────────────────────────────────────

sudo ufw allow 22/tcp
# Rate limit: blocks IPs making 6+ connections in 30 seconds
sudo ufw limit ssh

# ─────────────────────────────────────────────
# STEP 7: Remove the Test Block Rule (Port 23)
# ─────────────────────────────────────────────

# Check numbered rules first to find the correct indices
sudo ufw status numbered

# Delete port 23 rules — delete HIGHER number first to avoid index shift
# NOTE: replace 8 and 4 with the actual rule numbers from your output
sudo ufw delete 8   # IPv6 rule for port 23
sudo ufw delete 4   # IPv4 rule for port 23

# Verify removal — port 23 rules should be gone
sudo ufw status numbered

# ─────────────────────────────────────────────
# STEP 8: Save Final Configuration to File
# ─────────────────────────────────────────────

sudo ufw status verbose > firewall_rules.txt
echo "[*] Final firewall rules saved to firewall_rules.txt"
cat firewall_rules.txt
