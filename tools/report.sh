#!/usr/bin/env bash
source "$(dirname "$0")/../config/colors.sh"
source "$(dirname "$0")/../config/kernos.conf"

# ─────────────────────────────────────────────
#  kernos report
#  Saves a full system health report to a file
# ─────────────────────────────────────────────

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
mkdir -p "$REPORT_DIR"
REPORT="${REPORT_DIR}/kernos_report_${TIMESTAMP}.txt"

echo -e "\n  ${BOLD}Generating Report${RESET}"
divider
info "This will run all core modules and save output"
info "Destination: ${BOLD}${REPORT}${RESET}"
echo ""

{
echo "================================================================"
echo "  KERNOS SYSTEM HEALTH REPORT"
echo "  Host:      $(hostname)"
echo "  Generated: $(date)"
echo "  Kernel:    $(uname -r)"
echo "================================================================"

export LEARN=""  # no learn notes in reports
KERNOS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

bash "$KERNOS_DIR/core/system.sh"
bash "$KERNOS_DIR/core/cpu.sh"
bash "$KERNOS_DIR/core/memory.sh"
bash "$KERNOS_DIR/core/disk.sh"
bash "$KERNOS_DIR/core/network.sh"
bash "$KERNOS_DIR/core/processes.sh"
bash "$KERNOS_DIR/audit/users.sh"
bash "$KERNOS_DIR/tools/score.sh"

echo ""
echo "================================================================"
echo "  END OF REPORT"
echo "================================================================"
} | tee "$REPORT" | grep -v '^$' | tail -5

echo ""
ok "Report saved: ${BOLD}${REPORT}${RESET}"
info "View it with:  ${BOLD}cat $REPORT${RESET}  or  ${BOLD}less $REPORT${RESET}"
echo ""
