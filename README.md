# Kernos

**Your Linux learning companion. From zero to DevOps Engineer.**

![Shell](https://img.shields.io/badge/shell-bash-89e051?style=flat-square)
![Platform](https://img.shields.io/badge/platform-linux-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-orange?style=flat-square)
![Level](https://img.shields.io/badge/level-beginner%20→%20devops-cyan?style=flat-square)

Kernos is a pure Bash interactive learning tool that runs on your actual Linux machine. It guides you from your very first `ls` command all the way to writing real DevOps scripts — through structured levels, real hands-on challenges, and a gamified XP system that keeps you coming back.

No browser. No video. No theory-only lessons. You learn by doing it on your actual machine, and Kernos checks if you did it right.

---

## How it works

```
kernos
```

That's it. Kernos starts an interactive session right in your terminal.

```
    ██╗  ██╗███████╗██████╗ ███╗   ██╗ ██████╗ ███████╗
    ...

    Hello, Ahmed  —  [ APPRENTICE ]
    [████████████░░░░░░░░░░░░░░░░░░] 412/600 XP

    LEARNING PATH

    ✔  Level 1 — Finding Your Way Around     [7 challenges done]
    ✔  Level 2 — Reading, Writing, Perms     [6 challenges done]
    ✔  Level 3 — Processes & System          [4 challenges done]
    ▶  Level 4 — Networking Essentials
       Commands: ip ss ping ssh curl ufw
    🔒 Level 5 — Bash Scripting              (unlocks at 1000 XP)

    f  Free Mode — Explore any topic
    p  Your Profile & Rank Roadmap
```

---

## The learning path

| Level | Topic | Commands |
|-------|-------|----------|
| 1 | Finding Your Way Around | `pwd` `ls` `cd` `mkdir` `touch` `rm` `cp` `mv` |
| 2 | Reading, Writing, Permissions | `cat` `grep` `chmod` `pipes` `redirects` `wc` |
| 3 | Processes & System Control | `ps` `top` `kill` `systemctl` `df` `free` `uname` |
| 4 | Networking Essentials | `ip` `ss` `ping` `curl` `ssh` `ufw` `scp` |
| 5 | Bash Scripting | variables, loops, conditions, functions, exit codes |
| 6+ | *(coming)* | Docker, Git, Ansible, CI/CD, Kubernetes basics |

---

## How challenges work

Every challenge follows the same 4-step pattern:

**1. Learn the command** — Kernos explains what it does and why it matters, with a real example.

**2. See it in context** — you see the exact syntax and common flags before you write anything.

**3. Do it on your real machine** — Kernos gives you a specific task: create this file, find these processes, write this script. You open a terminal and actually do it.

**4. Kernos checks your work** — it looks at your actual machine to verify you completed the task. No guessing. Either you did it or you didn't.

```bash
⚡ CHALLENGE: Create your project structure

  Your task:
  In your home directory, create this structure:
    ~/kernos-practice/
    ~/kernos-practice/notes/
    ~/kernos-practice/scripts/
    ~/kernos-practice/logs/

  Use one command: mkdir -p ~/kernos-practice/{notes,scripts,logs}

  Hint: The {} syntax creates all three directories at once.

  Press Enter when ready...

  Checking...

  ✔  kernos-practice/ exists
  ✔  notes/ exists
  ✔  scripts/ exists
  ✔  logs/ exists

  +20 XP — challenge completed

  [ BEGINNER ] [████████░░░░░░░░░░░░░░░░░░░░] 85/100 XP
```

---

## The XP & Rank system

| XP | Rank |
|----|------|
| 0 | NEWCOMER |
| 100 | BEGINNER |
| 300 | EXPLORER |
| 600 | APPRENTICE |
| 1000 | PRACTITIONER |
| 1600 | ADVANCED |
| 2400 | SYSADMIN |
| 3500 | **DEVOPS ENGINEER** |

Completing harder challenges earns more XP. Boss challenges at the end of each level give a large XP reward.

---

## Free Mode

Not in the mood for structured learning? Free Mode lets you explore any topic:

- Text processing (awk, sed, cut, sort, uniq)
- Disk & storage deep dive
- Users & groups management
- Cron & scheduling
- Git essentials
- Docker basics
- Vim survival guide
- Environment & aliases
- Archives & compression
- System logs (journalctl)

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/kernos.git
cd kernos
bash install.sh
source ~/.bashrc
kernos
```

**Requirements:** Linux, Bash 4.0+, standard GNU coreutils. Nothing else.

---

## Who this is for

- Complete beginners who want to learn Linux the right way
- Developers who want to get comfortable in the terminal
- Students preparing for sysadmin or DevOps roles
- Anyone who keeps forgetting Linux commands because they never practiced enough

---

## Why pure Bash?

Because the best way to learn Linux is to use Linux. Kernos has zero dependencies — no Python, no Node, no package manager required. If you have a Linux terminal, you have everything you need.

And because reading the source code of Kernos itself is a Linux education. Every script is clean, commented, and written the way real sysadmins write Bash.

---

## License

MIT — fork it, improve it, share it.
