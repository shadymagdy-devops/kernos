#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Kernos Progress Engine
#  Tracks XP, level, rank, streaks, completed
#  challenges. All stored in ~/.kernos/progress
# ─────────────────────────────────────────────

source "$(dirname "$0")/ui.sh"

KERNOS_HOME="$HOME/.kernos"
PROGRESS_FILE="$KERNOS_HOME/progress"
COMPLETED_FILE="$KERNOS_HOME/completed"
STREAK_FILE="$KERNOS_HOME/streak"

# ── Rank thresholds ─────────────────────────
# Format: "min_xp:rank_name:rank_color"
declare -a RANKS=(
    "0:NEWCOMER:${DIM}"
    "100:BEGINNER:${GREEN}"
    "300:EXPLORER:${CYAN}"
    "600:APPRENTICE:${BLUE}"
    "1000:PRACTITIONER:${YELLOW}"
    "1600:ADVANCED:${MAGENTA}"
    "2400:SYSADMIN:${RED}"
    "3500:DEVOPS ENGINEER:${CYAN}${BOLD}"
)

# ── Init user data ───────────────────────────
init_progress() {
    mkdir -p "$KERNOS_HOME"
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo "XP=0" > "$PROGRESS_FILE"
        echo "LEVEL=1" >> "$PROGRESS_FILE"
        echo "COMPLETED=0" >> "$PROGRESS_FILE"
        echo "NAME=" >> "$PROGRESS_FILE"
    fi
    [[ ! -f "$COMPLETED_FILE" ]] && touch "$COMPLETED_FILE"
    [[ ! -f "$STREAK_FILE" ]] && echo "0" > "$STREAK_FILE"
}

# ── Load progress ────────────────────────────
load_progress() {
    init_progress
    source "$PROGRESS_FILE"
}

# ── Save XP ──────────────────────────────────
save_xp() {
    echo "XP=$XP"          > "$PROGRESS_FILE"
    echo "LEVEL=$LEVEL"   >> "$PROGRESS_FILE"
    echo "COMPLETED=$COMPLETED" >> "$PROGRESS_FILE"
    echo "NAME=$NAME"     >> "$PROGRESS_FILE"
}

# ── Add XP and show gain ─────────────────────
add_xp() {
    local amount=$1
    local reason="${2:-challenge}"
    load_progress

    local old_rank
    old_rank=$(get_rank_name "$XP")

    XP=$(( XP + amount ))
    COMPLETED=$(( COMPLETED + 1 ))

    local new_rank
    new_rank=$(get_rank_name "$XP")

    save_xp

    echo ""
    echo -e "  ${YELLOW}${BOLD}+${amount} XP${RESET}  ${DIM}— ${reason}${RESET}"

    # Rank up?
    if [[ "$old_rank" != "$new_rank" ]]; then
        echo ""
        echo -e "  ${CYAN}${BOLD}★ RANK UP! ★${RESET}"
        echo -e "  ${BOLD}You are now: $(get_rank_display "$XP")${RESET}"
    fi

    show_xp_bar
}

# ── Mark challenge complete ──────────────────
mark_complete() {
    local challenge_id="$1"
    echo "$challenge_id" >> "$COMPLETED_FILE"
}

# ── Check if challenge done ──────────────────
is_complete() {
    local challenge_id="$1"
    grep -q "^${challenge_id}$" "$COMPLETED_FILE" 2>/dev/null
}

# ── Get rank name for XP ─────────────────────
get_rank_name() {
    local xp=$1
    local name="NEWCOMER"
    for entry in "${RANKS[@]}"; do
        local min; min=$(echo "$entry" | cut -d: -f1)
        local rank; rank=$(echo "$entry" | cut -d: -f2)
        [[ "$xp" -ge "$min" ]] && name="$rank"
    done
    echo "$name"
}

# ── Get colored rank display ─────────────────
get_rank_display() {
    local xp=$1
    local display="NEWCOMER"
    for entry in "${RANKS[@]}"; do
        local min; min=$(echo "$entry" | cut -d: -f1)
        local rank; rank=$(echo "$entry" | cut -d: -f2)
        local color; color=$(echo "$entry" | cut -d: -f3-)
        [[ "$xp" -ge "$min" ]] && display="${color}${BOLD}[ ${rank} ]${RESET}"
    done
    echo -e "$display"
}

# ── Next rank info ───────────────────────────
get_next_rank() {
    local xp=$1
    local next_min=9999
    local next_name="MAX RANK"
    for entry in "${RANKS[@]}"; do
        local min; min=$(echo "$entry" | cut -d: -f1)
        local rank; rank=$(echo "$entry" | cut -d: -f2)
        if [[ "$min" -gt "$xp" && "$min" -lt "$next_min" ]]; then
            next_min=$min
            next_name=$rank
        fi
    done
    echo "${next_min}:${next_name}"
}

# ── Show XP bar ──────────────────────────────
show_xp_bar() {
    load_progress
    local rank_name; rank_name=$(get_rank_name "$XP")
    local next; next=$(get_next_rank "$XP")
    local next_min; next_min=$(echo "$next" | cut -d: -f1)
    local next_name; next_name=$(echo "$next" | cut -d: -f2)

    # Find current rank min
    local cur_min=0
    for entry in "${RANKS[@]}"; do
        local min; min=$(echo "$entry" | cut -d: -f1)
        local rank; rank=$(echo "$entry" | cut -d: -f2)
        [[ "$rank" == "$rank_name" ]] && cur_min=$min
    done

    local range=$(( next_min - cur_min ))
    local progress=$(( XP - cur_min ))
    [[ $next_min -eq 9999 ]] && range=100 && progress=100

    echo ""
    echo -e "  $(get_rank_display "$XP")"
    xp_bar "$progress" "$range"
    echo -e "  ${DIM}Total XP: ${BOLD}${XP}${RESET}${DIM} — Challenges done: ${BOLD}${COMPLETED}${RESET}${DIM} — Next: ${next_name} at ${next_min} XP${RESET}"
    echo ""
}

# ── Full profile ─────────────────────────────
show_profile() {
    load_progress
    section "Your Profile"

    local display_name="${NAME:-Anonymous Learner}"
    info "Name:       ${BOLD}${display_name}${RESET}"
    info "Rank:       $(get_rank_display "$XP")"
    info "Total XP:   ${BOLD}${XP}${RESET}"
    info "Challenges: ${BOLD}${COMPLETED}${RESET} completed"

    echo ""
    local next; next=$(get_next_rank "$XP")
    local next_min; next_min=$(echo "$next" | cut -d: -f1)
    local next_name; next_name=$(echo "$next" | cut -d: -f2)
    local needed=$(( next_min - XP ))
    [[ $next_min -eq 9999 ]] && info "You've reached the highest rank!" \
                              || info "You need ${BOLD}${needed} more XP${RESET} to reach ${BOLD}${next_name}${RESET}"

    show_xp_bar

    section "Rank Roadmap"
    for entry in "${RANKS[@]}"; do
        local min; min=$(echo "$entry" | cut -d: -f1)
        local rank; rank=$(echo "$entry" | cut -d: -f2)
        local color; color=$(echo "$entry" | cut -d: -f3-)
        if [[ "$XP" -ge "$min" ]]; then
            echo -e "  ${GREEN}✔${RESET}  ${color}${rank}${RESET}  ${DIM}(${min} XP)${RESET}"
        else
            echo -e "  ${DIM}○  ${rank}  (${min} XP)${RESET}"
        fi
    done
    echo ""
}
