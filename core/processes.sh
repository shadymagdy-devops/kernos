#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos processes [--kill PID] [--search name]
#  What's running, what's zombie, who's guilty
# ─────────────────────────────────────────────

handle_kill() {
    local pid=$1
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        fail "Give me a valid PID number"; exit 1
    fi
    proc_name=$(ps -p "$pid" -o comm= 2>/dev/null)
    [[ -z "$proc_name" ]] && { fail "No process with PID $pid found"; exit 1; }
    warn "Sending SIGTERM to PID $pid ($proc_name)..."
    if kill -15 "$pid" 2>/dev/null; then
        sleep 1
        if ps -p "$pid" > /dev/null 2>&1; then
            warn "Process didn't stop — sending SIGKILL..."
            kill -9 "$pid" 2>/dev/null && ok "Process $pid forcefully killed" \
                                        || fail "Could not kill PID $pid (permission denied?)"
        else
            ok "Process $pid ($proc_name) terminated cleanly"
        fi
    else
        fail "Could not signal PID $pid — do you have permission?"
    fi
    learn "SIGTERM (15) = polite request to stop. Gives the process time to clean up.
           SIGKILL (9) = forced kill. The kernel removes it instantly. No cleanup.
           Always try SIGTERM first — SIGKILL is the last resort."
    exit 0
}

handle_search() {
    local name=$1
    echo -e "\n  ${BOLD}Searching for: ${CYAN}$name${RESET}\n"
    result=$(pgrep -la "$name" 2>/dev/null)
    if [[ -z "$result" ]]; then
        info "No running process matched '$name'"
    else
        echo "$result" | awk '{printf "  PID \033[1m%-8s\033[0m  %s\n", $1, $2}'
    fi
    echo ""
    exit 0
}

# Route subcommands
[[ "$1" == "--kill" ]]   && handle_kill "$2"
[[ "$1" == "--search" ]] && handle_search "$2"

# ── Main view ─────────────────────────────────
echo -e "\n  ${BOLD}Processes${RESET}"
divider

section "Overview"
total=$(ps aux | wc -l)
running=$(ps aux | awk '$8=="R"' | wc -l)
sleeping=$(ps aux | awk '$8~/S/' | wc -l)
zombie=$(ps aux | awk '$8=="Z"' | wc -l)

info "Total processes:  ${BOLD}${total}${RESET}"
info "Running:          ${BOLD}${running}${RESET}"
info "Sleeping:         ${BOLD}${sleeping}${RESET}"

if [[ "$zombie" -gt 0 ]]; then
    fail "Zombie processes: ${BOLD}${zombie}${RESET}"
    learn "A zombie process has finished running but its parent hasn't collected its exit
           status yet. It's dead but still in the process table. A few zombies are normal.
           Hundreds means the parent process has a bug and isn't cleaning up after its children."
else
    ok "No zombie processes — clean process table"
fi

learn "Every process on Linux has a state. R=running, S=sleeping (waiting for something),
       Z=zombie (finished but not reaped), D=uninterruptible sleep (usually waiting on disk)."

section "Top CPU Hogs"
echo ""
ps aux --sort=-%cpu | awk '
NR==1 { printf "  \033[1m%-6s %-25s %-7s %-7s %s\033[0m\n", "PID", "COMMAND", "CPU%", "MEM%", "STATUS" }
NR>1 && NR<=11 {
    name=$11; if(length(name)>24) name=substr(name,1,24)"…"
    color=""
    if ($3+0 > 50) color="\033[0;31m"
    else if ($3+0 > 20) color="\033[1;33m"
    printf "  " color "%-6s %-25s %-7s %-7s %s\033[0m\n", $2, name, $3, $4, $8
}'
echo ""

section "Top Memory Hogs"
echo ""
ps aux --sort=-%mem | awk '
NR==1 { printf "  \033[1m%-6s %-25s %-7s %-9s\033[0m\n", "PID", "COMMAND", "MEM%", "RSS(MB)" }
NR>1 && NR<=8 {
    name=$11; if(length(name)>24) name=substr(name,1,24)"…"
    rss=int($6/1024)
    printf "  %-6s %-25s %-7s %-9s\n", $2, name, $4, rss"MB"
}'
echo ""

section "Useful Commands"
info "Kill a process:    ${BOLD}kernos processes --kill <PID>${RESET}"
info "Search by name:    ${BOLD}kernos processes --search <name>${RESET}"
echo ""
