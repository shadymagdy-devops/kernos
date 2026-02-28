#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Kernos Installer
#  Run: bash install.sh
# ─────────────────────────────────────────────

GREEN='\033[0;32m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RED='\033[0;31m'; RESET='\033[0m'

KERNOS_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin/kernos"

echo -e "\n  ${CYAN}${BOLD}Installing Kernos...${RESET}\n"

# Make all scripts executable
find "$KERNOS_DIR" -name "*.sh" -exec chmod +x {} \;
echo -e "  ${GREEN}✔${RESET}  Scripts made executable"

# Create bin dir and symlink
mkdir -p "$HOME/.local/bin"
ln -sf "$KERNOS_DIR/kernos.sh" "$BIN"
echo -e "  ${GREEN}✔${RESET}  Symlink: $BIN"

# Add to PATH if needed
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo -e "  ${GREEN}✔${RESET}  Added ~/.local/bin to PATH in .bashrc"
    echo -e "  ${CYAN}→${RESET}  Run: source ~/.bashrc  (or restart terminal)"
fi

# Init data dir
mkdir -p "$HOME/.kernos"
echo -e "  ${GREEN}✔${RESET}  Data directory: ~/.kernos"

echo ""
echo -e "  ${BOLD}${GREEN}Done!${RESET}  Run: ${CYAN}${BOLD}kernos${RESET}"
echo -e "  ${DIM}(you may need to run: source ~/.bashrc first)${RESET}\n"
