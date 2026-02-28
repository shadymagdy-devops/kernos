#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  Kernos Free Mode
#  Explore any command or topic freely
#  No levels, no XP — just learn what you want
# ─────────────────────────────────────────────

KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$KERNOS_DIR/config/ui.sh"

free_menu() {
    clear
    banner
    echo -e "  ${CYAN}${BOLD}Free Mode — Explore Anything${RESET}"
    echo -e "  ${DIM}No structure. No XP. Just you and Linux.${RESET}\n"
    divider
    echo ""

    echo -e "  ${BOLD}Topics:${RESET}\n"
    echo -e "  ${CYAN}1${RESET}  Text processing     (awk, sed, cut, sort, uniq)"
    echo -e "  ${CYAN}2${RESET}  Disk & storage      (du, df, lsblk, mount)"
    echo -e "  ${CYAN}3${RESET}  Users & groups      (useradd, usermod, passwd, sudo)"
    echo -e "  ${CYAN}4${RESET}  Cron & scheduling   (crontab, at, systemd timers)"
    echo -e "  ${CYAN}5${RESET}  Git essentials      (init, add, commit, push, pull)"
    echo -e "  ${CYAN}6${RESET}  Docker basics       (run, ps, exec, logs, build)"
    echo -e "  ${CYAN}7${RESET}  Text editors        (vim, nano — survive in both)"
    echo -e "  ${CYAN}8${RESET}  Environment & PATH  (export, source, .bashrc, alias)"
    echo -e "  ${CYAN}9${RESET}  Archives & compress (tar, gzip, zip, unzip)"
    echo -e "  ${CYAN}10${RESET} System logs         (journalctl, dmesg, /var/log)"
    echo ""
    echo -e "  ${DIM}Enter a number or press Enter to go back: ${RESET}"
    read -r choice

    case "$choice" in
        1)  free_awk      ;;
        2)  free_disk     ;;
        3)  free_users    ;;
        4)  free_cron     ;;
        5)  free_git      ;;
        6)  free_docker   ;;
        7)  free_vim      ;;
        8)  free_env      ;;
        9)  free_tar      ;;
        10) free_logs     ;;
        "")  return       ;;
        *)   free_menu    ;;
    esac
}

# ── Text processing ──────────────────────────
free_awk() {
    clear
    section "awk, sed, cut, sort, uniq"
    echo -e "  The text processing Swiss army knife of Linux.\n"

    echo -e "  ${BOLD}awk — column-based processing:${RESET}"
    echo -e "  ${CYAN}awk '{print \$1}' file${RESET}          — print first column"
    echo -e "  ${CYAN}awk -F: '{print \$1}' /etc/passwd${RESET}— use : as delimiter"
    echo -e "  ${CYAN}awk '\$3 > 1000' /etc/passwd${RESET}    — filter by column value"
    echo -e "  ${CYAN}ps aux | awk '{sum+=\$3} END {print sum}'${RESET} — sum CPU%"
    echo ""

    echo -e "  ${BOLD}sed — stream editor (find & replace):${RESET}"
    echo -e "  ${CYAN}sed 's/old/new/' file${RESET}          — replace first match per line"
    echo -e "  ${CYAN}sed 's/old/new/g' file${RESET}         — replace all matches"
    echo -e "  ${CYAN}sed -i 's/old/new/g' file${RESET}      — edit file in place"
    echo -e "  ${CYAN}sed '/pattern/d' file${RESET}           — delete matching lines"
    echo ""

    echo -e "  ${BOLD}cut, sort, uniq — pipeline tools:${RESET}"
    echo -e "  ${CYAN}cut -d: -f1 /etc/passwd${RESET}        — cut field 1 (delimiter :)"
    echo -e "  ${CYAN}sort file.txt${RESET}                   — sort alphabetically"
    echo -e "  ${CYAN}sort -n numbers.txt${RESET}             — sort numerically"
    echo -e "  ${CYAN}sort -rn numbers.txt${RESET}            — reverse numeric sort"
    echo -e "  ${CYAN}sort | uniq${RESET}                     — remove duplicates"
    echo -e "  ${CYAN}sort | uniq -c${RESET}                  — count occurrences"
    echo ""

    echo -e "  ${BOLD}Try this right now:${RESET}"
    echo -e "  ${DIM}cat /etc/passwd | cut -d: -f1 | sort${RESET}"
    echo -e "  ${DIM}(prints all usernames, sorted)${RESET}"
    echo ""

    pause
    free_menu
}

