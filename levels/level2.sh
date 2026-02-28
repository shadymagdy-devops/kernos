#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  LEVEL 2 — Reading, Writing, Permissions
#  Commands: cat, less, head, tail, grep, chmod, chown
#  XP available: 150
# ─────────────────────────────────────────────

KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$KERNOS_DIR/config/ui.sh"
source "$KERNOS_DIR/config/progress.sh"
source "$KERNOS_DIR/config/challenge.sh"

level_menu() {
    clear
    banner
    echo -e "  ${CYAN}${BOLD}LEVEL 2 — Reading, Writing, Permissions${RESET}"
    echo -e "  ${DIM}Learn to read files, search them, and control who can touch them.${RESET}"
    echo ""
    show_xp_bar
    divider
    echo ""

    local challenges=(
        "2.1" "Reading files         (cat, less, head, tail)" "c2_read"
        "2.2" "Searching text        (grep)"                  "c2_grep"
        "2.3" "Redirects & pipes     (>, >>, |)"              "c2_pipes"
        "2.4" "File permissions      (chmod)"                 "c2_chmod"
        "2.5" "Ownership             (chown, whoami, id)"     "c2_chown"
        "2.6" "BOSS — The log hunter (combine all)"           "c2_boss"
    )

    for ((i=0; i<${#challenges[@]}; i+=3)); do
        local id="${challenges[$i]}"
        local title="${challenges[$((i+1))]}"
        local fn="${challenges[$((i+2))]}"
        if is_complete "level2_${fn}"; then
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
        1|2.1) c2_read  ;;
        2|2.2) c2_grep  ;;
        3|2.3) c2_pipes ;;
        4|2.4) c2_chmod ;;
        5|2.5) c2_chown ;;
        6|2.6) c2_boss  ;;
        "")    return   ;;
        *)     level_menu ;;
    esac
}

