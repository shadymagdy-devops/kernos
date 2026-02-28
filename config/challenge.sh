#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Kernos Challenge Engine
#
#  Each challenge:
#  1. Explains the concept
#  2. Shows the command with examples
#  3. Gives a real task to complete
#  4. Verifies the user actually did it
#  5. Awards XP on success
# ─────────────────────────────────────────────

source "$(dirname "$0")/ui.sh"
source "$(dirname "$0")/progress.sh"

SANDBOX="$HOME/.kernos/sandbox"

# ── Setup sandbox directory ──────────────────
setup_sandbox() {
    mkdir -p "$SANDBOX"
}

# ── Teach phase ──────────────────────────────
# Shows concept + command before the challenge
teach() {
    local cmd="$1"
    local concept="$2"
    local example="$3"
    local example_out="$4"

    echo ""
    echo -e "  ${CYAN}${BOLD}The Command:  $cmd${RESET}"
    divider
    echo ""
    echo -e "  ${BOLD}What it does:${RESET}"
    echo -e "  $concept"
    echo ""
    echo -e "  ${BOLD}Example:${RESET}"
    echo -e "  ${GREEN}\$${RESET} ${BOLD}$example${RESET}"
    if [[ -n "$example_out" ]]; then
        echo ""
        echo -e "$example_out" | while IFS= read -r line; do
            echo -e "  ${DIM}$line${RESET}"
        done
    fi
    echo ""
    divider
}

# ── Challenge phase ──────────────────────────
# Presents the task clearly
challenge_prompt() {
    local title="$1"
    local task="$2"
    local hint="$3"

    echo ""
    echo -e "  ${YELLOW}${BOLD}⚡ CHALLENGE: $title${RESET}"
    echo ""
    echo -e "  ${BOLD}Your task:${RESET}"
    echo -e "  $task"
    echo ""
    if [[ -n "$hint" ]]; then
        echo -e "  ${DIM}Hint: $hint${RESET}"
        echo ""
    fi
    echo -e "  ${DIM}Open a terminal, complete the task, then come back here.${RESET}"
    press_any
}

# ── Verify phase ─────────────────────────────
# Returns 0 if passed, 1 if failed
verify_file_exists() {
    local path="$1"
    local label="${2:-file}"
    if [[ -e "$path" ]]; then
        ok "$label exists — ${BOLD}$path${RESET}"
        return 0
    else
        fail "$label not found — expected: ${BOLD}$path${RESET}"
        return 1
    fi
}

verify_dir_exists() {
    local path="$1"
    local label="${2:-directory}"
    if [[ -d "$path" ]]; then
        ok "$label exists — ${BOLD}$path${RESET}"
        return 0
    else
        fail "$label not found — expected: ${BOLD}$path${RESET}"
        return 1
    fi
}

verify_file_contains() {
    local path="$1"
    local text="$2"
    if grep -q "$text" "$path" 2>/dev/null; then
        ok "File contains expected text"
        return 0
    else
        fail "File doesn't contain: '$text'"
        return 1
    fi
}

verify_file_not_exists() {
    local path="$1"
    if [[ ! -e "$path" ]]; then
        ok "File correctly removed"
        return 0
    else
        fail "File still exists: $path"
        return 1
    fi
}

verify_symlink() {
    local path="$1"
    if [[ -L "$path" ]]; then
        ok "Symlink exists — $path"
        return 0
    else
        fail "No symlink found at: $path"
        return 1
    fi
}

verify_permission() {
    local path="$1"
    local expected="$2"
    local actual
    actual=$(stat -c "%a" "$path" 2>/dev/null)
    if [[ "$actual" == "$expected" ]]; then
        ok "Permissions correct: $expected"
        return 0
    else
        fail "Expected permissions $expected but got $actual"
        return 1
    fi
}

verify_process_running() {
    local name="$1"
    if pgrep -x "$name" > /dev/null 2>&1; then
        ok "Process '$name' is running"
        return 0
    else
        fail "Process '$name' not found"
        return 1
    fi
}

verify_var_in_file() {
    local file="$1"
    local pattern="$2"
    if grep -qE "$pattern" "$file" 2>/dev/null; then
        ok "Pattern found in file"
        return 0
    else
        fail "Pattern not found: $pattern"
        return 1
    fi
}

# ── Challenge result ─────────────────────────
challenge_pass() {
    local xp=$1
    local msg="${2:-Challenge complete!}"
    echo ""
    echo -e "  ${GREEN}${BOLD}★ $msg${RESET}"
    add_xp "$xp" "challenge completed"
}

challenge_fail() {
    local msg="${1:-Not quite right. Check the hint and try again.}"
    echo ""
    fail "$msg"
    echo -e "  ${DIM}Run the challenge again when you're ready.${RESET}"
    echo ""
}

# ── Try again loop ───────────────────────────
retry_prompt() {
    echo ""
    echo -ne "  ${DIM}Try again? (y/n): ${RESET}"
    read -r ans
    [[ "$ans" == "y" || "$ans" == "Y" ]]
}

# ── Show completed badge ─────────────────────
already_done() {
    echo ""
    ok "You already completed this challenge!"
    dim "You can redo it anytime but XP is only awarded once."
    echo ""
}