# ── Cron ─────────────────────────────────────
free_cron() {
    clear
    section "Cron & Scheduling"
    echo -e "  Automate anything to run on a schedule.\n"

    echo -e "  ${BOLD}crontab — the classic scheduler:${RESET}"
    echo -e "  ${CYAN}crontab -e${RESET}      — edit your crontab"
    echo -e "  ${CYAN}crontab -l${RESET}      — list current crontab"
    echo -e "  ${CYAN}crontab -r${RESET}      — remove crontab (careful!)"
    echo ""
    echo -e "  ${BOLD}Cron syntax:  minute hour day month weekday command${RESET}"
    echo -e "  ${DIM}*  *  *  *  *  = every minute of every hour every day${RESET}"
    echo ""
    echo -e "  ${BOLD}Examples:${RESET}"
    echo -e "  ${CYAN}0  9  *  *  1-5  /scripts/backup.sh${RESET}   — 9am weekdays"
    echo -e "  ${CYAN}*/5  *  *  *  *  /scripts/check.sh${RESET}    — every 5 minutes"
    echo -e "  ${CYAN}0  0  *  *  *  /scripts/cleanup.sh${RESET}    — midnight daily"
    echo -e "  ${CYAN}0  3  *  *  0  /scripts/weekly.sh${RESET}     — 3am Sunday"
    echo ""
    echo -e "  ${DIM}Tip: use https://crontab.guru to check cron expressions${RESET}"
    echo ""

    echo -e "  ${BOLD}Try this:${RESET}"
    echo -e "  ${DIM}crontab -l 2>/dev/null || echo 'No crontab set'${RESET}"
    echo ""

    pause
    free_menu
}

# ── Git essentials ───────────────────────────
free_git() {
    clear
    section "Git Essentials"
    echo -e "  Version control. Every DevOps engineer uses Git daily.\n"

    echo -e "  ${BOLD}Setup:${RESET}"
    echo -e "  ${CYAN}git config --global user.name 'Your Name'${RESET}"
    echo -e "  ${CYAN}git config --global user.email 'you@email.com'${RESET}"
    echo ""

    echo -e "  ${BOLD}The daily workflow:${RESET}"
    echo -e "  ${CYAN}git init${RESET}                — start a repo"
    echo -e "  ${CYAN}git clone URL${RESET}           — download a repo"
    echo -e "  ${CYAN}git status${RESET}              — what changed?"
    echo -e "  ${CYAN}git add file.txt${RESET}        — stage a file"
    echo -e "  ${CYAN}git add .${RESET}               — stage everything"
    echo -e "  ${CYAN}git commit -m 'message'${RESET} — save a snapshot"
    echo -e "  ${CYAN}git push${RESET}                — upload to remote"
    echo -e "  ${CYAN}git pull${RESET}                — download latest"
    echo -e "  ${CYAN}git log --oneline${RESET}       — commit history"
    echo -e "  ${CYAN}git diff${RESET}                — see changes"
    echo ""

    echo -e "  ${BOLD}Branches:${RESET}"
    echo -e "  ${CYAN}git branch feature-x${RESET}   — create branch"
    echo -e "  ${CYAN}git checkout feature-x${RESET} — switch to branch"
    echo -e "  ${CYAN}git checkout -b feature-x${RESET}— create and switch"
    echo -e "  ${CYAN}git merge feature-x${RESET}    — merge into current"
    echo ""

    pause
    free_menu
}

# ── Docker basics ────────────────────────────
free_docker() {
    clear
    section "Docker Basics"
    echo -e "  Containers. The foundation of modern DevOps.\n"

    echo -e "  ${BOLD}The core concept:${RESET}"
    echo -e "  Container = isolated process with everything it needs."
    echo -e "  Image = the blueprint. Container = running instance.\n"

    echo -e "  ${BOLD}Essential commands:${RESET}"
    echo -e "  ${CYAN}docker run nginx${RESET}              — run nginx container"
    echo -e "  ${CYAN}docker run -d -p 80:80 nginx${RESET}  — background + port map"
    echo -e "  ${CYAN}docker ps${RESET}                     — running containers"
    echo -e "  ${CYAN}docker ps -a${RESET}                  — all containers"
    echo -e "  ${CYAN}docker logs container_id${RESET}      — view logs"
    echo -e "  ${CYAN}docker exec -it id bash${RESET}       — shell inside container"
    echo -e "  ${CYAN}docker stop id${RESET}                — stop container"
    echo -e "  ${CYAN}docker rm id${RESET}                  — remove container"
    echo -e "  ${CYAN}docker images${RESET}                 — list images"
    echo -e "  ${CYAN}docker pull ubuntu:22.04${RESET}      — download image"
    echo -e "  ${CYAN}docker build -t myapp .${RESET}       — build from Dockerfile"
    echo ""

    echo -e "  ${DIM}Check if Docker is installed: docker --version${RESET}"
    echo ""

    pause
    free_menu
}

