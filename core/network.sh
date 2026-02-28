#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos network
#  Interfaces, ports, connections — what's
#  going in and out of your machine
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}Network${RESET}"
divider

section "Interfaces"
echo ""
ip -br addr show | awk '
{
    state=$2
    color="\033[0;32m"
    if (state=="DOWN") color="\033[0;31m"
    if (state=="UNKNOWN") color="\033[1;33m"
    printf "  " color "%-12s  %-10s  %s\033[0m\n", $1, $2, $3
}'
echo ""

learn "ip -br addr = brief view of all network interfaces and their IP addresses.
       lo = loopback (127.0.0.1) — your machine talking to itself, always there.
       eth0/ens/enp = wired. wlan = wireless. UP means active and connected."

section "Open Ports — What's Listening"
echo ""
ss -tulnp | grep LISTEN | awk '
{
    proto=$1; local=$5; proc=$7
    gsub(/users:\(\(/, "", proc); gsub(/\)\)/, "", proc)
    printf "  \033[1m%-6s\033[0m  %-25s  \033[0;36m%s\033[0m\n", proto, local, proc
}' | sort
echo ""

learn "ss = socket statistics (modern replacement for netstat). -tulnp means:
       t=TCP  u=UDP  l=listening  n=numeric (don't resolve names)  p=show process.
       Every port here is a door into your machine. Know what's knocking."

section "Active Connections"
echo ""
conn_count=$(ss -tn | grep -c ESTAB 2>/dev/null || echo 0)
info "Established connections: ${BOLD}${conn_count}${RESET}"
echo ""
ss -tnp | grep ESTAB | awk '
{
    printf "  %-25s  →  %-25s  %s\n", $4, $5, $7
}' | head -15
echo ""

learn "ESTABLISHED = a live, active connection. These are real conversations happening
       right now between your machine and something else. Unfamiliar remote addresses
       here are worth investigating."

section "Routing Table"
echo ""
ip route show | awk '{printf "  %s\n", $0}'
echo ""

learn "The routing table is how your machine decides where to send network packets.
       'default via x.x.x.x' = your gateway — the door to the internet.
       Other routes are for local subnets your machine knows about directly."

section "DNS"
echo ""
info "Nameservers in use:"
grep '^nameserver' /etc/resolv.conf 2>/dev/null | awk '{printf "  → %s\n", $2}'
echo ""

learn "DNS = Domain Name System. It translates hostnames to IPs. Your nameserver
       is who your machine asks when you type 'google.com'. If DNS is misconfigured,
       hostnames stop resolving and it looks like 'the internet is broken'."

section "Bandwidth (Cumulative Since Boot)"
echo ""
awk 'NR>2 {
    if ($1 == "lo:") next
    name=$1; gsub(/:/, "", name)
    rx=int($2/1024/1024)
    tx=int($10/1024/1024)
    printf "  %-12s  RX: \033[0;32m%6d MB\033[0m   TX: \033[0;36m%6d MB\033[0m\n", name, rx, tx
}' /proc/net/dev
echo ""
