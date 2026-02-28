#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  LEVEL 3 — Processes & System Control
#  Commands: ps, top, kill, systemctl, df, free, uname
#  XP available: 175
# ─────────────────────────────────────────────

KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$KERNOS_DIR/config/ui.sh"
source "$KERNOS_DIR/config/progress.sh"
source "$KERNOS_DIR/config/challenge.sh"

level_menu() {
    clear
    banner
    echo -e "  ${CYAN}${BOLD}LEVEL 3 — Processes & System Control${RESET}"
    echo -e "  ${DIM}Understand what's running, control it, and read system health.${RESET}"
    echo ""
    show_xp_bar
    divider
    echo ""

    local challenges=(
        "3.1" "What's running?       (ps, pgrep)"              "c3_ps"
        "3.2" "Live system view      (top, htop)"              "c3_top"
        "3.3" "Kill & signals        (kill, pkill)"            "c3_kill"
        "3.4" "System services       (systemctl)"              "c3_systemctl"
        "3.5" "System info           (uname, uptime, df, free)""c3_sysinfo"
        "3.6" "BOSS — Server triage  (full system read)"       "c3_boss"
    )

    for ((i=0; i<${#challenges[@]}; i+=3)); do
        local id="${challenges[$i]}"
        local title="${challenges[$((i+1))]}"
        local fn="${challenges[$((i+2))]}"
        if is_complete "level3_${fn}"; then
            echo -e "  ${GREEN}✔${RESET}  ${BOLD}${id}${RESET}  $title  ${DIM}[done]${RESET}"
        else
            echo -e "  ${DIM}○${RESET}  ${BOLD}${id}${RESET}  $title"
        fi
    done

    echo ""
    divider
    echo ""
    echo -e "  ${DIM}Pick a challenge (1-6), or press Enter to go back: ${RESET}"
    read -r choice

    case "$choice" in
        1|3.1) c3_ps        ;;
        2|3.2) c3_top       ;;
        3|3.3) c3_kill      ;;
        4|3.4) c3_systemctl ;;
        5|3.5) c3_sysinfo   ;;
        6|3.6) c3_boss      ;;
        "")    return        ;;
        *)     level_menu    ;;
    esac
}

c3_ps() {
    clear
    echo -e "\n  ${BOLD}Challenge 3.1 — What's Running${RESET}\n"

    teach "ps / pgrep" \
        "ps shows running processes. It's a snapshot — not live.\nEvery program on your machine is a process with a unique PID.\npgrep finds processes by name." \
        "ps aux | grep nginx" \
        "USER       PID %CPU %MEM    VSZ   RSS  STAT  COMMAND
root      1234  0.0  0.1  12345  8192  Ss   nginx: master"

    echo -e "  ${BOLD}Key flags:${RESET}"
    echo -e "  ${CYAN}ps aux${RESET}           — all processes, all users, extended info"
    echo -e "  ${CYAN}ps aux --sort=-%cpu${RESET} — sort by CPU usage (highest first)"
    echo -e "  ${CYAN}ps aux --sort=-%mem${RESET} — sort by memory usage"
    echo -e "  ${CYAN}pgrep sshd${RESET}       — find PID of sshd"
    echo -e "  ${CYAN}pgrep -la sshd${RESET}   — find PID + command name"
    echo -e "  ${CYAN}ps -p 1234 -o pid,comm,pcpu${RESET} — info about specific PID"
    echo ""
    echo -e "  ${BOLD}State codes:${RESET}"
    echo -e "  ${CYAN}R${RESET}=running  ${CYAN}S${RESET}=sleeping  ${CYAN}D${RESET}=disk wait  ${CYAN}Z${RESET}=zombie  ${CYAN}T${RESET}=stopped"
    echo ""

    challenge_prompt "Explore your processes" \
        "Run these commands:\n\n  1. ps aux | wc -l\n     (how many processes are running?)\n\n  2. ps aux --sort=-%cpu | head -5\n     (top 5 CPU consumers)\n\n  3. pgrep -la sshd\n     (is sshd running? what's its PID?)\n\n  4. ps aux | grep -v grep | grep \\$USER | wc -l\n     (how many processes do YOU own?)" \
        "Every terminal session, background job, and app is a process."

    echo -ne "  ${DIM}How many total processes are running on this machine? ${RESET}"
    read -r answer

    if [[ "$answer" =~ ^[0-9]+$ && "$answer" -gt 5 ]]; then
        is_complete "level3_c3_ps" && { already_done; level_menu; return; }
        mark_complete "level3_c3_ps"
        challenge_pass 25 "You can see every process on the machine!"
        echo -e "  ${DIM}ps aux is the starting point for any system investigation.\n  When something is slow or broken, this is your first stop.${RESET}"
    else
        challenge_fail "Run: ps aux | wc -l — the answer should be well above 5."
    fi

    pause
    level_menu
}