# ─────────────────────────────────────────────
c2_read() {
    clear
    echo -e "\n  ${BOLD}Challenge 2.1 — Reading Files${RESET}\n"

    teach "cat / less / head / tail" \
        "Linux gives you multiple ways to read files.\nEach has a different use case." \
        "tail -f /var/log/syslog" \
        "(follows the log in real time — Ctrl+C to stop)"

    echo -e "  ${BOLD}The tools:${RESET}"
    echo -e "  ${CYAN}cat file.txt${RESET}        — print entire file to screen"
    echo -e "  ${CYAN}less file.txt${RESET}       — scroll through file (q to quit)"
    echo -e "  ${CYAN}head -n 5 file.txt${RESET}  — show first 5 lines"
    echo -e "  ${CYAN}tail -n 5 file.txt${RESET}  — show last 5 lines"
    echo -e "  ${CYAN}tail -f file.txt${RESET}    — follow file in real time (logs!)"
    echo -e "  ${CYAN}wc -l file.txt${RESET}      — count lines"
    echo ""

    # Create a practice file
    setup_sandbox
    cat > "$SANDBOX/server.log" << 'EOF'
2024-01-18 08:00:01 INFO  Server started
2024-01-18 08:00:02 INFO  Listening on port 8080
2024-01-18 08:01:15 INFO  Request received: GET /
2024-01-18 08:02:33 WARN  High memory usage: 78%
2024-01-18 08:03:44 ERROR Cannot connect to database
2024-01-18 08:03:45 INFO  Retrying database connection...
2024-01-18 08:03:47 INFO  Database connected
2024-01-18 08:05:00 INFO  Health check passed
2024-01-18 08:10:00 WARN  Disk usage at 82%
2024-01-18 08:15:00 ERROR Timeout on /api/users endpoint
EOF

    echo -e "  ${DIM}A practice log file has been created at:${RESET}"
    echo -e "  ${CYAN}$SANDBOX/server.log${RESET}\n"

    challenge_prompt "Read the log file 4 ways" \
        "Practice all four commands on $SANDBOX/server.log:\n\n  1. cat $SANDBOX/server.log\n  2. head -n 3 $SANDBOX/server.log\n  3. tail -n 3 $SANDBOX/server.log\n  4. wc -l $SANDBOX/server.log\n\n  Come back when you know how many lines the file has." \
        "wc -l counts lines. wc -w counts words. wc -c counts characters."

    echo -ne "  ${DIM}How many lines does server.log have? ${RESET}"
    read -r answer

    if [[ "$answer" == "10" ]]; then
        is_complete "level2_c2_read" && { already_done; level_menu; return; }
        mark_complete "level2_c2_read"
        challenge_pass 20 "You can read files like a pro!"
        echo -e "  ${DIM}tail -f is one of the most used commands in DevOps.\n  Watch logs in real time while your app is running.${RESET}"
    else
        challenge_fail "The file has 10 lines. Run: wc -l $SANDBOX/server.log"
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
c2_grep() {
    clear
    echo -e "\n  ${BOLD}Challenge 2.2 — Searching Text${RESET}\n"

    teach "grep" \
        "grep searches for patterns inside files.\nIt's one of the most powerful tools in Linux.\nMaster grep and you can find anything." \
        "grep 'ERROR' /var/log/syslog" \
        "(prints every line containing 'ERROR')"

    echo -e "  ${BOLD}Essential flags:${RESET}"
    echo -e "  ${CYAN}grep 'word' file${RESET}       — find lines containing 'word'"
    echo -e "  ${CYAN}grep -i 'word' file${RESET}    — case insensitive"
    echo -e "  ${CYAN}grep -n 'word' file${RESET}    — show line numbers"
    echo -e "  ${CYAN}grep -c 'word' file${RESET}    — count matching lines"
    echo -e "  ${CYAN}grep -v 'word' file${RESET}    — show lines NOT matching"
    echo -e "  ${CYAN}grep -r 'word' dir/${RESET}    — search recursively in directory"
    echo -e "  ${CYAN}grep -E 'err|warn' file${RESET}— match multiple patterns (regex)"
    echo ""

    challenge_prompt "Hunt the errors" \
        "Using the log file at $SANDBOX/server.log:\n\n  1. grep 'ERROR' $SANDBOX/server.log\n     (find all error lines)\n\n  2. grep -c 'INFO' $SANDBOX/server.log\n     (count how many INFO lines there are)\n\n  3. grep -v 'INFO' $SANDBOX/server.log\n     (show everything that is NOT an INFO line)\n\n  Come back with the ERROR count and INFO count." \
        "grep -c counts matches. grep -v inverts the match."

    echo -ne "  ${DIM}How many ERROR lines are in server.log? ${RESET}"
    read -r answer

    if [[ "$answer" == "2" ]]; then
        is_complete "level2_c2_grep" && { already_done; level_menu; return; }
        mark_complete "level2_c2_grep"
        challenge_pass 25 "grep mastered — you can find anything in any file!"
        echo -e "  ${DIM}In real DevOps work: grep -r 'Exception' /var/log/app/ finds\n  all exceptions across all log files instantly.${RESET}"
    else
        challenge_fail "There are 2 ERROR lines. Run: grep -c 'ERROR' $SANDBOX/server.log"
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
c2_pipes() {
    clear
    echo -e "\n  ${BOLD}Challenge 2.3 — Redirects & Pipes${RESET}\n"

    teach "| > >>" \
        "Pipes connect commands together. Output of one becomes input of the next.\nRedirects send output to files.\nThese are the building blocks of shell scripting." \
        "cat /etc/passwd | grep bash | wc -l" \
        "(count users who use bash as their shell)"

    echo -e "  ${BOLD}The operators:${RESET}"
    echo -e "  ${CYAN}cmd > file${RESET}       — write output to file (overwrites)"
    echo -e "  ${CYAN}cmd >> file${RESET}      — append output to file"
    echo -e "  ${CYAN}cmd1 | cmd2${RESET}      — pipe: output of cmd1 becomes input of cmd2"
    echo -e "  ${CYAN}cmd 2> err.txt${RESET}   — redirect errors to file"
    echo -e "  ${CYAN}cmd 2>&1${RESET}         — redirect errors to same place as output"
    echo ""
    echo -e "  ${BOLD}Power combos:${RESET}"
    echo -e "  ${CYAN}ls -la | grep '^d'${RESET}            — list only directories"
    echo -e "  ${CYAN}cat file | sort | uniq${RESET}        — sort and remove duplicates"
    echo -e "  ${CYAN}ps aux | grep nginx | wc -l${RESET}   — count nginx processes"
    echo ""

    challenge_prompt "Chain commands together" \
        "Complete these pipe challenges:\n\n  1. cat $SANDBOX/server.log | grep 'WARN' | wc -l\n     (how many WARNING lines?)\n\n  2. cat $SANDBOX/server.log | grep -v 'INFO' > $SANDBOX/problems.txt\n     (save all non-INFO lines to a new file)\n\n  3. cat $SANDBOX/server.log | tail -n 5 | grep 'ERROR'\n     (find errors in the last 5 lines)" \
        "Pipes chain left to right. Output flows like water through pipes."

    local pass=0
    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    verify_file_exists "$SANDBOX/problems.txt" "problems.txt was created" && \
    verify_file_contains "$SANDBOX/problems.txt" "ERROR" && pass=1

    if [[ $pass -eq 1 ]]; then
        is_complete "level2_c2_pipes" && { already_done; level_menu; return; }
        mark_complete "level2_c2_pipes"
        challenge_pass 25 "You understand the Unix philosophy — chain small tools together!"
        echo -e "  ${DIM}This is the Unix philosophy: small tools that do one thing well,\n  chained together to do complex things. This is why Linux is powerful.${RESET}"
    else
        challenge_fail "Create problems.txt by running: cat server.log | grep -v 'INFO' > $SANDBOX/problems.txt"
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
c2_chmod() {
    clear
    echo -e "\n  ${BOLD}Challenge 2.4 — File Permissions${RESET}\n"

    teach "chmod" \
        "Every file has permissions: who can read, write, execute it.\nchmod changes those permissions.\nUnderstanding permissions is critical for security and scripting." \
        "chmod 755 script.sh" \
        "(owner: rwx  group: r-x  others: r-x)"

    echo -e "  ${BOLD}Reading permissions from ls -la:${RESET}"
    echo -e "  ${DIM}-rwxr-xr-x  1 ubuntu ubuntu  512 Jan 18 script.sh${RESET}"
    echo -e "  ${DIM} ^^^         = owner permissions  (rwx = read+write+execute)${RESET}"
    echo -e "  ${DIM}    ^^^      = group permissions  (r-x = read+execute only)${RESET}"
    echo -e "  ${DIM}       ^^^   = others permissions (r-x = read+execute only)${RESET}"
    echo ""
    echo -e "  ${BOLD}The numbers:${RESET}"
    echo -e "  ${CYAN}4${RESET} = read   ${CYAN}2${RESET} = write   ${CYAN}1${RESET} = execute"
    echo -e "  ${CYAN}7${RESET} = 4+2+1 = rwx (full)   ${CYAN}6${RESET} = 4+2 = rw-   ${CYAN}5${RESET} = 4+1 = r-x"
    echo ""
    echo -e "  ${BOLD}Common patterns:${RESET}"
    echo -e "  ${CYAN}chmod 755 script.sh${RESET}   — executable script (owner full, others read+run)"
    echo -e "  ${CYAN}chmod 644 file.txt${RESET}    — normal file (owner rw, others read only)"
    echo -e "  ${CYAN}chmod 600 secret.key${RESET}  — private file (owner only, no one else)"
    echo -e "  ${CYAN}chmod 700 private/${RESET}    — private directory"
    echo -e "  ${CYAN}chmod +x script.sh${RESET}    — just add execute bit"
    echo ""

    # Create a test script
    setup_sandbox
    echo '#!/bin/bash
echo "Kernos script works!"' > "$SANDBOX/test_script.sh"
    chmod 644 "$SANDBOX/test_script.sh"

    challenge_prompt "Make a script executable" \
        "A script exists at: $SANDBOX/test_script.sh\n  Right now it can't be executed. Your task:\n\n  1. ls -la $SANDBOX/test_script.sh\n     (see its current permissions)\n\n  2. chmod 755 $SANDBOX/test_script.sh\n     (make it executable for everyone)\n\n  3. ls -la $SANDBOX/test_script.sh\n     (verify it changed)\n\n  4. $SANDBOX/test_script.sh\n     (run it!)" \
        "755 = owner:rwx group:r-x others:r-x"

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -x "$SANDBOX/test_script.sh" ]]; then
        local perms; perms=$(stat -c "%a" "$SANDBOX/test_script.sh")
        ok "Script is executable (permissions: $perms)"
        is_complete "level2_c2_chmod" && { already_done; level_menu; return; }
        mark_complete "level2_c2_chmod"
        challenge_pass 30 "You control who can do what with every file!"
        echo -e "  ${DIM}chmod +x is the most common use. chmod 600 on SSH keys and\n  private config files is a security essential.${RESET}"
    else
        challenge_fail "The script is not executable yet. Run: chmod 755 $SANDBOX/test_script.sh"
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
c2_chown() {
    clear
    echo -e "\n  ${BOLD}Challenge 2.5 — Who Owns What${RESET}\n"

    teach "whoami / id / chown" \
        "Every file has an owner and a group.\nwhoami shows your username. id shows all your groups.\nchown changes file ownership (needs sudo)." \
        "id" \
        "uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),27(sudo),4(adm)"

    echo -e "  ${BOLD}Identity commands:${RESET}"
    echo -e "  ${CYAN}whoami${RESET}                      — your username"
    echo -e "  ${CYAN}id${RESET}                          — your UID, GID, and all groups"
    echo -e "  ${CYAN}groups${RESET}                      — just your groups"
    echo -e "  ${CYAN}who${RESET}                         — who is logged in right now"
    echo -e "  ${CYAN}w${RESET}                           — who is logged in + what they're doing"
    echo ""
    echo -e "  ${BOLD}Ownership:${RESET}"
    echo -e "  ${CYAN}ls -la file.txt${RESET}             — see owner and group"
    echo -e "  ${CYAN}sudo chown user file.txt${RESET}    — change owner"
    echo -e "  ${CYAN}sudo chown user:group file${RESET}  — change owner and group"
    echo ""

    challenge_prompt "Know your identity" \
        "Run these commands and understand the output:\n\n  1. whoami\n  2. id\n  3. groups\n  4. ls -la ~ | head -5\n     (notice the owner column — it should be your username)\n\n  Come back with your UID number." \
        "UID 0 = root (superuser). Your UID is probably 1000 if you're the first user."

    echo -ne "  ${DIM}What is your user ID (UID)? Run: id -u ${RESET}"
    read -r answer

    local real_uid; real_uid=$(id -u)
    if [[ "$answer" == "$real_uid" ]]; then
        is_complete "level2_c2_chown" && { already_done; level_menu; return; }
        mark_complete "level2_c2_chown"
        challenge_pass 20 "You know your identity on this system!"
        echo -e "  ${DIM}UID 0 is root. Your UID (${real_uid}) makes you a regular user.\n  Being in the 'sudo' group is what lets you run commands as root.${RESET}"
    else
        challenge_fail "Run: id -u — that gives you your exact UID number."
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
c2_boss() {
    clear
    echo -e "\n  ${YELLOW}${BOLD}★ BOSS CHALLENGE — Level 2: The Log Hunter ★${RESET}\n"
    echo -e "  ${DIM}A real scenario. A production server is having problems.\n  You need to find out what's wrong using only Linux commands.${RESET}\n"
    divider

    # Build the scenario
    setup_sandbox
    mkdir -p "$SANDBOX/var/log/app"
    cat > "$SANDBOX/var/log/app/app.log" << 'EOF'
2024-01-18 09:00:01 INFO  Application started
2024-01-18 09:00:05 INFO  Connected to database
2024-01-18 09:01:00 INFO  Processed 120 requests
2024-01-18 09:02:00 WARN  Response time above 500ms: /api/search
2024-01-18 09:03:15 ERROR NullPointerException in UserService.java:142
2024-01-18 09:03:16 INFO  Request failed: GET /api/users/profile
2024-01-18 09:05:00 INFO  Processed 98 requests
2024-01-18 09:06:30 WARN  Database pool at 90% capacity
2024-01-18 09:07:00 ERROR Connection timeout: database unreachable
2024-01-18 09:07:01 ERROR Retry 1/3 failed
2024-01-18 09:07:03 ERROR Retry 2/3 failed
2024-01-18 09:07:05 ERROR Retry 3/3 failed
2024-01-18 09:07:06 FATAL Application entering emergency mode
2024-01-18 09:07:10 INFO  Alerting on-call engineer
EOF
    chmod 644 "$SANDBOX/var/log/app/app.log"

    echo -e "  ${BOLD}The scenario:${RESET}"
    echo -e "  An application log file is at:"
    echo -e "  ${CYAN}$SANDBOX/var/log/app/app.log${RESET}"
    echo ""
    echo -e "  Your mission — answer these 4 questions using Linux commands:\n"
    echo -e "  ${BOLD}Q1:${RESET} How many total lines are in the log?"
    echo -e "  ${BOLD}Q2:${RESET} How many ERROR lines are there?"
    echo -e "  ${BOLD}Q3:${RESET} What was the last thing that happened? (last line)"
    echo -e "  ${BOLD}Q4:${RESET} Save all ERROR and FATAL lines to: $SANDBOX/critical.log"
    echo ""
    echo -e "  ${DIM}Hint: wc -l, grep -c, tail -n 1, grep -E${RESET}"
    echo ""

    press_any

    local score=0
    echo -e "  ${BOLD}Answering the questions:${RESET}\n"

    echo -ne "  ${DIM}Q1 — Total lines in the log: ${RESET}"
    read -r q1
    [[ "$q1" == "14" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected 14. Run: wc -l $SANDBOX/var/log/app/app.log"

    echo -ne "  ${DIM}Q2 — Number of ERROR lines: ${RESET}"
    read -r q2
    [[ "$q2" == "5" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected 5. Run: grep -c 'ERROR' $SANDBOX/var/log/app/app.log"

    echo -ne "  ${DIM}Q3 — What was the last event? (paste the last line): ${RESET}"
    read -r q3
    echo "$q3" | grep -qi "alerting\|on-call\|engineer" && { ok "Correct!"; (( score++ )); } || fail "Run: tail -n 1 $SANDBOX/var/log/app/app.log"

    echo -e "  ${DIM}Q4 — Creating critical.log...${RESET}"
    echo -ne "  ${DIM}(Create it now if you haven't, then press Enter): ${RESET}"
    read -r
    verify_file_exists "$SANDBOX/critical.log" "critical.log" && \
    verify_file_contains "$SANDBOX/critical.log" "FATAL" && { (( score++ )); }

    echo ""
    echo -e "  ${BOLD}Score: ${score}/4${RESET}"

    if [[ $score -eq 4 ]]; then
        is_complete "level2_c2_boss" && { already_done; level_menu; return; }
        mark_complete "level2_c2_boss"
        challenge_pass 40 "LEVEL 2 BOSS DEFEATED — The Log Hunter!"
        echo ""
        echo -e "  ${CYAN}${BOLD}This is real DevOps work.${RESET}"
        echo -e "  ${DIM}Every time a production system goes down, engineers run exactly\n  these commands to understand what happened. You just did that.${RESET}"
    elif [[ $score -ge 2 ]]; then
        warn "$score/4 correct. Fix the rest and try again."
    else
        challenge_fail "Review the commands and try again. You need all 4."
    fi

    pause
    level_menu
}

level_menu
