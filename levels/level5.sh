#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  LEVEL 5 — Bash Scripting
#  Variables, loops, conditions, functions
#  XP available: 250
# ─────────────────────────────────────────────

KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$KERNOS_DIR/config/ui.sh"
source "$KERNOS_DIR/config/progress.sh"
source "$KERNOS_DIR/config/challenge.sh"

SCRIPT_DIR="$HOME/.kernos/scripts"

level_menu() {
    clear
    banner
    echo -e "  ${CYAN}${BOLD}LEVEL 5 — Bash Scripting${RESET}"
    echo -e "  ${DIM}Write scripts that automate everything. This is where Linux becomes a superpower.${RESET}"
    echo ""
    show_xp_bar
    divider
    echo ""

    local challenges=(
        "5.1" "Variables & input     (read, echo, \$VAR)"       "c5_vars"
        "5.2" "Conditions            (if/elif/else, test)"       "c5_conditions"
        "5.3" "Loops                 (for, while)"               "c5_loops"
        "5.4" "Functions             (define, call, return)"     "c5_functions"
        "5.5" "Real script           (args, exit codes)"         "c5_args"
        "5.6" "BOSS — Write a health check script"               "c5_boss"
    )

    for ((i=0; i<${#challenges[@]}; i+=3)); do
        local id="${challenges[$i]}"
        local title="${challenges[$((i+1))]}"
        local fn="${challenges[$((i+2))]}"
        if is_complete "level5_${fn}"; then
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
        1|5.1) c5_vars       ;;
        2|5.2) c5_conditions ;;
        3|5.3) c5_loops      ;;
        4|5.4) c5_functions  ;;
        5|5.5) c5_args       ;;
        6|5.6) c5_boss       ;;
        "")    return         ;;
        *)     level_menu     ;;
    esac
}

c5_vars() {
    clear
    echo -e "\n  ${BOLD}Challenge 5.1 — Variables & Input${RESET}\n"

    teach "Variables" \
        "Variables store values. No spaces around = in Bash.\nReference with \$VAR or \${VAR}.\nread takes input from the user." \
        'NAME="Alice"
echo "Hello, $NAME"
read -p "Enter your name: " NAME' \
        'Hello, Alice
Enter your name: _'

    echo -e "  ${BOLD}Variable types:${RESET}"
    echo -e '  NAME="Alice"         — string'
    echo -e '  AGE=25               — number (still a string in Bash)'
    echo -e '  FILES=$(ls)          — command output'
    echo -e '  TODAY=$(date +%F)    — date formatted as YYYY-MM-DD'
    echo -e '  readonly PI=3.14159  — constant'
    echo ""
    echo -e "  ${BOLD}Special variables:${RESET}"
    echo -e "  ${CYAN}\$0${RESET}  = script name   ${CYAN}\$1 \$2${RESET} = arguments"
    echo -e "  ${CYAN}\$?${RESET}  = last exit code ${CYAN}\$#${RESET}  = number of args"
    echo -e "  ${CYAN}\$@${RESET}  = all arguments  ${CYAN}\$\$${RESET}  = current PID"
    echo ""

    mkdir -p "$SCRIPT_DIR"

    challenge_prompt "Write a variables script" \
        "Create a script at $SCRIPT_DIR/vars.sh that:\n\n  1. Creates a variable: NAME=\"YourName\"\n  2. Creates: TODAY=\$(date +%F)\n  3. Prints: \"Hello NAME, today is TODAY\"\n  4. Prints: \"This script's PID is \$\$\"\n  5. Makes itself executable and runs it\n\n  Template to start:\n  #!/usr/bin/env bash\n  NAME=\"YourName\"\n  TODAY=\$(date +%F)\n  echo \"Hello \$NAME, today is \$TODAY\"\n  echo \"PID: \$\$\"" \
        "chmod +x $SCRIPT_DIR/vars.sh then run it: $SCRIPT_DIR/vars.sh"

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -f "$SCRIPT_DIR/vars.sh" ]] && [[ -x "$SCRIPT_DIR/vars.sh" ]]; then
        local output; output=$("$SCRIPT_DIR/vars.sh" 2>/dev/null)
        if echo "$output" | grep -qiE 'hello|today'; then
            is_complete "level5_c5_vars" && { already_done; level_menu; return; }
            mark_complete "level5_c5_vars"
            challenge_pass 35 "Your first real Bash script works!"
            echo -e "  ${DIM}Every Bash script starts with #!/usr/bin/env bash (the shebang).\n  This tells the system which interpreter to use.${RESET}"
        else
            challenge_fail "Script exists but output doesn't look right. Check it outputs 'Hello' and 'today'."
        fi
    else
        challenge_fail "Create and make executable: chmod +x $SCRIPT_DIR/vars.sh"
    fi

    pause
    level_menu
}

