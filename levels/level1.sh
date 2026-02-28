#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  LEVEL 1 — Finding Your Way Around
#  Commands: pwd, ls, cd, mkdir, touch, rm
#  XP available: 120
# ─────────────────────────────────────────────

KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$KERNOS_DIR/config/ui.sh"
source "$KERNOS_DIR/config/progress.sh"
source "$KERNOS_DIR/config/challenge.sh"

level_menu() {
    clear
    banner
    echo -e "  ${CYAN}${BOLD}LEVEL 1 — Finding Your Way Around${RESET}"
    echo -e "  ${DIM}The foundation of everything. Learn to move, create, and delete.${RESET}"
    echo ""
    show_xp_bar

    divider
    echo ""

    local challenges=(
        "1.1" "Where am I?           (pwd)"         "c1_pwd"
        "1.2" "What's in here?       (ls)"           "c1_ls"
        "1.3" "Move around           (cd)"           "c1_cd"
        "1.4" "Create a directory    (mkdir)"        "c1_mkdir"
        "1.5" "Create a file         (touch)"        "c1_touch"
        "1.6" "Delete files          (rm)"           "c1_rm"
        "1.7" "The big challenge     (combine all)"  "c1_boss"
    )

    for ((i=0; i<${#challenges[@]}; i+=3)); do
        local id="${challenges[$i]}"
        local title="${challenges[$((i+1))]}"
        local fn="${challenges[$((i+2))]}"

        if is_complete "level1_${fn}"; then
            echo -e "  ${GREEN}✔${RESET}  ${BOLD}${id}${RESET}  $title  ${DIM}[done]${RESET}"
        else
            echo -e "  ${DIM}○${RESET}  ${BOLD}${id}${RESET}  $title"
        fi
    done

    echo ""
    divider
    echo ""
    echo -e "  ${DIM}Pick a challenge (1-7), or press Enter to go back: ${RESET}"
    read -r choice

    case "$choice" in
        1|1.1) c1_pwd ;;
        2|1.2) c1_ls ;;
        3|1.3) c1_cd ;;
        4|1.4) c1_mkdir ;;
        5|1.5) c1_touch ;;
        6|1.6) c1_rm ;;
        7|1.7) c1_boss ;;
        "")    return ;;
        *)     level_menu ;;
    esac
}

