#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos system
#  A clean snapshot of your machine right now.
#  Think of this as your machine's vitals.
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}System Snapshot${RESET}  ${DIM}— $(date '+%a %d %b %Y  %H:%M:%S')${RESET}"
divider

# OS & Kernel
section "Who Is This Machine"
info "Hostname:   ${BOLD}$(hostname)${RESET}"
info "OS:         $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || uname -s)"
info "Kernel:     $(uname -r)"
info "Arch:       $(uname -m)"
info "Shell:      $SHELL"

learn "The kernel is the core of Linux — it sits between your hardware and your software.
       Running 'uname -r' tells you exactly which version is managing your system right now."

# Uptime & Load
section "Uptime & Load"
boot_time=$(who -b 2>/dev/null | awk '{print $3, $4}')
info "Up since:   ${BOLD}${boot_time}${RESET}  ($(uptime -p))"

load=$(cat /proc/loadavg)
load1=$(echo $load | cut -d' ' -f1)
load5=$(echo $load | cut -d' ' -f2)
load15=$(echo $load | cut -d' ' -f3)
cores=$(nproc)

info "Load avg:   ${BOLD}${load1}${RESET} (1m)  ${BOLD}${load5}${RESET} (5m)  ${BOLD}${load15}${RESET} (15m)"
info "CPU cores:  ${BOLD}${cores}${RESET}"

# A human judgement on load
high=$(echo "$load1 $cores" | awk '{printf "%d", ($1 > $2)}')
[[ "$high" == "1" ]] && warn "Load average is above your core count — system is under pressure" \
                      || ok  "Load average looks healthy"

learn "Load average = how many processes are waiting to run on your CPU.
       A load of 1.0 on a 1-core machine = 100% busy. On 4 cores, 4.0 = fully loaded.
       Above your core count for sustained periods = something is wrong."

# Quick resource overview
section "Quick Resource Overview"
cpu_pct=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}')
ram_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ram_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
ram_used=$(( ram_total - ram_avail ))
ram_pct=$(( ram_used * 100 / ram_total ))
disk_pct=$(df / | awk 'NR==2{print int($5)}')

echo -e "  ${BOLD}CPU    ${RESET}"; bar $cpu_pct
echo -e "  ${BOLD}RAM    ${RESET}"; bar $ram_pct
echo -e "  ${BOLD}Disk / ${RESET}"; bar $disk_pct

echo ""
info "RAM: $(( ram_used/1024 ))MB used of $(( ram_total/1024 ))MB"
info "Run ${BOLD}kernos cpu${RESET}, ${BOLD}kernos memory${RESET}, ${BOLD}kernos disk${RESET} for details"
echo ""