c5_conditions() {
    clear
    echo -e "\n  ${BOLD}Challenge 5.2 — Conditions${RESET}\n"

    teach "if/elif/else" \
        "Conditions let your script make decisions.\n[[ ]] is the modern test syntax in Bash.\nAlways use spaces inside [[ ]]." \
        '#!/usr/bin/env bash
DISK=$(df / | awk '"'"'NR==2{print $5}'"'"' | tr -d "%")
if [[ $DISK -gt 90 ]]; then
    echo "CRITICAL: disk almost full"
elif [[ $DISK -gt 70 ]]; then
    echo "WARNING: disk getting full"
else
    echo "OK: disk usage fine"
fi' \
        ""

    echo -e "  ${BOLD}Comparison operators:${RESET}"
    echo -e "  ${DIM}Numbers:${RESET}  ${CYAN}-eq${RESET} -ne -lt -le -gt -ge"
    echo -e "  ${DIM}Strings:${RESET}  ${CYAN}==${RESET}  !=  -z (empty) -n (not empty)"
    echo -e "  ${DIM}Files:${RESET}    ${CYAN}-f${RESET} (file exists)  -d (dir)  -x (executable)"
    echo ""
    echo -e "  ${CYAN}[[ -f /etc/passwd ]] && echo 'exists'${RESET}   — short form"
    echo -e "  ${CYAN}[[ -d /tmp ]] || mkdir /tmp${RESET}             — create if missing"
    echo ""

    challenge_prompt "Write a disk check script" \
        "Create $SCRIPT_DIR/diskcheck.sh that:\n\n  1. Gets disk usage of / (just the number)\n  2. If > 90: prints 'CRITICAL'\n  3. If > 70: prints 'WARNING'\n  4. Otherwise: prints 'OK'\n  5. Always prints the actual percentage\n\n  Test it: $SCRIPT_DIR/diskcheck.sh" \
        "DISK=\$(df / | awk 'NR==2{print \$5}' | tr -d '%')"

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -f "$SCRIPT_DIR/diskcheck.sh" ]] && [[ -x "$SCRIPT_DIR/diskcheck.sh" ]]; then
        local output; output=$("$SCRIPT_DIR/diskcheck.sh" 2>/dev/null)
        if echo "$output" | grep -qiE 'ok|warn|critical'; then
            is_complete "level5_c5_conditions" && { already_done; level_menu; return; }
            mark_complete "level5_c5_conditions"
            challenge_pass 40 "Your script makes decisions!"
            echo -e "  ${DIM}This exact pattern — get a value, compare, output status — is\n  the core of every monitoring script in DevOps.${RESET}"
        else
            challenge_fail "Script should output OK, WARNING, or CRITICAL."
        fi
    else
        challenge_fail "Create: $SCRIPT_DIR/diskcheck.sh and make it executable."
    fi

    pause
    level_menu
}

