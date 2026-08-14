#!/bin/sh
# Idempotent cron setup utility - safe to re-run.
# Installs and enables the system cron service (skips steps already done).
# Supports both systemd and OpenRC (e.g. Alpine Linux) init systems.
# This does NOT schedule your Python script in cron - that's a separate step.

set -eu
QUIET=0
for arg in "$@"; do
	case "$arg" in
		-h|--help)
			cat <<EOF
Usage: sudo $0 [--quiet][--help]

Idempotent cron setup utility for systemd-based Linux systems.
Installs cron/cronie via the system package manager if missing,
enables and starts the service, and reports its version.

Options:
  -q, --quiet   Suppress progress output; only errors and the exit code
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
    	esac
done

log() {
	if [ "$QUIET" -eq 0 ]; then
		echo "$@"
	fi
}

log "Cron Setup Utility"

if [ "$(id -u)" -ne 0 ]; then  #this guy check if you are it as sudo or not
    echo "Please run this script as root."
    echo "Example: sudo ./setup_cron.sh"
    exit 1
fi

INIT_SYSTEM=""
detect_init() {
    if [ -d /run/systemd/system ]; then
        INIT_SYSTEM="systemd"
    elif [ -d /run/openrc ] || command -v rc-service >/dev/null 2>&1; then
        INIT_SYSTEM="openrc"
    elif [ "$(ps -p 1 -o comm=)" = "init" ]; then
        INIT_SYSTEM="sysvinit"
    fi
}

detect_init

case "$INIT_SYSTEM" in
    systemd|openrc)
        ;;
    sysvinit)
        echo "This system appears to run SysVinit, which isn't supported (only systemd and OpenRC are)."
        exit 1
        ;;
    *)
        echo "Could not detect a supported init system (systemd or OpenRC) on this system."
        exit 1
        ;;
esac
log "Init system: $INIT_SYSTEM"
 

install_cron() {  #tell me if any package manager is missing

    log "Installing cron..."

    if command -v apt >/dev/null 2>&1; then
        apt update
        DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt install -y cron

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y cronie

    elif command -v yum >/dev/null 2>&1; then
        yum install -y cronie

    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm cronie #i don't use -Syu cause it was doing full system upgrade 

    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive refresh
        zypper --non-interactive install cron
        
	elif command -v apk >/dev/null 2>&1; then
        apk update
        apk add cronie
        
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
}

if command -v crontab >/dev/null 2>&1; then #check if crontab is installed or not 
    log "✓ crontab is already installed."
else
    log "crontab not found."
    install_cron
fi

SERVICE=""

if [ "$INIT_SYSTEM" = "systemd" ]; then #systemctl
    if systemctl cat cron >/dev/null 2>&1; then
        SERVICE="cron"
    elif systemctl cat crond >/dev/null 2>&1; then
        SERVICE="crond"
    elif systemctl cat cronie >/dev/null 2>&1; then
    		SERVICE="cronie"
    else
        echo "Cron service not found after installation."
        exit 1
    fi
 
    log "Using service: $SERVICE"
    log "Enabling service..."
    if ! systemctl enable "$SERVICE"; then
        echo "✗ Failed to enable $SERVICE (it may be masked)."
        echo "  Check with: systemctl status $SERVICE"
        exit 1
    fi
 
    if systemctl is-active --quiet "$SERVICE"; then
        log "✓ Service already running."
        log "Cron-setup was already Completed"
    else
        log "Starting service..."
        systemctl start "$SERVICE"
    fi
 
    log ""
    if systemctl is-active --quiet "$SERVICE"; then
        log "Cron setup completed successfully."
    else
        echo "Failed to start cron service. Recent logs:"
        journalctl -u "$SERVICE" --no-pager -n 15 || true
        exit 1
    fi
else # OpenRC
    if [ -f /etc/init.d/crond ]; then
        SERVICE="crond"
    elif [ -f /etc/init.d/cronie ]; then
        SERVICE="cronie"
    elif [ -f /etc/init.d/cron ]; then
        SERVICE="cron"
    else
        echo "Cron service not found after installation."
        exit 1
    fi
 
    log "Using service: $SERVICE"
    log "Enabling service..."
    if ! rc-update add "$SERVICE" default; then
        echo "✗ Failed to enable $SERVICE."
        echo "  Check with: rc-service $SERVICE status"
        exit 1
    fi
 
    if rc-service "$SERVICE" status >/dev/null 2>&1; then
        log "✓ Service already running."
        log "Cron-setup was already Completed"
    else
        log "Starting service..."
        rc-service "$SERVICE" start
    fi
 
    log ""
    if rc-service "$SERVICE" status >/dev/null 2>&1; then
        log "Cron setup completed successfully."
    else
        echo "Failed to start cron service."
        echo "Check status with: rc-service $SERVICE status"
        exit 1
    fi
fi
