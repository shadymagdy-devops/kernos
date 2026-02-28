#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  LEVEL 4 — Networking Essentials
#  Commands: ip, ss, ping, curl, ssh, scp, netstat
#  XP available: 200
# ─────────────────────────────────────────────

KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$KERNOS_DIR/config/ui.sh"
source "$KERNOS_DIR/config/progress.sh"
source "$KERNOS_DIR/config/challenge.sh"

level_menu() {
    clear
    banner
    echo -e "  ${CYAN}${BOLD}LEVEL 4 — Networking Essentials${RESET}"
    echo -e "  ${DIM}Understand and control your network. Critical for DevOps.${RESET}"
    echo ""
    show_xp_bar
    divider
    echo ""

    local challenges=(
        "4.1" "Network interfaces     (ip addr, ip link)"       "c4_ip"
        "4.2" "Open ports & sockets   (ss, netstat)"            "c4_ss"
        "4.3" "Connectivity testing   (ping, curl, wget)"       "c4_ping"
        "4.4" "SSH deep dive          (ssh, scp, ssh-keygen)"   "c4_ssh"
        "4.5" "Firewall basics        (ufw)"                    "c4_ufw"
        "4.6" "BOSS — Network audit"                            "c4_boss"
    )

    for ((i=0; i<${#challenges[@]}; i+=3)); do
        local id="${challenges[$i]}"
        local title="${challenges[$((i+1))]}"
        local fn="${challenges[$((i+2))]}"
        if is_complete "level4_${fn}"; then
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
        1|4.1) c4_ip   ;;
        2|4.2) c4_ss   ;;
        3|4.3) c4_ping ;;
        4|4.4) c4_ssh  ;;
        5|4.5) c4_ufw  ;;
        6|4.6) c4_boss ;;
        "")    return   ;;
        *)     level_menu ;;
    esac
}

c4_ip() {
    clear
    echo -e "\n  ${BOLD}Challenge 4.1 — Network Interfaces${RESET}\n"

    teach "ip" \
        "ip is the modern replacement for ifconfig.\nIt manages network interfaces, routes, and addresses.\nip -br addr show gives a clean summary." \
        "ip -br addr show" \
        "lo     UNKNOWN  127.0.0.1/8
eth0   UP       192.168.1.105/24
wlan0  DOWN"

    echo -e "  ${BOLD}Key commands:${RESET}"
    echo -e "  ${CYAN}ip addr show${RESET}         — all interfaces and IPs"
    echo -e "  ${CYAN}ip -br addr show${RESET}     — brief, clean output"
    echo -e "  ${CYAN}ip link show${RESET}         — interface state (UP/DOWN)"
    echo -e "  ${CYAN}ip route show${RESET}        — routing table + default gateway"
    echo -e "  ${CYAN}hostname -I${RESET}          — just your IP addresses"
    echo -e "  ${CYAN}cat /etc/resolv.conf${RESET} — DNS servers"
    echo ""
    echo -e "  ${BOLD}Understanding the output:${RESET}"
    echo -e "  ${DIM}lo${RESET}    = loopback (127.0.0.1) — your machine to itself"
    echo -e "  ${DIM}eth0${RESET}  = wired ethernet"
    echo -e "  ${DIM}wlan0${RESET} = wireless"
    echo -e "  ${DIM}/24${RESET}   = subnet mask — 24 bits = 255.255.255.0"
    echo ""

    challenge_prompt "Understand your network interfaces" \
        "Run:\n  1. ip -br addr show\n  2. ip route show\n  3. cat /etc/resolv.conf\n\n  Answer the questions below." \
        "Your default gateway (ip route show) is the door to the internet"

    local real_ip; real_ip=$(hostname -I | awk '{print $1}')
    echo -ne "  ${DIM}What is your primary IP address? (run: hostname -I) ${RESET}"
    read -r answer

    if [[ "$answer" == "$real_ip" ]] || echo "$answer" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
        is_complete "level4_c4_ip" && { already_done; level_menu; return; }
        mark_complete "level4_c4_ip"
        challenge_pass 30 "You understand network interfaces!"
    else
        challenge_fail "Run: hostname -I — paste the IP address."
    fi

    pause
    level_menu
}

