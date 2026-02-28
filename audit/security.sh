#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"

# ─────────────────────────────────────────────
#  kernos security
#  SSH, firewall, SUID files, open ports.
#  The stuff that bites when you ignore it.
# ─────────────────────────────────────────────

ISSUES=0
PASSES=0

flag_issue() { (( ISSUES++ )); fail "$1"; }
flag_pass()  { (( PASSES++ )); ok   "$1"; }

echo -e "\n  ${BOLD}Security Audit${RESET}"
divider
echo -e "  ${DIM}Checking your machine for common security issues...${RESET}\n"

# ── SSH ────────────────────────────────────────
section "SSH Configuration"

sshd_cfg="/etc/ssh/sshd_config"
if [[ ! -f "$sshd_cfg" ]]; then
    info "SSH server not installed — skipping SSH checks"
else
    # Root login
    root_login=$(grep -i '^PermitRootLogin' "$sshd_cfg" | awk '{print $2}' | tr -d '"')
    if [[ "$root_login" == "no" || "$root_login" == "prohibit-password" ]]; then
        flag_pass "Root login over SSH is disabled"
    else
        flag_issue "Root login over SSH is ${BOLD}ENABLED${RESET} — attackers target this directly"
        learn "PermitRootLogin no in /etc/ssh/sshd_config prevents anyone from SSHing
               directly as root. Even with a strong password, it's better to SSH as a
               regular user and then sudo. Defense in depth."
    fi

    # Password auth
    pass_auth=$(grep -i '^PasswordAuthentication' "$sshd_cfg" | awk '{print $2}')
    if [[ "$pass_auth" == "no" ]]; then
        flag_pass "SSH password authentication is disabled (key-only)"
    else
        warn "SSH password authentication is ENABLED — key-only is safer"
        learn "SSH keys are nearly impossible to brute-force. Passwords can be guessed.
               Setting PasswordAuthentication no and using only SSH keys is one of
               the highest-impact security changes you can make on a Linux server."
    fi

    # Default port
    ssh_port=$(grep -i '^Port' "$sshd_cfg" | awk '{print $2}')
    if [[ -n "$ssh_port" && "$ssh_port" != "22" ]]; then
        flag_pass "SSH is on non-default port $ssh_port (reduces automated scan noise)"
    else
        info "SSH is on default port 22 (not a vulnerability, but attracts bots)"
    fi
fi

# ── Firewall ───────────────────────────────────
section "Firewall"

if command -v ufw &>/dev/null; then
    ufw_status=$(ufw status 2>/dev/null | head -1)
    if echo "$ufw_status" | grep -q "active"; then
        flag_pass "UFW firewall is active"
        ufw status numbered 2>/dev/null | grep -v '^Status' | awk '{printf "  %s\n", $0}'
    else
        flag_issue "UFW is installed but ${BOLD}INACTIVE${RESET} — your machine is unprotected"
        learn "UFW (Uncomplicated Firewall) is a frontend for iptables. An inactive firewall
               means every port your services open is accessible to anyone. Enable with:
               sudo ufw enable && sudo ufw allow ssh"
    fi
elif command -v firewall-cmd &>/dev/null; then
    fw_state=$(firewall-cmd --state 2>/dev/null)
    [[ "$fw_state" == "running" ]] && flag_pass "firewalld is running" \
                                    || flag_issue "firewalld is installed but not running"
else
    flag_issue "No firewall detected (ufw or firewalld). Consider installing one."
fi

# ── SUID Files ─────────────────────────────────
section "SUID Files"
echo ""
info "Scanning for SUID files (run as file owner, regardless of who calls them)..."
echo ""

suid_files=$(find / -not \( -path '/proc/*' -o -path '/sys/*' -o -path '/dev/*' \) \
    -perm -4000 -type f 2>/dev/null)

suid_count=$(echo "$suid_files" | grep -c '/' 2>/dev/null || echo 0)

# Known safe SUID binaries
known_safe=(passwd sudo su ping mount umount newgrp chsh chfn)

echo "$suid_files" | while read -r f; do
    base=$(basename "$f")
    is_known=0
    for safe in "${known_safe[@]}"; do
        [[ "$base" == "$safe" ]] && is_known=1 && break
    done
    if [[ "$is_known" -eq 1 ]]; then
        ok "  $f  ${DIM}(expected)${RESET}"
    else
        warn "  $f  ${YELLOW}← unfamiliar SUID binary${RESET}"
    fi
done

echo ""
learn "SUID = Set User ID. When a file has SUID set, anyone who runs it temporarily
       becomes the file's owner. For /usr/bin/passwd this is intentional — it needs
       root to change /etc/shadow. But unexpected SUID files can be used for privilege
       escalation. This is a classic attack vector."

# ── World-Writable Files ───────────────────────
section "World-Writable Files"
echo ""
info "Scanning for files anyone can write to..."
echo ""

ww_files=$(find / -not \( -path '/proc/*' -o -path '/sys/*' -o -path '/tmp/*' \
    -o -path '/dev/*' \) -perm -002 -type f 2>/dev/null | head -10)

if [[ -z "$ww_files" ]]; then
    flag_pass "No unexpected world-writable files found"
else
    echo "$ww_files" | while read -r f; do
        flag_issue "World-writable: $f"
    done
    learn "World-writable means any user on the system can modify this file.
           That's dangerous for scripts, config files, or anything run by root.
           Fix with: chmod o-w <filename>"
fi

# ── Open Ports Summary ─────────────────────────
section "Exposed Services"
echo ""
info "Services listening on all interfaces (0.0.0.0 or :::)"
echo ""
ss -tulnp | grep -E '0\.0\.0\.0|:::' | grep LISTEN | awk '
{
    proto=$1; addr=$5; proc=$7
    gsub(/users:\(\(/, "", proc); gsub(/\)\)/, "", proc)
    printf "  \033[1m%-6s\033[0m  %-25s  \033[0;36m%s\033[0m\n", proto, addr, proc
}'
echo ""
learn "Services listening on 0.0.0.0 or ::: are accessible from any network interface.
       Services on 127.0.0.1 only accept local connections — much safer for things
       like databases that shouldn't be internet-facing."

# ── Score ─────────────────────────────────────
divider
total=$(( ISSUES + PASSES ))
echo ""
if [[ "$ISSUES" -eq 0 ]]; then
    ok "${BOLD}All checks passed — looking clean${RESET}"
elif [[ "$ISSUES" -le 2 ]]; then
    warn "${BOLD}$ISSUES issue(s) found — worth fixing soon${RESET}"
else
    fail "${BOLD}$ISSUES issues found — take action on these${RESET}"
fi
echo -e "  ${DIM}$PASSES checks passed  |  $ISSUES issues flagged${RESET}\n"