c3_top() {
    clear
    echo -e "\n  ${BOLD}Challenge 3.2 — Live System View${RESET}\n"

    teach "top" \
        "top shows a live, refreshing view of your system.\nIt shows CPU, memory, and processes updated every 3 seconds.\nPress q to quit, M to sort by memory, P to sort by CPU." \
        "top" \
        "(live view — press q to exit)"

    echo -e "  ${BOLD}Inside top — key shortcuts:${RESET}"
    echo -e "  ${CYAN}q${RESET}     — quit"
    echo -e "  ${CYAN}M${RESET}     — sort by Memory"
    echo -e "  ${CYAN}P${RESET}     — sort by CPU (default)"
    echo -e "  ${CYAN}k${RESET}     — kill a process (enter PID)"
    echo -e "  ${CYAN}1${RESET}     — show individual CPU cores"
    echo -e "  ${CYAN}h${RESET}     — help"
    echo ""
    echo -e "  ${BOLD}Reading the top header:${RESET}"
    echo -e "  ${DIM}top - 16:24:31 up 3 days — uptime${RESET}"
    echo -e "  ${DIM}Tasks: 187 total, 3 running — process count${RESET}"
    echo -e "  ${DIM}%Cpu(s): 12.5 us, 2.1 sy — user vs system CPU${RESET}"
    echo -e "  ${DIM}MiB Mem: 8192 total, 3277 free — RAM${RESET}"
    echo ""

    challenge_prompt "Use top for 60 seconds" \
        "Run: top\n\n  While inside, do these things:\n  1. Press M — now it's sorted by memory\n  2. Press P — back to CPU sort\n  3. Press 1 — see each CPU core separately\n  4. Press q — exit\n\n  Then run: top -bn1 | head -20\n  (non-interactive snapshot — useful for scripts)" \
        "top -bn1 means: batch mode, 1 iteration — perfect for scripting"

    echo -ne "  ${DIM}What command exits top? ${RESET}"
    read -r answer

    if [[ "$answer" == "q" || "$answer" == "Q" ]]; then
        is_complete "level3_c3_top" && { already_done; level_menu; return; }
        mark_complete "level3_c3_top"
        challenge_pass 20 "You can watch your system live!"
        echo -e "  ${DIM}htop is a nicer version of top — sudo apt install htop\n  But top is always available on every Linux machine. Know it.${RESET}"
    else
        challenge_fail "Press 'q' to quit top. That's the answer."
    fi

    pause
    level_menu
}

c3_kill() {
    clear
    echo -e "\n  ${BOLD}Challenge 3.3 — Kill & Signals${RESET}\n"

    teach "kill / pkill" \
        "kill sends a signal to a process. The most common signals:\nSIGTERM (15) = please stop cleanly. SIGKILL (9) = stop NOW.\nAlways try SIGTERM first — SIGKILL skips cleanup." \
        "kill -15 1234   # or: kill 1234
pkill nginx      # kill by name" \
        ""

    echo -e "  ${BOLD}Signals:${RESET}"
    echo -e "  ${CYAN}kill -15 PID${RESET}   — SIGTERM: graceful stop (default)"
    echo -e "  ${CYAN}kill -9  PID${RESET}   — SIGKILL: force kill (no cleanup)"
    echo -e "  ${CYAN}kill -1  PID${RESET}   — SIGHUP: reload config (for daemons)"
    echo -e "  ${CYAN}kill -l${RESET}        — list all signals"
    echo -e "  ${CYAN}pkill nginx${RESET}    — kill by process name"
    echo -e "  ${CYAN}killall nginx${RESET}  — kill all processes named nginx"
    echo ""

    challenge_prompt "Start and kill a process" \
        "Run these in your terminal:\n\n  1. sleep 999 &\n     (start a background process — & puts it in background)\n\n  2. ps aux | grep sleep\n     (find its PID)\n\n  3. pgrep sleep\n     (simpler way to get the PID)\n\n  4. kill \$(pgrep sleep)\n     (kill it — \$() runs a command and uses its output)\n\n  5. pgrep sleep\n     (verify it's gone — should return nothing)" \
        "\$(pgrep sleep) is command substitution — a powerful Bash pattern"

    echo -ne "  ${DIM}Is the sleep process still running? (yes/no): ${RESET}"
    read -r answer

    if echo "$answer" | grep -qi 'no'; then
        is_complete "level3_c3_kill" && { already_done; level_menu; return; }
        mark_complete "level3_c3_kill"
        challenge_pass 30 "You can start and stop any process!"
        echo -e "  ${DIM}kill \$(pgrep name) is a one-liner pattern you'll use constantly.\n  SIGKILL (9) is the nuclear option — only when SIGTERM fails.${RESET}"
    else
        challenge_fail "Make sure you killed it: kill \$(pgrep sleep). Then check: pgrep sleep (nothing should print)"
    fi

    pause
    level_menu
}