c5_loops() {
    clear
    echo -e "\n  ${BOLD}Challenge 5.3 — Loops${RESET}\n"

    teach "for / while" \
        "Loops repeat actions. for iterates over a list.\nwhile loops while a condition is true.\nLoops + Linux commands = automation." \
        '# Loop over files
for file in /etc/*.conf; do
    echo "Config: $file"
done

# Count to 5
for i in {1..5}; do
    echo "Step $i"
done

# While loop
count=0
while [[ $count -lt 3 ]]; do
    echo "Count: $count"
    count=$(( count + 1 ))
done' \
        ""

    challenge_prompt "Write a file scanner" \
        "Create $SCRIPT_DIR/scanner.sh that:\n\n  1. Loops over all .sh files in $SCRIPT_DIR\n  2. For each file, prints its name and whether it's executable\n  3. At the end, prints total count of .sh files found\n\n  for f in $SCRIPT_DIR/*.sh; do\n    if [[ -x \"\$f\" ]]; then\n      echo \"\$f is executable\"\n    else\n      echo \"\$f is NOT executable\"\n    fi\n  done" \
        "Use a counter variable: count=0 then (( count++ )) inside the loop"

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -f "$SCRIPT_DIR/scanner.sh" ]] && [[ -x "$SCRIPT_DIR/scanner.sh" ]]; then
        local output; output=$("$SCRIPT_DIR/scanner.sh" 2>/dev/null)
        if echo "$output" | grep -qiE 'executable|sh'; then
            is_complete "level5_c5_loops" && { already_done; level_menu; return; }
            mark_complete "level5_c5_loops"
            challenge_pass 40 "You can loop over anything — files, lines, numbers, commands!"
        else
            challenge_fail "Script should print info about .sh files in $SCRIPT_DIR"
        fi
    else
        challenge_fail "Create: $SCRIPT_DIR/scanner.sh and make it executable."
    fi

    pause
    level_menu
}

c5_functions() {
    clear
    echo -e "\n  ${BOLD}Challenge 5.4 — Functions${RESET}\n"

    teach "functions" \
        "Functions group reusable code. Define once, call many times.\nBash functions return exit codes (0=success, 1=failure).\nUse 'local' for variables inside functions." \
        '#!/usr/bin/env bash

check_service() {
    local name="$1"
    if systemctl is-active --quiet "$name" 2>/dev/null; then
        echo "  OK: $name is running"
        return 0
    else
        echo "  FAIL: $name is not running"
        return 1
    fi
}

check_service sshd
check_service nginx
check_service mysql' \
        ""

    challenge_prompt "Write a script with functions" \
        "Create $SCRIPT_DIR/functions.sh with:\n\n  1. A function: print_header() that prints a formatted title\n  2. A function: check_disk() that returns disk % and a status\n  3. A function: check_memory() that returns RAM % and a status\n  4. Call all three functions\n\n  Structure:\n  #!/usr/bin/env bash\n  print_header() { echo \"=== \$1 ===\"; }\n  check_disk()   { ... }\n  check_memory() { ... }\n  print_header 'Health Check'\n  check_disk\n  check_memory" \
        "Functions make scripts readable. If it's longer than 5 lines, it should be a function."

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -f "$SCRIPT_DIR/functions.sh" ]] && [[ -x "$SCRIPT_DIR/functions.sh" ]]; then
        if grep -q 'function\|()' "$SCRIPT_DIR/functions.sh" && \
           grep -qc '()' "$SCRIPT_DIR/functions.sh" | grep -q '[2-9]'; then
            is_complete "level5_c5_functions" && { already_done; level_menu; return; }
            mark_complete "level5_c5_functions"
            challenge_pass 45 "Your scripts are now modular and professional!"
        else
            local fn_count; fn_count=$(grep -c '()' "$SCRIPT_DIR/functions.sh" 2>/dev/null || echo 0)
            [[ "$fn_count" -ge 2 ]] && {
                is_complete "level5_c5_functions" && { already_done; level_menu; return; }
                mark_complete "level5_c5_functions"
                challenge_pass 45 "Functions mastered!"
            } || challenge_fail "Define at least 2 functions (with () syntax) in the script."
        fi
    else
        challenge_fail "Create: $SCRIPT_DIR/functions.sh and make it executable."
    fi

    pause
    level_menu
}

c5_args() {
    clear
    echo -e "\n  ${BOLD}Challenge 5.5 — Arguments & Exit Codes${RESET}\n"

    teach "Arguments & Exit Codes" \
        "Scripts accept arguments like commands do: script.sh arg1 arg2\n\$1, \$2 = positional args. \$@ = all args. \$# = count.\nExit codes: 0 = success, anything else = error." \
        '#!/usr/bin/env bash
# Usage: ./greet.sh Alice
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <name>"
    exit 1
fi
NAME="$1"
echo "Hello, $NAME!"
exit 0' \
        ""

    echo -e "  ${BOLD}Exit codes matter:${RESET}"
    echo -e "  ${CYAN}exit 0${RESET}    — success"
    echo -e "  ${CYAN}exit 1${RESET}    — general error"
    echo -e "  ${CYAN}\$?${RESET}       — exit code of last command"
    echo -e "  ${CYAN}cmd && echo ok || echo fail${RESET} — act on exit code"
    echo ""

    challenge_prompt "Write a script that takes arguments" \
        "Create $SCRIPT_DIR/backup.sh that:\n\n  1. Takes one argument: the directory to back up\n  2. If no argument given: prints usage and exits with code 1\n  3. If directory doesn't exist: prints error and exits with 1\n  4. If valid: creates a tar.gz backup with timestamp in /tmp\n  5. Prints success message with backup filename\n\n  Test: $SCRIPT_DIR/backup.sh ~/kernos-practice" \
        "TIMESTAMP=\$(date +%Y%m%d_%H%M%S) — use this in your filename"

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -f "$SCRIPT_DIR/backup.sh" ]] && [[ -x "$SCRIPT_DIR/backup.sh" ]]; then
        # Test no-arg error handling
        "$SCRIPT_DIR/backup.sh" 2>/dev/null
        local code=$?
        if [[ $code -ne 0 ]]; then
            ok "Exits with error code when no argument given"
            is_complete "level5_c5_args" && { already_done; level_menu; return; }
            mark_complete "level5_c5_args"
            challenge_pass 45 "Professional script with proper argument handling!"
            echo -e "  ${DIM}Real scripts always validate their arguments.\n  A script that fails silently is worse than one that gives clear errors.${RESET}"
        else
            challenge_fail "Script should exit with code 1 when no argument is given."
        fi
    else
        challenge_fail "Create: $SCRIPT_DIR/backup.sh and make it executable."
    fi

    pause
    level_menu
}

c5_boss() {
    clear
    echo -e "\n  ${YELLOW}${BOLD}★ BOSS CHALLENGE — Level 5: The Health Check Script ★${RESET}\n"
    echo -e "  ${DIM}Write a complete, real-world Bash script from scratch.\n  This is the kind of script you'd write on your first DevOps job.${RESET}\n"
    divider
    echo ""
    echo -e "  ${BOLD}Mission: Create $SCRIPT_DIR/healthcheck.sh${RESET}\n"
    echo -e "  The script must:"
    echo ""
    echo -e "  ${CYAN}1.${RESET} Print a formatted header: '=== System Health Check ==='"
    echo -e "  ${CYAN}2.${RESET} Check CPU load — warn if load > number of cores"
    echo -e "  ${CYAN}3.${RESET} Check disk / — warn if > 80%, critical if > 90%"
    echo -e "  ${CYAN}4.${RESET} Check RAM — warn if used > 80%"
    echo -e "  ${CYAN}5.${RESET} Check if SSH service is running"
    echo -e "  ${CYAN}6.${RESET} Count zombie processes — warn if any found"
    echo -e "  ${CYAN}7.${RESET} Print a final summary line: 'X issues found'"
    echo -e "  ${CYAN}8.${RESET} Exit with code 0 if no issues, 1 if issues found"
    echo ""
    echo -e "  ${DIM}Use: functions, variables, if/else, exit codes, \$() substitution${RESET}"
    echo -e "  ${DIM}Hint: each check should be its own function${RESET}"
    echo ""
    echo -e "  ${DIM}Take your time. This is the real thing.${RESET}"
    echo ""

    press_any

    echo -e "\n  ${BOLD}Verification:${RESET}\n"
    local score=0

    # Check file exists and is executable
    if [[ -f "$SCRIPT_DIR/healthcheck.sh" ]] && [[ -x "$SCRIPT_DIR/healthcheck.sh" ]]; then
        ok "Script exists and is executable"; (( score++ ))
    else
        fail "Script not found or not executable at $SCRIPT_DIR/healthcheck.sh"
    fi

    # Check it has functions
    if grep -q '()' "$SCRIPT_DIR/healthcheck.sh" 2>/dev/null; then
        local fn_count; fn_count=$(grep -c '()' "$SCRIPT_DIR/healthcheck.sh")
        ok "Has $fn_count function(s) defined"; (( score++ ))
    else
        fail "No functions found — use functions for each check"
    fi

    # Check it covers disk
    if grep -qiE 'df|disk' "$SCRIPT_DIR/healthcheck.sh" 2>/dev/null; then
        ok "Disk check present"; (( score++ ))
    else
        fail "Missing disk check (df /)"
    fi

    # Check it covers memory
    if grep -qiE 'free|mem|meminfo' "$SCRIPT_DIR/healthcheck.sh" 2>/dev/null; then
        ok "Memory check present"; (( score++ ))
    else
        fail "Missing memory check (free)"
    fi

    # Check it covers SSH/services
    if grep -qiE 'systemctl|sshd|ssh' "$SCRIPT_DIR/healthcheck.sh" 2>/dev/null; then
        ok "Service check present"; (( score++ ))
    else
        fail "Missing service check (systemctl)"
    fi

    # Check exit codes
    if grep -q 'exit' "$SCRIPT_DIR/healthcheck.sh" 2>/dev/null; then
        ok "Uses exit codes"; (( score++ ))
    else
        fail "No exit codes found — add exit 0 / exit 1"
    fi

    # Run it
    if [[ -f "$SCRIPT_DIR/healthcheck.sh" ]] && [[ -x "$SCRIPT_DIR/healthcheck.sh" ]]; then
        local output; output=$("$SCRIPT_DIR/healthcheck.sh" 2>/dev/null)
        if echo "$output" | grep -qiE 'ok|warn|critical|pass|fail|health|check'; then
            ok "Script runs and produces output"; (( score++ ))
        else
            fail "Script runs but output doesn't look like a health check"
        fi
    fi

    echo ""
    echo -e "  ${BOLD}Score: ${score}/7${RESET}"

    if [[ $score -ge 6 ]]; then
        is_complete "level5_c5_boss" && { already_done; level_menu; return; }
        mark_complete "level5_c5_boss"
        challenge_pass 80 "LEVEL 5 BOSS DEFEATED — You wrote a real DevOps script!"
        echo ""
        echo -e "  ${CYAN}${BOLD}This script would be useful on any Linux server right now.${RESET}"
        echo -e "  ${DIM}Add it to cron and you have an automated monitoring system.\n  That's what DevOps engineers build. You just built one.${RESET}"
        echo ""
        show_xp_bar
    elif [[ $score -ge 4 ]]; then
        warn "$score/7 — you're close. Fix the missing pieces."
    else
        challenge_fail "Keep building. Review the requirements and add what's missing."
    fi

    pause
    level_menu
}

level_menu
