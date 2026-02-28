#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos monitor
#  Live terminal dashboard — refreshes every 2s
#  Press Q or Ctrl+C to exit
# ─────────────────────────────────────────────

cleanup() {
    tput cnorm   # restore cursor
    tput rmcup   # restore terminal screen
    echo -e "\n  ${DIM}Monitor closed.${RESET}\n"
    exit 0
}
trap cleanup INT TERM

tput smcup   # save terminal screen
tput civis   # hide cursor

draw() {
    tput cup 0 0

    # Header
    echo -e "${CYAN}${BOLD}"
    echo "  ██╗  ██╗███████╗██████╗ ███╗   ██╗ ██████╗ ███████╗"
    echo "  ██║ ██╔╝██╔════╝██╔══██╗████╗  ██║██╔═══██╗██╔════╝"
    echo "  █████╔╝ █████╗  ██████╔╝██╔██╗ ██║██║   ██║███████╗"
    echo "  ██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╗██║██║   ██║╚════██║"
    echo "  ██║  ██╗███████╗██║  ██║██║ ╚████║╚██████╔╝███████║"
    echo "  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝"
    echo -e "${RESET}"

    host=$(hostname)
    kern=$(uname -r)
    now=$(date '+%Y-%m-%d  %H:%M:%S')
    uptm=$(uptime -p)
    echo -e "  ${DIM}${host}${RESET}  │  ${DIM}${kern}${RESET}  │  ${DIM}${now}${RESET}  │  ${DIM}${uptm}${RESET}"
    echo -e "  ${DIM}Press Q or Ctrl+C to exit${RESET}"
    echo ""

    # CPU
    cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}')
    printf "  ${BOLD}%-8s${RESET}" "CPU"
    bar_inline $cpu 36
    echo ""

    # RAM
    ram_total=$(grep MemTotal     /proc/meminfo | awk '{print $2}')
    ram_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    ram_used=$(( ram_total - ram_avail ))
    ram_pct=$(( ram_used * 100 / ram_total ))
    printf "  ${BOLD}%-8s${RESET}" "RAM"
    bar_inline $ram_pct 36
    printf "   ${DIM}%sMB / %sMB${RESET}\n" "$(( ram_used/1024 ))" "$(( ram_total/1024 ))"

    # Swap
    swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    if [[ "$swap_total" -gt 0 ]]; then
        swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
        swap_pct=$(( (swap_total - swap_free) * 100 / swap_total ))
        printf "  ${BOLD}%-8s${RESET}" "SWAP"
        bar_inline $swap_pct 36
        echo ""
    fi

    # Disk
    disk_pct=$(df / | awk 'NR==2{print int($5)}')
    printf "  ${BOLD}%-8s${RESET}" "DISK /"
    bar_inline $disk_pct 36
    echo ""

    # Load
    load=$(cat /proc/loadavg)
    l1=$(echo $load | cut -d' ' -f1)
    l5=$(echo $load | cut -d' ' -f2)
    l15=$(echo $load | cut -d' ' -f3)
    cores=$(nproc)
    echo ""
    echo -e "  ${BOLD}Load Average${RESET}   ${l1} (1m)  ${l5} (5m)  ${l15} (15m)   ${DIM}${cores} cores${RESET}"

    # Network
    echo ""
    echo -e "  ${CYAN}${BOLD}── Network ─────────────────────────────────────${RESET}"
    conns=$(ss -tn 2>/dev/null | grep -c ESTAB || echo 0)
    echo -e "  Active connections: ${BOLD}${conns}${RESET}"
    ip -br addr show | grep UP | awk '{printf "  %-12s  %s\n", $1, $3}' | head -4

    # Top Processes
    echo ""
    echo -e "  ${CYAN}${BOLD}── Top Processes ───────────────────────────────${RESET}"
    printf "  ${BOLD}%-24s %-8s %-8s${RESET}\n" "COMMAND" "CPU%" "MEM%"
    ps aux --sort=-%cpu | awk '
    NR>1 && NR<=9 {
        name=$11; if(length(name)>23) name=substr(name,1,23)"…"
        color=""
        if ($3+0>40) color="\033[0;31m"
        else if ($3+0>15) color="\033[1;33m"
        printf "  " color "%-24s %-8s %-8s\033[0m\n", name, $3, $4
    }'

    echo ""
    echo -e "  ${DIM}Refreshes every 2 seconds${RESET}"
}

# Inline bar (no newline, for dashboard)
bar_inline() {
    local pct=$1 width=${2:-30}
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local color=$GREEN
    (( pct >= 80 )) && color=$RED
    (( pct >= 60 && pct < 80 )) && color=$YELLOW
    printf "${color}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty;  i++)); do printf "░"; done
    printf "] ${BOLD}%3d%%${RESET}" "$pct"
}
export -f bar_inline

# Clear screen once
clear

# Main loop
while true; do
    draw

    # Non-blocking key check — press Q to quit
    read -t 2 -n 1 key 2>/dev/null
    [[ "$key" == "q" || "$key" == "Q" ]] && cleanup
done