# ─────────────────────────────────────────────
#  Challenge 1.1 — pwd
# ─────────────────────────────────────────────
c1_pwd() {
    clear
    echo -e "\n  ${BOLD}Challenge 1.1 — Where am I?${RESET}\n"

    teach "pwd" \
        "pwd stands for Print Working Directory.\nIt tells you exactly where you are in the filesystem right now.\nThink of it as asking Linux: where am I standing?" \
        "pwd" \
        "/home/ubuntu"

    echo -e "  ${DIM}The Linux filesystem is a tree. Everything starts at / (called 'root').\n  You always exist somewhere inside that tree. pwd shows you where.${RESET}\n"

    challenge_prompt "Print your location" \
        "Open a terminal and run pwd.\nThen run it again from a different directory (try: cd /tmp then pwd).\nCome back when you understand what it shows." \
        "Just type: pwd and press Enter"

    echo -e "  ${BOLD}Verification:${RESET} Tell me your home directory path.\n"
    echo -ne "  ${DIM}What does 'pwd' show when you're in your home directory? ${RESET}"
    read -r answer

    # Accept any path that starts with /
    if echo "$answer" | grep -qE '^/'; then
        is_complete "level1_c1_pwd" && { already_done; level_menu; return; }
        mark_complete "level1_c1_pwd"
        challenge_pass 15 "You know where you are!"
        echo -e "  ${DIM}pwd is something you'll run hundreds of times in your career.\n  Muscle memory: when lost, type pwd.${RESET}"
    else
        challenge_fail "A path always starts with /. Try running pwd in your terminal and paste what you see."
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
#  Challenge 1.2 — ls
# ─────────────────────────────────────────────
c1_ls() {
    clear
    echo -e "\n  ${BOLD}Challenge 1.2 — What's in here?${RESET}\n"

    teach "ls" \
        "ls lists the contents of a directory.\nBy default it shows the current directory.\nFlags change what you see and how." \
        "ls -la /home" \
        "total 32
drwxr-xr-x  5 root   root   4096 Jan 18 09:00 .
drwxr-xr-x 20 root   root   4096 Jan 15 08:30 ..
drwxr-xr-x 12 ubuntu ubuntu 4096 Jan 18 14:22 ubuntu
-rw-r--r--  1 root   root    220 Jan 15 08:30 .bashrc"

    echo -e "  ${BOLD}Useful flags:${RESET}"
    echo -e "  ${CYAN}ls${RESET}       — basic list"
    echo -e "  ${CYAN}ls -l${RESET}    — long format (permissions, size, date)"
    echo -e "  ${CYAN}ls -a${RESET}    — show hidden files (start with .)"
    echo -e "  ${CYAN}ls -la${RESET}   — long format + hidden files"
    echo -e "  ${CYAN}ls -lh${RESET}   — human readable file sizes"
    echo -e "  ${CYAN}ls -lt${RESET}   — sort by time, newest first"
    echo ""

    challenge_prompt "Explore with ls" \
        "1. Run: ls /etc | head -20  (list /etc, show first 20)\n  2. Run: ls -lh ~  (list your home dir, human readable)\n  3. Run: ls -la ~  (find hidden files — notice the . files)\n\n  Come back when you've tried all three." \
        "~ means your home directory"

    echo -e "  ${BOLD}Verification:${RESET}\n"
    echo -ne "  ${DIM}How many hidden files do you see in your home directory? (any number): ${RESET}"
    read -r answer

    if [[ "$answer" =~ ^[0-9]+$ ]]; then
        is_complete "level1_c1_ls" && { already_done; level_menu; return; }
        mark_complete "level1_c1_ls"
        challenge_pass 15 "You can see what's in any directory!"
        echo -e "  ${DIM}ls -la is one of the most used commands in Linux.\n  Hidden files (dotfiles) store config — .bashrc, .ssh, .gitconfig${RESET}"
    else
        challenge_fail "Enter a number (even 0 is fine). Run: ls -la ~ and count the lines starting with a dot."
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
#  Challenge 1.3 — cd
# ─────────────────────────────────────────────
c1_cd() {
    clear
    echo -e "\n  ${BOLD}Challenge 1.3 — Move Around${RESET}\n"

    teach "cd" \
        "cd stands for Change Directory.\nIt moves you to a different location in the filesystem.\nMastering cd makes everything else faster." \
        "cd /var/log" \
        "(you are now in /var/log)"

    echo -e "  ${BOLD}Essential shortcuts:${RESET}"
    echo -e "  ${CYAN}cd ~${RESET}        — go to your home directory (same as just: cd)"
    echo -e "  ${CYAN}cd ..${RESET}       — go up one level (parent directory)"
    echo -e "  ${CYAN}cd ../..${RESET}    — go up two levels"
    echo -e "  ${CYAN}cd -${RESET}        — go back to the previous directory (toggle)"
    echo -e "  ${CYAN}cd /${RESET}        — go to the root of the filesystem"
    echo -e "  ${CYAN}cd /etc${RESET}     — absolute path (starts from root)"
    echo -e "  ${CYAN}cd logs${RESET}     — relative path (from current location)"
    echo ""

    challenge_prompt "Navigate the filesystem" \
        "Complete this exact sequence in your terminal:\n\n  1. cd /var/log     (go into /var/log)\n  2. pwd             (confirm you're there)\n  3. cd ..           (go up one level)\n  4. pwd             (you should be in /var)\n  5. cd ~            (go home)\n  6. pwd             (confirm you're home)\n\n  Practice until the movement feels natural." \
        "cd - is the secret weapon — it jumps back to wherever you were"

    echo -ne "  ${DIM}What does 'cd ..' do? ${RESET}"
    read -r answer

    if echo "$answer" | grep -qiE 'up|parent|above|back|level'; then
        is_complete "level1_c1_cd" && { already_done; level_menu; return; }
        mark_complete "level1_c1_cd"
        challenge_pass 15 "You can navigate the filesystem!"
        echo -e "  ${DIM}Pro tip: press Tab to autocomplete directory names.\n  Type cd /va then Tab — it becomes cd /var automatically.${RESET}"
    else
        challenge_fail "Think about it: if you're in /var/log, cd .. takes you to...?"
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
#  Challenge 1.4 — mkdir
# ─────────────────────────────────────────────
c1_mkdir() {
    clear
    echo -e "\n  ${BOLD}Challenge 1.4 — Create a Directory${RESET}\n"

    teach "mkdir" \
        "mkdir creates a new directory.\nmkdir -p creates the full path including parent directories.\nWithout -p, you get an error if the parent doesn't exist." \
        "mkdir -p projects/kernos/notes" \
        "(creates projects/, then kernos/ inside it, then notes/ inside that)"

    echo -e "  ${BOLD}Key flags:${RESET}"
    echo -e "  ${CYAN}mkdir mydir${RESET}          — create one directory"
    echo -e "  ${CYAN}mkdir dir1 dir2 dir3${RESET} — create multiple at once"
    echo -e "  ${CYAN}mkdir -p a/b/c${RESET}       — create full nested path"
    echo -e "  ${CYAN}mkdir -v mydir${RESET}        — verbose (shows what was created)"
    echo ""

    challenge_prompt "Create your project structure" \
        "In your home directory (~), create this structure:\n\n  ~/kernos-practice/\n  ~/kernos-practice/notes/\n  ~/kernos-practice/scripts/\n  ~/kernos-practice/logs/\n\n  Use one command: mkdir -p ~/kernos-practice/{notes,scripts,logs}" \
        "The {notes,scripts,logs} syntax creates all three at once"

    # Verify
    local pass=0
    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    verify_dir_exists "$HOME/kernos-practice" "Base directory" && \
    verify_dir_exists "$HOME/kernos-practice/notes" "notes/" && \
    verify_dir_exists "$HOME/kernos-practice/scripts" "scripts/" && \
    verify_dir_exists "$HOME/kernos-practice/logs" "logs/" && pass=1

    if [[ $pass -eq 1 ]]; then
        is_complete "level1_c1_mkdir" && { already_done; level_menu; return; }
        mark_complete "level1_c1_mkdir"
        challenge_pass 20 "Project structure created!"
        echo -e "  ${DIM}mkdir -p with braces is a pattern you'll use constantly.\n  mkdir -p /etc/app/{config,logs,backup} is standard sysadmin work.${RESET}"
    else
        challenge_fail "Create the directories and come back. Use: mkdir -p ~/kernos-practice/{notes,scripts,logs}"
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
#  Challenge 1.5 — touch, echo, cat
# ─────────────────────────────────────────────
c1_touch() {
    clear
    echo -e "\n  ${BOLD}Challenge 1.5 — Create Files${RESET}\n"

    teach "touch / echo / cat" \
        "touch creates an empty file (or updates timestamp if it exists).\necho prints text — redirect it with > to write to a file.\ncat reads and displays file contents." \
        'echo "Hello Linux" > ~/kernos-practice/notes/hello.txt' \
        "(creates hello.txt with the text 'Hello Linux')"

    echo -e "  ${BOLD}File creation methods:${RESET}"
    echo -e "  ${CYAN}touch file.txt${RESET}             — create empty file"
    echo -e "  ${CYAN}echo 'text' > file.txt${RESET}     — create file with content (overwrites)"
    echo -e "  ${CYAN}echo 'text' >> file.txt${RESET}    — append to file (adds a line)"
    echo -e "  ${CYAN}cat file.txt${RESET}               — read file contents"
    echo -e "  ${CYAN}cat > file.txt${RESET}             — type content, Ctrl+D to save"
    echo ""

    challenge_prompt "Create your first real file" \
        'Run these commands:\n\n  echo "I am learning Linux with Kernos" > ~/kernos-practice/notes/hello.txt\n  echo "Today I learned: pwd, ls, cd, mkdir" >> ~/kernos-practice/notes/hello.txt\n  cat ~/kernos-practice/notes/hello.txt\n\n  The file must exist with both lines inside.' \
        ">> appends, > overwrites. Know the difference."

    local pass=0
    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    verify_file_exists "$HOME/kernos-practice/notes/hello.txt" "hello.txt" && \
    verify_file_contains "$HOME/kernos-practice/notes/hello.txt" "Linux" && pass=1

    if [[ $pass -eq 1 ]]; then
        is_complete "level1_c1_touch" && { already_done; level_menu; return; }
        mark_complete "level1_c1_touch"
        challenge_pass 20 "You created your first file with real content!"
        echo -e "  ${DIM}echo + redirect is how scripts write output to files.\n  cat is how you quickly read small files without opening an editor.${RESET}"
    else
        challenge_fail "Create the file with that exact path and make sure it has content."
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
#  Challenge 1.6 — rm, rmdir, mv, cp
# ─────────────────────────────────────────────
c1_rm() {
    clear
    echo -e "\n  ${BOLD}Challenge 1.6 — Delete, Move, Copy${RESET}\n"

    teach "rm / mv / cp" \
        "rm deletes files. rmdir deletes empty directories.\nrm -rf deletes directories and everything inside them.\nWARNING: Linux has no recycle bin. rm is permanent." \
        "rm file.txt          # delete a file
mv file.txt newname.txt  # rename / move
cp file.txt backup.txt   # copy" \
        ""

    echo -e "  ${RED}${BOLD}⚠  rm is permanent. Always double-check your path.${RESET}"
    echo -e "  ${DIM}There is no undo. There is no recycle bin. rm is forever.${RESET}\n"

    echo -e "  ${BOLD}The commands:${RESET}"
    echo -e "  ${CYAN}rm file.txt${RESET}           — delete a file"
    echo -e "  ${CYAN}rm -i file.txt${RESET}        — ask before deleting (safe habit)"
    echo -e "  ${CYAN}rm -r directory/${RESET}      — delete directory recursively"
    echo -e "  ${CYAN}rm -rf directory/${RESET}     — force delete, no questions asked"
    echo -e "  ${CYAN}mv old.txt new.txt${RESET}    — rename or move"
    echo -e "  ${CYAN}cp file.txt copy.txt${RESET}  — copy file"
    echo -e "  ${CYAN}cp -r dir/ newdir/${RESET}    — copy directory recursively"
    echo ""

    challenge_prompt "Clean up and reorganize" \
        "Complete these tasks:\n\n  1. cp ~/kernos-practice/notes/hello.txt ~/kernos-practice/notes/hello-backup.txt\n  2. mv ~/kernos-practice/notes/hello-backup.txt ~/kernos-practice/logs/\n  3. rm ~/kernos-practice/logs/hello-backup.txt\n\n  When done: ls ~/kernos-practice/notes/ and ls ~/kernos-practice/logs/ should both work." \
        "cp first, then mv, then rm — copy before moving anything important"

    local pass=0
    echo -e "\n  ${BOLD}Checking...${RESET}\n"
    verify_file_exists "$HOME/kernos-practice/notes/hello.txt" "Original file still exists" && \
    verify_file_not_exists "$HOME/kernos-practice/logs/hello-backup.txt" "Backup was deleted" && \
    verify_file_not_exists "$HOME/kernos-practice/notes/hello-backup.txt" "Backup not in notes" && pass=1

    if [[ $pass -eq 1 ]]; then
        is_complete "level1_c1_rm" && { already_done; level_menu; return; }
        mark_complete "level1_c1_rm"
        challenge_pass 20 "You can create, move, copy, and delete files!"
        echo -e "  ${DIM}Before any rm -rf, always run: ls -la <path> first to see what you're deleting.\n  Professional habit: never run rm -rf as root without triple-checking.${RESET}"
    else
        challenge_fail "Follow the steps in order. The original hello.txt must still exist in notes/."
    fi

    pause
    level_menu
}

# ─────────────────────────────────────────────
#  Challenge 1.7 — BOSS CHALLENGE
# ─────────────────────────────────────────────
c1_boss() {
    clear
    echo -e "\n  ${YELLOW}${BOLD}★ BOSS CHALLENGE — Level 1 ★${RESET}\n"
    echo -e "  ${DIM}Combine everything you learned. No hints this time.${RESET}\n"
    divider
    echo ""

    echo -e "  ${BOLD}Mission: Build a project skeleton from scratch${RESET}"
    echo ""
    echo -e "  Create this exact structure in your home directory:"
    echo ""
    echo -e "  ${CYAN}~/myproject/${RESET}"
    echo -e "  ${CYAN}~/myproject/src/${RESET}"
    echo -e "  ${CYAN}~/myproject/docs/${RESET}"
    echo -e "  ${CYAN}~/myproject/tests/${RESET}"
    echo -e "  ${CYAN}~/myproject/README.txt${RESET}  ← must contain: 'My first Linux project'"
    echo -e "  ${CYAN}~/myproject/src/main.sh${RESET} ← any content is fine"
    echo ""
    echo -e "  ${DIM}Commands you'll need: mkdir -p, echo, touch${RESET}"
    echo -e "  ${DIM}No hints. You know enough. Go build it.${RESET}"
    echo ""

    press_any

    echo -e "\n  ${BOLD}Verifying your work...${RESET}\n"
    local score=0

    verify_dir_exists "$HOME/myproject"         "myproject/"     && (( score++ ))
    verify_dir_exists "$HOME/myproject/src"     "src/"           && (( score++ ))
    verify_dir_exists "$HOME/myproject/docs"    "docs/"          && (( score++ ))
    verify_dir_exists "$HOME/myproject/tests"   "tests/"         && (( score++ ))
    verify_file_exists "$HOME/myproject/README.txt" "README.txt" && (( score++ ))
    verify_file_contains "$HOME/myproject/README.txt" "Linux" "README.txt has required text" && (( score++ ))
    verify_file_exists "$HOME/myproject/src/main.sh" "main.sh"   && (( score++ ))

    echo ""
    echo -e "  Score: ${BOLD}${score}/7${RESET}"

    if [[ $score -ge 6 ]]; then
        is_complete "level1_c1_boss" && { already_done; level_menu; return; }
        mark_complete "level1_c1_boss"
        challenge_pass 30 "LEVEL 1 BOSS DEFEATED!"
        echo ""
        echo -e "  ${CYAN}${BOLD}You now know the foundation of Linux navigation.${RESET}"
        echo -e "  ${DIM}Every DevOps engineer, every sysadmin, every developer uses"
        echo -e "  these commands dozens of times every day. They are yours now.${RESET}"
    elif [[ $score -ge 4 ]]; then
        warn "So close! Fix the missing pieces and try again."
        challenge_fail "You're almost there — $score/7 checks passed."
    else
        challenge_fail "Keep going. Build the structure step by step."
    fi

    pause
    level_menu
}

# ── Entry point ──────────────────────────────
level_menu
