#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Shared colors, helpers, and output functions
#  used by every Kernos script
# ─────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

export RED GREEN YELLOW CYAN BLUE MAGENTA BOLD DIM RESET

# ── Output helpers ──────────────────────────

section() {
    echo -e "\n  ${CYAN}${BOLD}── $1 ${DIM}$(printf '─%.0s' $(seq 1 $((40 - ${#1}))))${RESET}\n"
}

ok()    { echo -e "  ${GREEN}✔${RESET}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
fail()  { echo -e "  ${RED}✘${RESET}  $1"; }
info()  { echo -e "  ${CYAN}→${RESET}  $1"; }
label() { echo -e "  ${BOLD}$1${RESET}"; }

# Show inline learning note (only if --learn was passed)
learn() {
    [[ "$LEARN" == "yes" ]] && echo -e "  ${DIM}${BLUE}💡 $1${RESET}"
}

# ── Visual bar ──────────────────────────────
# Usage: bar <percent> [width]
bar() {
    local pct=$1
    local width=${2:-28}
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

# ── Divider ─────────────────────────────────
divider() {
    echo -e "  ${DIM}$(printf '─%.0s' $(seq 1 50))${RESET}"
}
