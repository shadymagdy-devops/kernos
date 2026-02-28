#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"

# ─────────────────────────────────────────────
#  kernos logs
#  What your system has been quietly recording
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}System Logs${RESET}"
divider

learn "Linux logs everything. /var/log/ is where most of it lives. journalctl is
       the modern way to read logs from systemd. Knowing how to read logs is one
       of the most important skills a sysadmin can have — logs are the truth."

section "System Journal — Last 20 Entries"
echo ""
journalctl -n 20 --no-pager 2>/dev/null | awk '{printf "  %s\n", $0}' \
    || tail -20 /var/log/syslog 2>/dev/null | awk '{printf "  %s\n", $0}' \
    || info "Could not read system journal"
echo ""

section "Errors & Warnings (Last 24h)"
echo ""
error_count=$(journalctl --since "24 hours ago" -p err --no-pager 2>/dev/null | wc -l)
warn_count=$(journalctl  --since "24 hours ago" -p warning --no-pager 2>/dev/null | wc -l)

info "Errors in last 24h:    ${BOLD}${error_count}${RESET}"
info "Warnings in last 24h:  ${BOLD}${warn_count}${RESET}"
echo ""

if [[ "$error_count" -gt 50 ]]; then
    fail "High error count — something isn't happy on this machine"
elif [[ "$error_count" -gt 10 ]]; then
    warn "Some errors found — worth reviewing"
else
    ok "Error count looks normal"
fi

echo ""
info "Recent errors:"
journalctl --since "24 hours ago" -p err --no-pager 2>/dev/null \
    | tail -10 | awk '{printf "  \033[0;31m%s\033[0m\n", $0}'
echo ""

learn "journalctl -p err = show only error-level log entries.
       Levels: 0=emerg 1=alert 2=crit 3=err 4=warning 5=notice 6=info 7=debug
       --since '24 hours ago' filters by time. You can also do --since '2024-01-01'."

section "Authentication Log"
echo ""
auth_log=""
[[ -f /var/log/auth.log ]]   && auth_log="/var/log/auth.log"
[[ -f /var/log/secure ]]     && auth_log="/var/log/secure"

if [[ -n "$auth_log" ]]; then
    info "Source: $auth_log"
    echo ""
    fail_count=$(grep -c 'Failed password' "$auth_log" 2>/dev/null || echo 0)
    accept_count=$(grep -c 'Accepted' "$auth_log" 2>/dev/null || echo 0)
    info "Failed password attempts:   ${BOLD}${fail_count}${RESET}"
    info "Accepted logins:            ${BOLD}${accept_count}${RESET}"

    [[ "$fail_count" -gt 100 ]] && fail "Over 100 failed login attempts — you're being scanned" \
                                 || ok  "Failed login count is manageable"
    echo ""
    info "Last 5 successful logins:"
    grep 'Accepted' "$auth_log" 2>/dev/null | tail -5 | awk '{printf "  → %s\n", $0}'
else
    journalctl _SYSTEMD_UNIT=sshd.service --no-pager 2>/dev/null | tail -20 \
        | awk '{printf "  %s\n", $0}'
fi
echo ""

section "Boot Log — Last 3 Boots"
echo ""
journalctl --list-boots 2>/dev/null | tail -3 | awk '{printf "  Boot %-4s  %s %s  →  %s %s\n", $2,$3,$4,$6,$7}' \
    || info "Boot history not available"
echo ""

learn "journalctl --list-boots shows each time the system was started.
       You can read a specific boot's logs with: journalctl -b -1 (previous boot)
       This is incredibly useful for diagnosing a crash — read the log right before shutdown."