c4_ss() {
    clear
    echo -e "\n  ${BOLD}Challenge 4.2 — Open Ports & Sockets${RESET}\n"

    teach "ss" \
        "ss shows socket statistics — what's listening, what's connected.\nIt replaced netstat. Knowing open ports is critical for security.\nEvery open port is a potential entry point." \
        "ss -tulnp | grep LISTEN" \
        "tcp  LISTEN  0  128  0.0.0.0:22   0.0.0.0:*  users:((\"sshd\",pid=892))"

    echo -e "  ${BOLD}Flags explained:${RESET}"
    echo -e "  ${CYAN}-t${RESET} TCP    ${CYAN}-u${RESET} UDP    ${CYAN}-l${RESET} listening"
    echo -e "  ${CYAN}-n${RESET} numeric (no DNS lookup)    ${CYAN}-p${RESET} show process"
    echo ""
    echo -e "  ${BOLD}Common uses:${RESET}"
    echo -e "  ${CYAN}ss -tulnp${RESET}              — all listening ports + processes"
    echo -e "  ${CYAN}ss -tnp | grep ESTAB${RESET}   — active connections"
    echo -e "  ${CYAN}ss -tnp | grep :443${RESET}    — connections to HTTPS port"
    echo -e "  ${CYAN}ss -s${RESET}                  — summary statistics"
    echo ""

    challenge_prompt "Audit open ports" \
        "Run:\n  1. ss -tulnp\n     (see all listening ports)\n\n  2. ss -tulnp | grep :22\n     (is SSH open?)\n\n  3. ss -tnp | grep ESTAB | wc -l\n     (how many active connections?)\n\n  Come back with the count of open TCP ports." \
        "Any port you don't recognise is worth investigating."

    local port_count; port_count=$(ss -tln | grep LISTEN | wc -l)
    echo -ne "  ${DIM}How many TCP ports are in LISTEN state? (run: ss -tln | grep LISTEN | wc -l) ${RESET}"
    read -r answer

    if [[ "$answer" == "$port_count" ]]; then
        is_complete "level4_c4_ss" && { already_done; level_menu; return; }
        mark_complete "level4_c4_ss"
        challenge_pass 35 "You can audit every open door on this machine!"
        echo -e "  ${DIM}Security rule: if you don't know why a port is open, find out.\n  Every unknown open port is a risk.${RESET}"
    else
        challenge_fail "Run: ss -tln | grep LISTEN | wc -l — paste that number."
    fi

    pause
    level_menu
}

c4_ping() {
    clear
    echo -e "\n  ${BOLD}Challenge 4.3 — Connectivity Testing${RESET}\n"

    teach "ping / curl" \
        "ping tests if a host is reachable at the network level.\ncurl transfers data — great for testing HTTP APIs and services.\nThese are your first tools when 'the internet is broken'." \
        "curl -I https://google.com" \
        "HTTP/2 200
content-type: text/html
server: gws"

    echo -e "  ${BOLD}Connectivity toolkit:${RESET}"
    echo -e "  ${CYAN}ping -c 4 8.8.8.8${RESET}          — ping Google DNS 4 times"
    echo -e "  ${CYAN}ping -c 4 google.com${RESET}       — tests DNS + connectivity"
    echo -e "  ${CYAN}curl -I https://google.com${RESET} — HTTP headers only (-I)"
    echo -e "  ${CYAN}curl -s https://api.ipify.org${RESET}— get your public IP"
    echo -e "  ${CYAN}curl -o file.txt https://...${RESET}— download to file"
    echo -e "  ${CYAN}wget https://...${RESET}            — download file"
    echo -e "  ${CYAN}traceroute google.com${RESET}       — see the network path"
    echo -e "  ${CYAN}nslookup google.com${RESET}         — DNS lookup"
    echo ""

    challenge_prompt "Test connectivity" \
        "Run:\n  1. ping -c 4 8.8.8.8\n     (test basic internet connectivity)\n\n  2. ping -c 2 google.com\n     (test DNS resolution + connectivity)\n\n  3. curl -s https://api.ipify.org\n     (what is your public IP?)\n\n  4. curl -I https://google.com 2>/dev/null | head -5\n     (check HTTP headers)" \
        "If ping 8.8.8.8 works but ping google.com fails → DNS problem"

    echo -ne "  ${DIM}What is your public IP? (run: curl -s https://api.ipify.org) ${RESET}"
    read -r answer

    if echo "$answer" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
        is_complete "level4_c4_ping" && { already_done; level_menu; return; }
        mark_complete "level4_c4_ping"
        challenge_pass 30 "You can test any network connection from the command line!"
        echo -e "  ${DIM}curl is a Swiss army knife. curl -s URL | jq is how engineers\n  test REST APIs. curl -v shows full request/response headers.${RESET}"
    else
        challenge_fail "Run: curl -s https://api.ipify.org — it returns your public IP."
    fi

    pause
    level_menu
}

