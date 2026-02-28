#!/usr/bin/env bash
# ═══════════════════════════════════════════════
#  KERNOS — Your Linux Learning Companion
#  From zero to DevOps Engineer. One challenge at a time.
#
#  github.com/shadymagdy-devops/kernos
# ═══════════════════════════════════════════════

KERNOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$KERNOS_DIR/config/ui.sh"
source "$KERNOS_DIR/config/progress.sh"

init_progress

# ── First time setup ────────────────────────
first_time_setup() {
    load_progress
    if [[ -z "$NAME" ]]; then
        clear
        banner
        echo -e "  ${BOLD}Welcome to Kernos.${RESET}"
        echo -e "  ${DIM}The Linux learning companion that makes you do the real thing.${RESET}\n"
        typewrite "  What's your name? " 0.04
        echo -ne "  ${CYAN}→ ${RESET}"
        read -r input_name
        NAME="${input_name:-Learner}"
        save_xp
        echo ""
        echo -e "  ${GREEN}${BOLD}Nice to meet you, $NAME.${RESET}"
        echo -e "  ${DIM}You're starting from zero. That's the right place to start.\n  Every expert was once exactly where you are now.${RESET}"
        pause
    fi
}

# ── Main menu ───────────────────────────────
main_menu() {
    clear
    banner

    load_progress

    echo -e "  ${BOLD}Hello, ${NAME:-Learner}${RESET}  —  $(get_rank_display "$XP")"
    show_xp_bar

    divider
    echo ""
    echo -e "  ${CYAN}${BOLD}LEARNING PATH${RESET}"
    echo ""

    # Levels with unlock logic
    local levels=(
        "1" "Finding Your Way Around"   "pwd ls cd mkdir touch rm"        0
        "2" "Reading, Writing, Perms"   "cat grep chmod pipes redirects"   100
        "3" "Processes & System"        "ps top kill systemctl df free"    300
        "4" "Networking Essentials"     "ip ss ping ssh curl ufw"          600
        "5" "Bash Scripting"            "variables loops functions scripts" 1000
    )

    for ((i=0; i<${#levels[@]}; i+=4)); do
        local num="${levels[$i]}"
        local title="${levels[$((i+1))]}"
        local cmds="${levels[$((i+2))]}"
        local req="${levels[$((i+3))]}"

        if [[ "$XP" -ge "$req" ]]; then
            # Count completed challenges for this level
            local done; done=$(grep -c "^level${num}_" "$COMPLETED_FILE" 2>/dev/null || echo 0)
            if [[ "$done" -ge 6 ]]; then
                echo -e "  ${GREEN}✔${RESET}  ${BOLD}Level $num${RESET} — $title  ${DIM}[$done challenges done]${RESET}"
            else
                echo -e "  ${CYAN}▶${RESET}  ${BOLD}Level $num${RESET} — $title"
                echo -e "     ${DIM}Commands: $cmds${RESET}"
            fi
        else
            local needed=$(( req - XP ))
            echo -e "  ${DIM}🔒 Level $num — $title${RESET}"
            echo -e "     ${DIM}Unlocks at $req XP (need $needed more)${RESET}"
        fi
        echo ""
    done

    echo -e "  ${DIM}○${RESET}  ${BOLD}Level 6+${RESET} — ${DIM}Coming: Advanced Bash, Docker, CI/CD, Ansible...${RESET}\n"

    divider
    echo ""
    echo -e "  ${CYAN}f${RESET}  Free Mode — Explore any topic (no XP required)"
    echo -e "  ${CYAN}p${RESET}  Your Profile & Rank Roadmap"
    echo -e "  ${CYAN}q${RESET}  Quit"
    echo ""
    echo -ne "  ${DIM}Choose a level (1-5), f, p, or q: ${RESET}"
    read -r choice

    case "$choice" in
        1) bash "$KERNOS_DIR/levels/level1.sh" ;;
        2)
            if [[ "$XP" -ge 100 ]]; then
                bash "$KERNOS_DIR/levels/level2.sh"
            else
                warn "Level 2 unlocks at 100 XP. You have ${XP} XP."
                echo -e "  ${DIM}Complete Level 1 challenges to earn more XP.${RESET}"
                pause
            fi
            ;;
        3)
            if [[ "$XP" -ge 300 ]]; then
                bash "$KERNOS_DIR/levels/level3.sh"
            else
                warn "Level 3 unlocks at 300 XP. You have ${XP} XP."
                pause
            fi
            ;;
        4)
            if [[ "$XP" -ge 600 ]]; then
                bash "$KERNOS_DIR/levels/level4.sh"
            else
                warn "Level 4 unlocks at 600 XP. You have ${XP} XP."
                pause
            fi
            ;;
        5)
            if [[ "$XP" -ge 1000 ]]; then
                bash "$KERNOS_DIR/levels/level5.sh"
            else
                warn "Level 5 unlocks at 1000 XP. You have ${XP} XP."
                pause
            fi
            ;;
        f|F) bash "$KERNOS_DIR/free/explore.sh" ;;
        p|P) show_profile; pause ;;
        q|Q)
            echo ""
            echo -e "  ${DIM}See you next time, ${NAME}. Keep practicing.${RESET}"
            echo ""
            exit 0
            ;;
        *)   main_menu ;;
    esac

    main_menu
}

# ── Entry ───────────────────────────────────
first_time_setup
main_menu