c3_systemctl() {
    clear
    echo -e "\n  ${BOLD}Challenge 3.4 — System Services${RESET}\n"

    teach "systemctl" \
        "systemd manages all services (daemons) on modern Linux.\nsystemctl is how you control them.\nServices are programs that run in the background automatically." \
        "sudo systemctl status nginx" \
        "● nginx.service - A high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled)
   Active: active (running) since Mon 2024-01-15 08:30:00 UTC"

    echo -e "  ${BOLD}Essential systemctl commands:${RESET}"
    echo -e "  ${CYAN}systemctl status nginx${RESET}    — is it running? any errors?"
    echo -e "  ${CYAN}sudo systemctl start nginx${RESET}  — start a service"
    echo -e "  ${CYAN}sudo systemctl stop nginx${RESET}   — stop a service"
    echo -e "  ${CYAN}sudo systemctl restart nginx${RESET}— stop then start"
    echo -e "  ${CYAN}sudo systemctl reload nginx${RESET} — reload config (no downtime)"
    echo -e "  ${CYAN}sudo systemctl enable nginx${RESET} — start automatically on boot"
    echo -e "  ${CYAN}sudo systemctl disable nginx${RESET}— don't start on boot"
    echo -e "  ${CYAN}systemctl list-units --type=service${RESET} — all services"
    echo ""

    challenge_prompt "Inspect your system services" \
        "Run these commands:\n\n  1. systemctl list-units --type=service --state=running | head -15\n     (what services are running?)\n\n  2. systemctl status sshd 2>/dev/null || systemctl status ssh\n     (is SSH running?)\n\n  3. systemctl is-enabled cron 2>/dev/null || systemctl is-enabled crond\n     (is cron enabled to start at boot?)\n\n  4. systemctl --failed\n     (any failed services?)" \
        "Every running service = a potential attack surface. Know what's running."

    echo -ne "  ${DIM}Is the SSH service active on this machine? (yes/no): ${RESET}"
    read -r answer

    if echo "$answer" | grep -qiE 'yes|no'; then
        is_complete "level3_c3_systemctl" && { already_done; level_menu; return; }
        mark_complete "level3_c3_systemctl"
        challenge_pass 35 "You can manage any service on a Linux server!"
        echo -e "  ${DIM}In DevOps: sudo systemctl restart app && systemctl status app\n  is how you deploy changes and confirm the service came back up.${RESET}"
    else
        challenge_fail "Answer yes or no — just check if SSH is running: systemctl status sshd"
    fi

    pause
    level_menu
}

c3_sysinfo() {
    clear
    echo -e "\n  ${BOLD}Challenge 3.5 — Read System Health${RESET}\n"

    teach "uname / df / free / uptime" \
        "A sysadmin always knows the state of their machine.\nThese commands give you the vital signs in seconds." \
        "uname -a && uptime && free -h && df -h /" \
        "(one line to see kernel, uptime, RAM, and disk)"

    echo -e "  ${BOLD}The commands:${RESET}"
    echo -e "  ${CYAN}uname -r${RESET}    — kernel version"
    echo -e "  ${CYAN}uname -a${RESET}    — all kernel info"
    echo -e "  ${CYAN}uptime${RESET}      — how long running + load average"
    echo -e "  ${CYAN}free -h${RESET}     — RAM and swap usage"
    echo -e "  ${CYAN}df -h${RESET}       — disk usage all filesystems"
    echo -e "  ${CYAN}df -h /${RESET}     — just the root disk"
    echo -e "  ${CYAN}df -i${RESET}       — inode usage"
    echo -e "  ${CYAN}lscpu${RESET}       — CPU info"
    echo -e "  ${CYAN}lsmem${RESET}       — memory info"
    echo -e "  ${CYAN}hostname -I${RESET} — your IP addresses"
    echo ""

    challenge_prompt "Full system health check" \
        "Run all of these and understand what each shows:\n\n  uname -r        → kernel version\n  uptime -p       → human readable uptime\n  free -h         → RAM\n  df -h /         → root disk\n  hostname -I     → your IPs\n  nproc           → number of CPU cores\n\n  Come back with answers to the verification questions." \
        "These 6 commands give you a complete picture in under 10 seconds."

    local kern; kern=$(uname -r)
    local cores; cores=$(nproc)

    echo -ne "  ${DIM}What is your kernel version? (run: uname -r) ${RESET}"
    read -r answer

    if [[ "$answer" == "$kern" ]]; then
        is_complete "level3_c3_sysinfo" && { already_done; level_menu; return; }
        mark_complete "level3_c3_sysinfo"
        challenge_pass 25 "You can read any machine's vital signs instantly!"
        echo -e "  ${DIM}When you SSH into a new server, these commands should be\n  your first 30 seconds. Know what you're working with.${RESET}"
    else
        challenge_fail "Run: uname -r — paste the exact output."
    fi

    pause
    level_menu
}

