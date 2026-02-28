#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos disk
#  Storage usage, large files, inode health
# ─────────────────────────────────────────────

echo -e "\n  ${BOLD}Disk${RESET}"
divider

section "Filesystem Usage"
echo ""

df -hT | grep -v tmpfs | grep -v udev | grep -v loop | awk '
NR==1 {
    printf "  \033[1m%-20s %-8s %-6s %-6s %-6s %s\033[0m\n", $1, $2, $3, $4, $5, $7
    next
}
{
    pct=$6+0
    color="\033[0;32m"
    if (pct>=88) color="\033[0;31m"
    else if (pct>=70) color="\033[1;33m"
    printf "  " color "%-20s %-8s %-6s %-6s %-6s %s\033[0m\n", $1, $2, $3, $4, $5, $7
}'

echo ""
learn "df -hT shows disk usage per filesystem. The -h flag makes sizes human-readable,
       -T shows the filesystem type. tmpfs and devtmpfs are virtual — they live in RAM,
       not on actual disk. Only the real ones matter here."

section "Inode Usage"
echo ""
df -i | grep -v tmpfs | grep -v udev | grep -v loop | awk '
NR==1 {
    printf "  \033[1m%-25s %-12s %-12s %s\033[0m\n", $1, "Inodes", "IUsed", "IUse%"
    next
}
NR>1 {
    pct=$5+0
    color="\033[0;32m"
    if (pct>=88) color="\033[0;31m"
    else if (pct>=70) color="\033[1;33m"
    printf "  " color "%-25s %-12s %-12s %s\033[0m\n", $1, $2, $3, $5
}'
echo ""

learn "Inodes are like ID cards for files. Every file needs one. You can run out of inodes
       before running out of disk space — especially if something creates millions of tiny
       files (log systems, mail queues, temp files). If inodes are 100%, you can't create
       new files even with space available. Sneaky and confusing."

section "Top 10 Largest Files"
info "Searching from / — this may take a moment..."
echo ""
find / -not \( -path '/proc/*' -o -path '/sys/*' -o -path '/dev/*' \) \
    -type f -exec du -h {} + 2>/dev/null \
    | sort -rh | head -10 \
    | awk '{printf "  \033[1m%-10s\033[0m  %s\n", $1, $2}'
echo ""

learn "du = disk usage. The find + du combo here checks every real file on your system.
       Useful for hunting down what's filling your disk when 'df' shows high usage
       but you can't figure out where the space went."

section "Recently Modified Large Files"
echo ""
find /var /tmp /home -type f -size +50M 2>/dev/null \
    | xargs ls -lh 2>/dev/null \
    | awk '{printf "  %-10s  %s\n", $5, $9}' \
    | sort -rh | head -8
echo ""
info "These are files over 50MB in common write locations — worth knowing about"