# ── Vim survival ─────────────────────────────
free_vim() {
    clear
    section "Vim — Survive and Thrive"
    echo -e "  Vim is on every Linux server. You WILL need it someday.\n"

    echo -e "  ${RED}${BOLD}How to exit vim:${RESET}  ${CYAN}:q!${RESET}  ${DIM}(force quit, no save)${RESET}"
    echo -e "  ${BOLD}How to save and exit:${RESET}  ${CYAN}:wq${RESET}  or  ${CYAN}:x${RESET}"
    echo ""

    echo -e "  ${BOLD}Modes:${RESET}"
    echo -e "  ${CYAN}Normal mode${RESET}  — default, for navigation and commands"
    echo -e "  ${CYAN}Insert mode${RESET}  — press ${BOLD}i${RESET} to type text"
    echo -e "  ${CYAN}Command mode${RESET} — press ${BOLD}:${RESET} to enter commands"
    echo -e "  ${CYAN}Esc${RESET}          — always goes back to Normal mode"
    echo ""

    echo -e "  ${BOLD}Essential Normal mode keys:${RESET}"
    echo -e "  ${CYAN}h j k l${RESET}  — left down up right"
    echo -e "  ${CYAN}gg${RESET}       — top of file    ${CYAN}G${RESET}  — bottom"
    echo -e "  ${CYAN}dd${RESET}       — delete line    ${CYAN}yy${RESET} — copy line"
    echo -e "  ${CYAN}p${RESET}        — paste          ${CYAN}u${RESET}  — undo"
    echo -e "  ${CYAN}/word${RESET}    — search forward  ${CYAN}n${RESET} — next match"
    echo -e "  ${CYAN}:set number${RESET} — show line numbers"
    echo ""

    echo -e "  ${BOLD}Try it:${RESET}"
    echo -e "  ${DIM}vim /tmp/vimtest.txt${RESET}"
    echo -e "  ${DIM}Press i, type something, press Esc, type :wq, press Enter${RESET}"
    echo ""

    pause
    free_menu
}

# ── Env & aliases ────────────────────────────
free_env() {
    clear
    section "Environment & PATH"
    echo -e "  Customize your shell to work faster.\n"

    echo -e "  ${BOLD}Environment variables:${RESET}"
    echo -e "  ${CYAN}env${RESET}                    — see all environment variables"
    echo -e "  ${CYAN}echo \$PATH${RESET}             — where Linux looks for commands"
    echo -e "  ${CYAN}export VAR=value${RESET}        — set for current session + children"
    echo -e "  ${CYAN}echo \$HOME \$USER \$SHELL${RESET}  — common env vars"
    echo ""

    echo -e "  ${BOLD}Making it permanent (~/.bashrc):${RESET}"
    echo -e '  echo '"'"'export PATH=$PATH:/my/tools'"'"' >> ~/.bashrc'
    echo -e '  echo '"'"'alias ll="ls -la"'"'"' >> ~/.bashrc'
    echo -e "  ${CYAN}source ~/.bashrc${RESET}   — reload without restarting terminal"
    echo ""

    echo -e "  ${BOLD}Useful aliases to add:${RESET}"
    echo -e '  alias ll="ls -la"'
    echo -e '  alias ..="cd .."'
    echo -e '  alias ...="cd ../.."'
    echo -e '  alias grep="grep --color=auto"'
    echo -e '  alias df="df -h"'
    echo -e '  alias free="free -h"'
    echo ""

    pause
    free_menu
}

# ── Archives ─────────────────────────────────
free_tar() {
    clear
    section "Archives & Compression"
    echo -e "  Pack and unpack files — essential for backups and transfers.\n"

    echo -e "  ${BOLD}tar — the main tool:${RESET}"
    echo -e "  ${CYAN}tar -czf archive.tar.gz directory/${RESET}   — create gzip archive"
    echo -e "  ${CYAN}tar -xzf archive.tar.gz${RESET}             — extract gzip archive"
    echo -e "  ${CYAN}tar -tzf archive.tar.gz${RESET}             — list contents"
    echo -e "  ${CYAN}tar -czf backup.tar.gz -C /var/www html/${RESET} — backup specific dir"
    echo ""
    echo -e "  ${BOLD}Flags:${RESET}  ${CYAN}c${RESET}=create  ${CYAN}x${RESET}=extract  ${CYAN}t${RESET}=list  ${CYAN}z${RESET}=gzip  ${CYAN}j${RESET}=bzip2  ${CYAN}f${RESET}=file  ${CYAN}v${RESET}=verbose"
    echo ""

    echo -e "  ${BOLD}zip/unzip:${RESET}"
    echo -e "  ${CYAN}zip -r archive.zip directory/${RESET}  — create zip"
    echo -e "  ${CYAN}unzip archive.zip${RESET}             — extract zip"
    echo -e "  ${CYAN}unzip -l archive.zip${RESET}          — list contents"
    echo ""

    echo -e "  ${BOLD}Try it:${RESET}"
    echo -e "  ${DIM}tar -czf /tmp/test_backup.tar.gz ~/kernos-practice/${RESET}"
    echo -e "  ${DIM}ls -lh /tmp/test_backup.tar.gz${RESET}"
    echo ""

    pause
    free_menu
}