c4_ssh() {
    clear
    echo -e "\n  ${BOLD}Challenge 4.4 — SSH Deep Dive${RESET}\n"

    teach "ssh / ssh-keygen" \
        "SSH = Secure Shell. It's how you connect to remote servers.\nSSH keys are safer than passwords — nearly impossible to brute-force.\nEvery DevOps engineer lives in SSH." \
        "ssh user@192.168.1.100" \
        "(connects to server at 192.168.1.100 as 'user')"

    echo -e "  ${BOLD}SSH essentials:${RESET}"
    echo -e "  ${CYAN}ssh user@host${RESET}                 — connect to remote server"
    echo -e "  ${CYAN}ssh -p 2222 user@host${RESET}         — connect on non-default port"
    echo -e "  ${CYAN}ssh -i ~/.ssh/mykey user@host${RESET} — use specific key"
    echo -e "  ${CYAN}ssh-keygen -t ed25519${RESET}         — generate new SSH key pair"
    echo -e "  ${CYAN}ssh-copy-id user@host${RESET}         — copy your key to server"
    echo -e "  ${CYAN}scp file.txt user@host:~/${RESET}     — copy file to remote"
    echo -e "  ${CYAN}scp user@host:~/file.txt .${RESET}    — copy file from remote"
    echo ""
    echo -e "  ${BOLD}SSH keys live in:${RESET}"
    echo -e "  ${CYAN}~/.ssh/id_ed25519${RESET}    — private key (NEVER share this)"
    echo -e "  ${CYAN}~/.ssh/id_ed25519.pub${RESET}— public key (safe to share)"
    echo -e "  ${CYAN}~/.ssh/authorized_keys${RESET}— keys allowed to log in"
    echo ""

    challenge_prompt "Generate an SSH key pair" \
        "Generate a new SSH key:\n\n  ssh-keygen -t ed25519 -C 'kernos-learning' -f ~/.ssh/kernos_key\n\n  (press Enter twice to skip passphrase for now)\n\n  Then:\n  ls -la ~/.ssh/\n  cat ~/.ssh/kernos_key.pub\n\n  Your public key is what you put on servers you want to access." \
        "ed25519 is modern and secure. RSA 4096 is also fine but older."

    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    if [[ -f "$HOME/.ssh/kernos_key" ]] && [[ -f "$HOME/.ssh/kernos_key.pub" ]]; then
        is_complete "level4_c4_ssh" && { already_done; level_menu; return; }
        mark_complete "level4_c4_ssh"
        challenge_pass 40 "You have SSH keys — the passport of every DevOps engineer!"
        echo -e "  ${DIM}Never share your private key (~/.ssh/kernos_key).\n  chmod 600 ~/.ssh/kernos_key — SSH refuses to use keys that are too open.${RESET}"
    else
        challenge_fail "Generate the key: ssh-keygen -t ed25519 -C 'kernos-learning' -f ~/.ssh/kernos_key"
    fi

    pause
    level_menu
}

