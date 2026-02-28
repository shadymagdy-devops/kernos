#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos backup <source> [destination]
#  Backup a directory safely with timestamps
# ─────────────────────────────────────────────

SRC="$1"
DEST="${2:-$BACKUP_DEST}"

if [[ -z "$SRC" ]]; then
    echo -e "\n  ${BOLD}Usage:${RESET} kernos backup <source_directory> [destination]\n"
    echo -e "  ${DIM}Examples:${RESET}"
    info "kernos backup /etc"
    info "kernos backup /home/user/projects /mnt/backup"
    echo ""
    exit 1
fi

[[ ! -e "$SRC" ]] && { fail "Source not found: $SRC"; exit 1; }

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BASENAME=$(basename "$SRC")
mkdir -p "$DEST"
ARCHIVE="${DEST}/${BASENAME}_${TIMESTAMP}.tar.gz"

echo -e "\n  ${BOLD}Backup${RESET}"
divider
info "Source:      ${BOLD}$SRC${RESET}"
info "Destination: ${BOLD}$ARCHIVE${RESET}"
info "Started:     $(date '+%H:%M:%S')"
echo ""

learn "tar -czf creates a compressed archive. -c = create, -z = gzip compression,
       -f = filename. Gzip is fast and gives decent compression. For maximum
       compression use -cJf with xz, but it's much slower."

echo -ne "  ${DIM}Creating archive...${RESET}"

if tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$BASENAME" 2>/dev/null; then
    echo -e "\r  ${GREEN}✔${RESET} Archive created"
    size=$(du -sh "$ARCHIVE" | cut -f1)
    ok "Size: ${BOLD}${size}${RESET}"
    ok "Saved to: ${BOLD}${ARCHIVE}${RESET}"

    # Keep only last 5 backups of this source
    echo ""
    old_count=$(ls "${DEST}/${BASENAME}_"*.tar.gz 2>/dev/null | wc -l)
    if [[ "$old_count" -gt 5 ]]; then
        ls -t "${DEST}/${BASENAME}_"*.tar.gz | tail -n +6 | xargs rm -f
        info "Cleaned up old backups (keeping 5 most recent)"
    fi
else
    echo ""
    fail "Backup failed — check permissions on source and destination"
    exit 1
fi
echo ""
