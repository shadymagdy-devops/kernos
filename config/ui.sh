#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Kernos UI — colors, helpers, progress bars
# ─────────────────────────────────────────────

RED='\033[0;31m';    GREEN='\033[0;32m';   YELLOW='\033[1;33m'
CYAN='\033[0;36m';   BLUE='\033[0;34m';    MAGENTA='\033[0;35m'
BOLD='\033[1m';      DIM='\033[2m';         RESET='\033[0m'
ITALIC='\033[3m';    UNDERLINE='\033[4m'

export RED GREEN YELLOW CYAN BLUE MAGENTA BOLD DIM RESET ITALIC UNDERLINE

# ── Basic output ────────────────────────────
ok()      { echo -e "  ${GREEN}✔${RESET}  $1"; }
fail()    { echo -e "  ${RED}✘${RESET}  $1"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
info()    { echo -e "  ${CYAN}→${RESET}  $1"; }
label()   { echo -e "\n  ${BOLD}$1${RESET}"; }
dim()     { echo -e "  ${DIM}$1${RESET}"; }
blank()   { echo ""; }

divider() {
    echo -e "  ${DIM}$(printf '─%.0s' $(seq 1 52))${RESET}"
}

section() {
    echo -e "\n  ${CYAN}${BOLD}── $1 ${RESET}${DIM}$(printf '─%.0s' $(seq 1 $((44 - ${#1}))))${RESET}\n"
}

# ── XP progress bar ─────────────────────────
xp_bar() {
    local current=$1
    local max=$2
    local width=30
    local filled=$(( current * width / max ))
    local empty=$(( width - filled ))
    [[ $filled -gt $width ]] && filled=$width && empty=0

    printf "  ${CYAN}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty;  i++)); do printf "░"; done
    printf "]${RESET} ${BOLD}%d${RESET}${DIM}/%d XP${RESET}\n" "$current" "$max"
}

# ── Generic bar ─────────────────────────────
bar() {
    local pct=$1 width=${2:-28}
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local color=$GREEN
    (( pct >= 80 )) && color=$RED
    (( pct >= 60 && pct < 80 )) && color=$YELLOW
    printf "  ${color}["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty;  i++)); do printf "░"; done
    printf "] ${BOLD}%3d%%${RESET}\n" "$pct"
}

# ── Big banner ──────────────────────────────
banner() {
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
    ██╗  ██╗███████╗██████╗ ███╗   ██╗ ██████╗ ███████╗
    ██║ ██╔╝██╔════╝██╔══██╗████╗  ██║██╔═══██╗██╔════╝
    █████╔╝ █████╗  ██████╔╝██╔██╗ ██║██║   ██║███████╗
    ██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╗██║██║   ██║╚════██║
    ██║  ██╗███████╗██║  ██║██║ ╚████║╚██████╔╝███████║
    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
EOF
    echo -e "${RESET}"
    echo -e "    ${DIM}Your Linux Learning Companion — from zero to DevOps${RESET}\n"
}

# ── Typewriter effect ───────────────────────
typewrite() {
    local text="$1"
    local delay="${2:-0.03}"
    local i
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# ── Pause ────────────────────────────────────
pause() {
    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${RESET}"
    read -r
}

press_any() {
    echo -ne "  ${DIM}Press Enter when ready...${RESET}"
    read -r
    echo ""
}