c4_ufw() {
    clear
    echo -e "\n  ${BOLD}Challenge 4.5 — Firewall Basics${RESET}\n"

    teach "ufw" \
        "UFW = Uncomplicated Firewall. It manages iptables rules simply.\nA firewall controls what network traffic is allowed in and out.\nEvery internet-facing server MUST have a firewall." \
        "sudo ufw status verbose" \
        "Status: active
To         Action  From
--         ------  ----
22/tcp     ALLOW   Anywhere
80/tcp     ALLOW   Anywhere
443/tcp    ALLOW   Anywhere"

    echo -e "  ${BOLD}Core UFW commands:${RESET}"
    echo -e "  ${CYAN}sudo ufw status${RESET}              — is it on? what rules?"
    echo -e "  ${CYAN}sudo ufw enable${RESET}              — turn it on"
    echo -e "  ${CYAN}sudo ufw disable${RESET}             — turn it off"
    echo -e "  ${CYAN}sudo ufw allow 22/tcp${RESET}        — allow SSH"
    echo -e "  ${CYAN}sudo ufw allow 80/tcp${RESET}        — allow HTTP"
    echo -e "  ${CYAN}sudo ufw deny 23/tcp${RESET}         — block telnet"
    echo -e "  ${CYAN}sudo ufw delete allow 80/tcp${RESET} — remove a rule"
    echo -e "  ${CYAN}sudo ufw allow from 192.168.1.0/24${RESET} — allow local network"
    echo ""
    echo -e "  ${RED}${BOLD}⚠  Always allow SSH (port 22) BEFORE enabling UFW on a remote server.${RESET}"
    echo -e "  ${DIM}Locking yourself out of a remote server is a real and painful mistake.${RESET}\n"

    challenge_prompt "Check firewall status" \
        "Run:\n  1. sudo ufw status verbose\n     (or: sudo ufw status if verbose doesn't work)\n\n  2. sudo ufw status numbered\n     (see rules with numbers — useful for deleting)\n\n  Answer the question below." \
        "If UFW is inactive: sudo ufw allow ssh && sudo ufw enable"

    echo -ne "  ${DIM}Is UFW active on this machine? (yes/no/not installed): ${RESET}"
    read -r answer

    if echo "$answer" | grep -qiE 'yes|no|not|install'; then
        is_complete "level4_c4_ufw" && { already_done; level_menu; return; }
        mark_complete "level4_c4_ufw"
        challenge_pass 35 "You understand firewall fundamentals!"
        echo -e "  ${DIM}Rule of thumb for any server:\n  sudo ufw default deny incoming\n  sudo ufw default allow outgoing\n  sudo ufw allow ssh\n  sudo ufw enable${RESET}"
    else
        challenge_fail "Answer yes, no, or 'not installed'. Run: sudo ufw status"
    fi

    pause
    level_menu
}

c4_boss() {
    clear
    echo -e "\n  ${YELLOW}${BOLD}★ BOSS CHALLENGE — Level 4: Network Audit ★${RESET}\n"
    echo -e "  ${DIM}Security team asked you to audit the network exposure of this server.\n  Answer 5 questions using what you've learned.${RESET}\n"
    divider

    local score=0

    echo -e "  ${BOLD}Running network audit...${RESET}\n"
    press_any

    local port_count; port_count=$(ss -tln | grep LISTEN | wc -l)
    echo -ne "  ${DIM}Q1 — How many TCP ports are listening? ${RESET}"
    read -r q1
    [[ "$q1" == "$port_count" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected $port_count — run: ss -tln | grep LISTEN | wc -l"

    local my_ip; my_ip=$(hostname -I | awk '{print $1}')
    echo -ne "  ${DIM}Q2 — What is this machine's primary IP? ${RESET}"
    read -r q2
    [[ "$q2" == "$my_ip" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected $my_ip — run: hostname -I"

    echo -ne "  ${DIM}Q3 — Is there an SSH key in ~/.ssh/? (yes/no) ${RESET}"
    read -r q3
    has_key=false
    [[ -d "$HOME/.ssh" ]] && ls "$HOME/.ssh"/*.pub &>/dev/null && has_key=true
    if $has_key && echo "$q3" | grep -qi yes; then
        ok "Correct!"; (( score++ ))
    elif ! $has_key && echo "$q3" | grep -qi no; then
        ok "Correct!"; (( score++ ))
    else
        fail "Check: ls ~/.ssh/*.pub"
    fi

    local conns; conns=$(ss -tn | grep -c ESTAB || echo 0)
    echo -ne "  ${DIM}Q4 — How many established TCP connections? ${RESET}"
    read -r q4
    [[ "$q4" == "$conns" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected $conns — run: ss -tn | grep ESTAB | wc -l"

    local gw; gw=$(ip route | grep default | awk '{print $3}')
    echo -ne "  ${DIM}Q5 — What is the default gateway IP? ${RESET}"
    read -r q5
    [[ "$q5" == "$gw" ]] && { ok "Correct!"; (( score++ )); } || fail "Expected $gw — run: ip route show"

    echo ""
    echo -e "  ${BOLD}Score: ${score}/5${RESET}"

    if [[ $score -ge 4 ]]; then
        is_complete "level4_c4_boss" && { already_done; level_menu; return; }
        mark_complete "level4_c4_boss"
        challenge_pass 60 "LEVEL 4 BOSS DEFEATED — Network Audit Complete!"
        echo ""
        echo -e "  ${CYAN}${BOLD}You can audit any server's network exposure.${RESET}"
        echo -e "  ${DIM}Next level: Bash scripting — automate everything you just learned.${RESET}"
    else
        warn "$score/5. Try again when ready."
    fi

    pause
    level_menu
}

level_menu
