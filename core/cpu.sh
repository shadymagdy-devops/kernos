#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos cpu
#  Deep dive into what your processor is doing
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}CPU Deep Dive${RESET}"
divider

section "Processor Info"
model=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
cores=$(nproc --all)
threads=$(grep -c 'processor' /proc/cpuinfo)
freq=$(grep 'cpu MHz' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs | cut -d. -f1)
arch=$(uname -m)

info "Model:    ${BOLD}${model}${RESET}"
info "Cores:    ${BOLD}${cores}${RESET} physical  /  ${BOLD}${threads}${RESET} logical threads"
info "Speed:    ${BOLD}${freq} MHz${RESET} (current)"
info "Arch:     ${BOLD}${arch}${RESET}"

learn "Physical cores = actual CPU units. Logical threads = with hyperthreading, each
       core can run 2 threads at once. That's why you might see 4 cores / 8 threads."

section "Current Usage"
cpu_line=$(top -bn1 | grep 'Cpu(s)')
user=$(echo $cpu_line | awk '{print $2}' | cut -d. -f1)
system=$(echo $cpu_line | awk '{print $4}' | cut -d. -f1)
idle=$(echo $cpu_line | awk '{print $8}' | cut -d. -f1)
used=$(( 100 - idle ))

echo -e "  ${BOLD}Usage  ${RESET}"; bar $used
echo ""
info "User processes:   ${BOLD}${user}%${RESET}"
info "Kernel/system:    ${BOLD}${system}%${RESET}"
info "Idle:             ${BOLD}${idle}%${RESET}"

learn "User % = your applications. System % = the kernel working (disk I/O, network, etc).
       High system % with low user % usually means disk or network is the bottleneck."

(( used >= CPU_CRIT )) && fail "CPU is critically high — something is hammering it"
(( used >= CPU_WARN && used < CPU_CRIT )) && warn "CPU usage is elevated — worth a look"
(( used < CPU_WARN )) && ok "CPU usage is comfortable"

section "Load Average"
load=$(cat /proc/loadavg)
l1=$(echo $load | cut -d' ' -f1)
l5=$(echo $load | cut -d' ' -f2)
l15=$(echo $load | cut -d' ' -f3)
procs=$(echo $load | cut -d' ' -f4)

info "1 min:   ${BOLD}${l1}${RESET}"
info "5 min:   ${BOLD}${l5}${RESET}"
info "15 min:  ${BOLD}${l15}${RESET}"
info "Running/Total processes: ${BOLD}${procs}${RESET}"

learn "Load average tells you the average queue of processes waiting for CPU time.
       If load is trending UP from 15m → 5m → 1m, pressure is building.
       If trending DOWN, whatever caused the spike is passing."

section "Top CPU Consumers"
echo ""
ps aux --sort=-%cpu | awk '
NR==1 { printf "  %-25s %-8s %-8s %s\n", "PROCESS", "PID", "CPU%", "MEM%" }
NR>1 && NR<=11 {
    name=$11
    if(length(name)>24) name=substr(name,1,24)"…"
    printf "  %-25s %-8s %-8s %s\n", name, $2, $3, $4
}'
echo ""

learn "ps aux = list all processes with resource usage. --sort=-%cpu sorts highest first.
       This is how you find what's eating your CPU without installing anything extra."