free_disk() {
    clear
    section "Disk & Storage"
    echo -e "  Understand your storage in detail.\n"

    echo -e "  ${BOLD}Space and usage:${RESET}"
    echo -e "  ${CYAN}df -h${RESET}              — filesystem usage"
    echo -e "  ${CYAN}df -i${RESET}              — inode usage"
    echo -e "  ${CYAN}du -sh /var/*${RESET}      — size of each item in /var"
    echo -e "  ${CYAN}du -sh * | sort -rh${RESET}— sorted by size, largest first"
    echo -e "  ${CYAN}lsblk${RESET}              — block devices (disks, partitions)"
    echo -e "  ${CYAN}fdisk -l${RESET}           — partition table (needs root)"
    echo -e "  ${CYAN}blkid${RESET}              — UUIDs of block devices"
    echo -e "  ${CYAN}mount | column -t${RESET}  — mounted filesystems"
    echo ""

    echo -e "  ${BOLD}Finding disk hogs:${RESET}"
    echo -e "  ${CYAN}du -sh /var/* 2>/dev/null | sort -rh | head -10${RESET}"
    echo -e "  ${CYAN}find / -size +100M -type f 2>/dev/null${RESET}"
    echo ""

    pause
    free_menu
}

free_users() {
    clear
    section "Users & Groups"
    echo -e "  Managing who can do what on a Linux system.\n"

    echo -e "  ${BOLD}Managing users (needs sudo):${RESET}"
    echo -e "  ${CYAN}sudo useradd -m -s /bin/bash alice${RESET}  — create user"
    echo -e "  ${CYAN}sudo passwd alice${RESET}                   — set password"
    echo -e "  ${CYAN}sudo usermod -aG sudo alice${RESET}         — add to sudo group"
    echo -e "  ${CYAN}sudo userdel -r alice${RESET}               — delete user + home"
    echo ""

    echo -e "  ${BOLD}Groups:${RESET}"
    echo -e "  ${CYAN}groups${RESET}                    — your groups"
    echo -e "  ${CYAN}groups alice${RESET}              — alice's groups"
    echo -e "  ${CYAN}sudo groupadd developers${RESET}  — create group"
    echo -e "  ${CYAN}getent group sudo${RESET}         — who's in sudo group"
    echo ""

    echo -e "  ${BOLD}The files behind it all:${RESET}"
    echo -e "  ${CYAN}/etc/passwd${RESET}  — users (no passwords, public)"
    echo -e "  ${CYAN}/etc/shadow${RESET}  — password hashes (root only)"
    echo -e "  ${CYAN}/etc/group${RESET}   — group memberships"
    echo ""

    pause
    free_menu
}

free_logs() {
    clear
    section "System Logs"
    echo -e "  The truth about what your system has been doing.\n"

    echo -e "  ${BOLD}journalctl — modern log reader:${RESET}"
    echo -e "  ${CYAN}journalctl -n 50${RESET}                  — last 50 entries"
    echo -e "  ${CYAN}journalctl -f${RESET}                     — follow live"
    echo -e "  ${CYAN}journalctl -p err${RESET}                 — errors only"
    echo -e "  ${CYAN}journalctl --since '1 hour ago'${RESET}   — last hour"
    echo -e "  ${CYAN}journalctl -u nginx${RESET}               — nginx service logs"
    echo -e "  ${CYAN}journalctl --list-boots${RESET}           — all boot sessions"
    echo -e "  ${CYAN}journalctl -b -1${RESET}                  — previous boot logs"
    echo ""

    echo -e "  ${BOLD}Classic log files in /var/log/:${RESET}"
    echo -e "  ${CYAN}/var/log/syslog${RESET}    — general system log"
    echo -e "  ${CYAN}/var/log/auth.log${RESET}  — authentication (SSH, sudo)"
    echo -e "  ${CYAN}/var/log/kern.log${RESET}  — kernel messages"
    echo -e "  ${CYAN}/var/log/dpkg.log${RESET}  — package installs"
    echo ""

    echo -e "  ${BOLD}Try this:${RESET}"
    echo -e "  ${DIM}journalctl -p err --since '24 hours ago' | tail -20${RESET}"
    echo ""

    pause
    free_menu
}

free_menu
