#!/usr/bin/env bash
# Idempotent cron uninstall utility - safe to re-run.
# Backs up every user's crontab (crontab -l) before removing cron/cronie.
# Does NOT touch /etc/crontab or /etc/cron.d - only each user's personal crontab.
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi
set -euo pipefail

QUIET=0

for arg in "$@"; do
	case "$arg" in
		-h|--help)
			cat <<EOF
Usage: sudo $0 [--quiet] [--help]
Idempotent cron uninstall utility for systemd-based Linux systems.
Backs up every user's crontab, stops and disables the cron service,
then removes cron/cronie via the system package manager.
Options:
  -q, --quiet   Suppress progress output; errors and the backup file
                location are still shown
  -h, --help    Show this help message and exit
EOF
			exit 0
			;;
		-q|--quiet)
			QUIET=1
			;;
		*)
			echo "Unknown option: $arg" >&2
			echo "Try '$0 --help' for usage" >&2
			exit 1
			;;
	esac
done

log() {
	if [[ "$QUIET" -eq 0 ]]; then
		echo "$@"
	fi
}

log "Cron Uninstall Utility"

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root."
    echo "Example: sudo ./uninstall.sh"
    exit 1
fi

if ! command -v systemctl >/dev/null 2>&1 || ! systemctl list-units >/dev/null 2>&1; then
    echo "systemd not detected — this script requires a systemd-based system."
    exit 1
fi

# Back up to the invoking user's home directory (not root's) when run via sudo.
if [[ -n "${SUDO_USER:-}" ]] && getent passwd "$SUDO_USER" >/dev/null 2>&1; then
    REAL_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
    BACKUP_OWNER="$SUDO_USER"
else
    REAL_HOME="${HOME:-/root}"
    BACKUP_OWNER=""
fi
BACKUP_DIR="${REAL_HOME:-/root}/cron_backups"

backup_crontabs() {
    if ! command -v crontab >/dev/null 2>&1; then
        log "crontab command not found; nothing to back up."
        return
    fi

    log "Backing up existing crontabs..."
    local tmp_file backup_file
    tmp_file="$(mktemp)"
    {
        echo "# Crontab backup created by uninstall.sh"
        echo "# $(date '+%Y-%m-%d %H:%M:%S %Z')"
    } > "$tmp_file"

    local found_any=0
    local username user_crontab
    while IFS=: read -r username _ _ _ _ _ _; do
        if user_crontab="$(crontab -l -u "$username" 2>/dev/null)" && [[ -n "$user_crontab" ]]; then
            {
                echo
                echo "## User: $username"
                echo "$user_crontab"
            } >> "$tmp_file"
            found_any=1
        fi
    done < /etc/passwd

    if [[ "$found_any" -eq 1 ]]; then
        mkdir -p "$BACKUP_DIR"
        backup_file="$BACKUP_DIR/crontab_backup_$(date +%Y%m%d_%H%M%S).txt"
        mv "$tmp_file" "$backup_file"
        chmod 600 "$backup_file"
        if [[ -n "$BACKUP_OWNER" ]]; then
            chown "$BACKUP_OWNER":"$(id -gn "$BACKUP_OWNER")" "$BACKUP_DIR" "$backup_file" 2>/dev/null || true
        fi
        echo "✓ Crontab backup saved to: $backup_file"
    else
        rm -f "$tmp_file"
        log "No user crontabs found; nothing to back up."
    fi
}

backup_crontabs

SERVICE=""
if systemctl cat cron >/dev/null 2>&1; then
    SERVICE="cron"
elif systemctl cat crond >/dev/null 2>&1; then
    SERVICE="crond"
fi

if [[ -n "$SERVICE" ]]; then
    log "Using service: $SERVICE"
    if systemctl is-active --quiet "$SERVICE"; then
        log "Stopping service..."
        systemctl stop "$SERVICE" || echo "⚠ Could not stop $SERVICE; continuing anyway."
    fi
    if systemctl is-enabled --quiet "$SERVICE" 2>/dev/null; then
        log "Disabling service..."
        systemctl disable "$SERVICE" || echo "⚠ Could not disable $SERVICE; continuing anyway."
    fi
else
    log "No cron service unit found; skipping stop/disable."
fi

uninstall_cron() {
    log "Removing cron..."
    if command -v apt >/dev/null 2>&1; then
        DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt remove -y cron
    elif command -v dnf >/dev/null 2>&1; then
        dnf remove -y cronie
    elif command -v yum >/dev/null 2>&1; then
        yum remove -y cronie
    elif command -v pacman >/dev/null 2>&1; then
        pacman -R --noconfirm cronie
    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive remove cron
    elif command -v apk >/dev/null 2>&1; then
        apk del cronie
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
}

if command -v crontab >/dev/null 2>&1; then
    uninstall_cron
else
    log "crontab is already not installed."
fi

log ""
log "Cron uninstall completed."
