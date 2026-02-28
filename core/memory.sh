#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos memory
#  RAM, swap, buffers — and who's eating it all
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}Memory${RESET}"
divider

section "RAM Overview"

mem_total=$(grep MemTotal     /proc/meminfo | awk '{print $2}')
mem_free=$(grep  MemFree      /proc/meminfo | awk '{print $2}')
mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
mem_buff=$(grep  Buffers      /proc/meminfo | awk '{print $2}')
mem_cache=$(grep '^Cached'    /proc/meminfo | awk '{print $2}')
mem_used=$(( mem_total - mem_avail ))
mem_pct=$(( mem_used * 100 / mem_total ))

echo -e "  ${BOLD}RAM    ${RESET}"; bar $mem_pct
echo ""
info "Total:      ${BOLD}$(( mem_total  / 1024 )) MB${RESET}"
info "Used:       ${BOLD}$(( mem_used   / 1024 )) MB${RESET}"
info "Available:  ${BOLD}$(( mem_avail  / 1024 )) MB${RESET}  ← what actually matters"
info "Buffers:    ${BOLD}$(( mem_buff   / 1024 )) MB${RESET}"
info "Cache:      ${BOLD}$(( mem_cache  / 1024 )) MB${RESET}"

learn "Linux uses 'available' not 'free' as the real indicator.
       Buffers + Cache are memory Linux borrowed for speed — it gives it back
       instantly when a program needs it. So a machine with low 'free' but
       high 'available' is perfectly fine."

(( mem_pct >= RAM_CRIT )) && fail "RAM is critically low — system may start swapping heavily"
(( mem_pct >= RAM_WARN && mem_pct < RAM_CRIT )) && warn "RAM is getting full"
(( mem_pct < RAM_WARN )) && ok "RAM usage is healthy"

section "Swap"
swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
swap_free=$(grep  SwapFree  /proc/meminfo | awk '{print $2}')
swap_used=$(( swap_total - swap_free ))

if [[ "$swap_total" -eq 0 ]]; then
    info "No swap configured on this system"
    learn "Swap is disk space used as emergency RAM overflow. Without it, the kernel
           will kill processes when RAM runs out (OOM Killer). Not having swap on a
           server is a risk — the system can become unstable under memory pressure."
else
    swap_pct=$(( swap_used * 100 / swap_total ))
    echo -e "  ${BOLD}Swap   ${RESET}"; bar $swap_pct
    echo ""
    info "Total: $(( swap_total / 1024 )) MB  |  Used: $(( swap_used / 1024 )) MB"
    (( swap_pct > 20 )) && warn "Active swap usage — system has been low on RAM" \
                        || ok  "Swap is barely touched — RAM is sufficient"

    learn "A little swap usage is normal. Heavy swap usage means your system ran out
           of RAM and had to use slow disk instead. Programs slow down dramatically
           when they're running from swap."
fi

section "Top Memory Consumers"
echo ""
ps aux --sort=-%mem | awk '
NR==1 { printf "  %-25s %-8s %-8s %s\n", "PROCESS", "PID", "MEM%", "RSS(KB)" }
NR>1 && NR<=11 {
    name=$11
    if(length(name)>24) name=substr(name,1,24)"…"
    printf "  %-25s %-8s %-8s %s\n", name, $2, $4, $6
}'
echo ""

learn "RSS = Resident Set Size — the actual RAM a process is using right now.
       VSZ (virtual size) is often much larger but includes memory mapped files
       and shared libraries that aren't all in RAM at once."