c3_boss() {
    clear
    echo -e "\n  ${YELLOW}${BOLD}★ BOSS CHALLENGE — Level 3: Server Triage ★${RESET}\n"
    echo -e "  ${DIM}You just SSHed into an unfamiliar server.\n  You have 5 questions to answer in 5 minutes. Go.${RESET}\n"
    divider
    echo ""
    echo -e "  Answer these questions using only Linux commands:\n"
    echo -e "  ${BOLD}Q1:${RESET} What Linux kernel is this server running?"
    echo -e "  ${BOLD}Q2:${RESET} How many CPU cores does it have?"
    echo -e "  ${BOLD}Q3:${RESET} What percentage of disk space is used on /?"
    echo -e "  ${BOLD}Q4:${RESET} Is the SSH service running? (yes or no)"
    echo -e "  ${BOLD}Q5:${RESET} What is the system's load average (1 minute)?"
    echo ""
    echo -e "  ${DIM}Commands to use: uname, nproc, df, systemctl, uptime or cat /proc/loadavg${RESET}"
    echo ""

    press_any

    local score=0

    local real_kern; real_kern=$(uname -r)
    echo -ne "  ${DIM}Q1 — Kernel version: ${RESET}"
    read -r q1
    [[ "$q1" == "$real_kern" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected: $real_kern"

    local real_cores; real_cores=$(nproc)
    echo -ne "  ${DIM}Q2 — CPU cores: ${RESET}"
    read -r q2
    [[ "$q2" == "$real_cores" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected: $real_cores — run: nproc"

    local real_disk; real_disk=$(df / | awk 'NR==2{print $5}' | tr -d '%')
    echo -ne "  ${DIM}Q3 — Disk usage on / (just the number, no %): ${RESET}"
    read -r q3
    [[ "$q3" == "$real_disk" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected: ${real_disk}% — run: df -h /"

    echo -ne "  ${DIM}Q4 — Is SSH running? (yes/no): ${RESET}"
    read -r q4
    ssh_running=false
    systemctl is-active --quiet sshd 2>/dev/null && ssh_running=true
    systemctl is-active --quiet ssh  2>/dev/null && ssh_running=true
    if $ssh_running && echo "$q4" | grep -qi 'yes'; then
        ok "Correct!"; (( score++ ))
    elif ! $ssh_running && echo "$q4" | grep -qi 'no'; then
        ok "Correct!"; (( score++ ))
    else
        fail "Run: systemctl status sshd"
    fi

    local real_load; real_load=$(cut -d' ' -f1 /proc/loadavg)
    echo -ne "  ${DIM}Q5 — Load average (1 min): ${RESET}"
    read -r q5
    [[ "$q5" == "$real_load" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected: $real_load — run: uptime"

    echo ""
    echo -e "  ${BOLD}Score: ${score}/5${RESET}"

    if [[ $score -ge 4 ]]; then
        is_complete "level3_c3_boss" && { already_done; level_menu; return; }
        mark_complete "level3_c3_boss"
        challenge_pass 50 "LEVEL 3 BOSS DEFEATED — Server Triage Expert!"
        echo ""
        echo -e "  ${CYAN}${BOLD}This is the first thing every DevOps engineer does on a new server.${RESET}"
        echo -e "  ${DIM}You now have the foundation. Networking and scripting are next.${RESET}"
    elif [[ $score -ge 3 ]]; then
        warn "$score/5. Almost — fix the ones you missed and try again."
    else
        challenge_fail "Review Level 3 challenges and come back stronger."
    fi

    pause
    level_menu
}

level_menu
