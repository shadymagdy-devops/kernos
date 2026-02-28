#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos score
#  Your system health score out of 100.
#  Checks CPU, RAM, disk, security basics,
#  zombie procs, and more.
# ─────────────────────────────────────────────

SCORE=100
NOTES=()

deduct() {
    local points=$1
    local reason="$2"
    SCORE=$(( SCORE - points ))
    NOTES+=("-${points}  ${reason}")
}

echo -e "\n  ${BOLD}System Health Score${RESET}"
divider
echo -e "  ${DIM}Checking your machine across 10 dimensions...${RESET}\n"

sleep 0.3

# 1. CPU
cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}')
if   (( cpu >= 90 )); then deduct 15 "CPU is critically high (${cpu}%)"
elif (( cpu >= 70 )); then deduct 7  "CPU is elevated (${cpu}%)"
else ok "CPU usage is fine (${cpu}%)"; fi

# 2. RAM
ram_total=$(grep MemTotal     /proc/meminfo | awk '{print $2}')
ram_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
ram_pct=$(( (ram_total - ram_avail) * 100 / ram_total ))
if   (( ram_pct >= 90 )); then deduct 15 "RAM critically full (${ram_pct}%)"
elif (( ram_pct >= 75 )); then deduct 7  "RAM usage high (${ram_pct}%)"
else ok "RAM usage healthy (${ram_pct}%)"; fi

# 3. Disk
disk_pct=$(df / | awk 'NR==2{print int($5)}')
if   (( disk_pct >= 90 )); then deduct 15 "Disk almost full (${disk_pct}%)"
elif (( disk_pct >= 75 )); then deduct 8  "Disk getting full (${disk_pct}%)"
else ok "Disk usage fine (${disk_pct}%)"; fi

# 4. Swap usage
swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
if [[ "$swap_total" -gt 0 ]]; then
    swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    swap_pct=$(( (swap_total - swap_free) * 100 / swap_total ))
    if (( swap_pct >= 50 )); then deduct 10 "Heavy swap usage — RAM pressure (${swap_pct}%)"
    elif (( swap_pct >= 20 )); then deduct 5 "Some swap in use (${swap_pct}%)"
    else ok "Swap barely used (${swap_pct}%)"; fi
else
    warn "No swap configured — risky under memory pressure"
    deduct 3 "No swap space configured"
fi

# 5. Zombie processes
zombies=$(ps aux | awk '$8=="Z"' | wc -l)
if   (( zombies >= 10 )); then deduct 10 "$zombies zombie processes — parent has a bug"
elif (( zombies >= 1  )); then deduct 3  "$zombies zombie process(es)"
else ok "No zombie processes"; fi

# 6. Firewall
if command -v ufw &>/dev/null; then
    ufw_on=$(ufw status 2>/dev/null | grep -c "active")
    if [[ "$ufw_on" -eq 0 ]]; then deduct 10 "Firewall is installed but inactive"
    else ok "Firewall (UFW) is active"; fi
elif command -v firewall-cmd &>/dev/null; then
    fw=$(firewall-cmd --state 2>/dev/null)
    [[ "$fw" == "running" ]] && ok "Firewall (firewalld) is running" \
                               || { deduct 10 "firewalld is not running"; }
else
    deduct 8 "No firewall detected (ufw or firewalld)"
fi

# 7. SSH root login
sshd_cfg="/etc/ssh/sshd_config"
if [[ -f "$sshd_cfg" ]]; then
    root_login=$(grep -i '^PermitRootLogin' "$sshd_cfg" | awk '{print $2}')
    if [[ "$root_login" == "no" || "$root_login" == "prohibit-password" ]]; then
        ok "SSH root login disabled"
    else
        deduct 8 "SSH root login is ENABLED"
    fi
else
    ok "SSH server not installed — no SSH risk"
fi

# 8. Load average check
l1=$(cut -d' ' -f1 /proc/loadavg)
cores=$(nproc)
high=$(echo "$l1 $cores" | awk '{printf "%d", ($1 > $2 * 1.5)}')
[[ "$high" == "1" ]] && deduct 8 "Load average (${l1}) is well above core count (${cores})" \
                      || ok "Load average looks reasonable"

# 9. Inodes
inode_pct=$(df -i / | awk 'NR==2{print int($5)}')
if   (( inode_pct >= 90 )); then deduct 10 "Inode usage critically high (${inode_pct}%)"
elif (( inode_pct >= 75 )); then deduct 5  "Inode usage elevated (${inode_pct}%)"
else ok "Inode usage fine (${inode_pct}%)"; fi

# 10. Failed logins
fail_count=0
[[ -f /var/log/auth.log ]] && fail_count=$(grep -c 'Failed password' /var/log/auth.log 2>/dev/null || echo 0)
if   (( fail_count >= 500 )); then deduct 5 "Over 500 failed SSH attempts — being scanned"
elif (( fail_count >= 100 )); then deduct 2 "$fail_count failed login attempts logged"
else ok "Failed login count is low ($fail_count)"; fi

# ── Score Display ──────────────────────────────
[[ $SCORE -lt 0 ]] && SCORE=0

echo ""
divider
echo ""

# Color the score
score_color=$GREEN
score_label="Excellent"
(( SCORE <= 85 && SCORE > 70 )) && { score_color=$YELLOW; score_label="Good but has issues"; }
(( SCORE <= 70 && SCORE > 50 )) && { score_color=$YELLOW; score_label="Needs attention"; }
(( SCORE <= 50 ))                && { score_color=$RED;    score_label="Poor — take action"; }

echo -e "  ${BOLD}Health Score:${RESET}  ${score_color}${BOLD}${SCORE} / 100${RESET}  ${DIM}— ${score_label}${RESET}"
echo ""

# Bar for the score
bar $SCORE
echo ""

# Show deductions
if [[ ${#NOTES[@]} -gt 0 ]]; then
    echo -e "  ${BOLD}What brought it down:${RESET}"
    for note in "${NOTES[@]}"; do
        echo -e "  ${RED}${note}${RESET}"
    done
    echo ""
    info "Run ${BOLD}kernos security${RESET} or the specific module to investigate further"
else
    echo -e "  ${GREEN}${BOLD}Perfect score — your system is in great shape.${RESET}"
fi
echo ""

learn "This score is a quick health check, not a comprehensive audit. Think of it
       like checking your vitals — useful for a quick overview, but not a replacement
       for understanding each area deeply. Use the other Kernos modules to dig in."
