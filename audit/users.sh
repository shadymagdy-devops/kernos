#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"

# ─────────────────────────────────────────────
#  kernos users
#  Who's on this machine and what have they done
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}Users${RESET}"
divider

section "Currently Logged In"
echo ""
who | awk '{
    printf "  \033[1m%-15s\033[0m  tty: %-12s  since: %s %s\n", $1, $2, $3, $4
}'
logged_in=$(who | wc -l)
[[ "$logged_in" -eq 0 ]] && info "Nobody currently logged in (besides you)"
echo ""

learn "who = shows everyone currently logged into this machine with their terminal (tty)
       and login time. w gives more detail including what they're running right now."

section "What They're Doing Right Now"
echo ""
w | awk '
NR==1 { print "  " $0 }
NR==2 { printf "  \033[1m%-12s %-8s %-12s %-10s %-10s %s\033[0m\n", "USER", "TTY", "FROM", "LOGIN", "IDLE", "COMMAND" }
NR>2  { printf "  %-12s %-8s %-12s %-10s %-10s %s\n", $1,$2,$3,$4,$5,$8 }'
echo ""

section "Login History (Last 15)"
echo ""
last -n 15 | head -17 | awk '
NF>1 {
    color=""
    if ($1 == "reboot") color="\033[0;36m"
    printf "  " color "%-12s %-10s %-18s %s %s\033[0m\n", $1, $2, $3, $4, $5
}'
echo ""

learn "last reads from /var/log/wtmp — a binary log of every login and logout.
       It shows you the full history of who has accessed this machine and when.
       'reboot' entries show when the system was restarted."

section "Failed Login Attempts"
echo ""
failed=$(journalctl _SYSTEMD_UNIT=sshd.service 2>/dev/null | grep 'Failed password' | tail -10)
if [[ -z "$failed" ]]; then
    failed=$(grep 'Failed password' /var/log/auth.log 2>/dev/null | tail -10)
fi

if [[ -z "$failed" ]]; then
    ok "No failed login attempts found (or log not accessible)"
else
    fail "Recent failed login attempts:"
    echo "$failed" | awk '{
        for(i=1;i<=NF;i++) if($i=="from") ip=$(i+1)
        printf "  → %-18s %s %s %s\n", ip, $1, $2, $3
    }'
fi
echo ""

learn "Failed SSH login attempts are normal — the internet is full of bots trying
       common passwords. What matters is the volume and whether any succeeded.
       If you see thousands from one IP, consider blocking it with: ufw deny from <IP>"

section "Users With sudo Access"
echo ""
getent group sudo 2>/dev/null | cut -d: -f4 | tr ',' '\n' | while read u; do
    [[ -n "$u" ]] && warn "sudo member: ${BOLD}$u${RESET}"
done
getent group wheel 2>/dev/null | cut -d: -f4 | tr ',' '\n' | while read u; do
    [[ -n "$u" ]] && warn "wheel member: ${BOLD}$u${RESET}"
done
echo ""

learn "sudo lets a regular user run commands as root. Anyone in the 'sudo' or 'wheel'
       group can escalate to root. This list should be short and intentional.
       If someone unexpected is here — that's a serious security issue."

section "All Human Users (UID ≥ 1000)"
echo ""
awk -F: '$3>=1000 && $3!=65534 {
    printf "  \033[1m%-15s\033[0m  UID:%-6s  Home: %s\n", $1, $3, $6
}' /etc/passwd
echo ""
