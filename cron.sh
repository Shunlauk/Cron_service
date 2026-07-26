#!/usr/bin/env bash
# Idempotent cron setup utility - safe to re-run.
# Installs and enables the system cron service (skips steps already done).
# This does NOT schedule your Python script in cron - that's a separate step.

if [ -z "${BASH_VERSION:-}" ]; then #I known some of will try to run it as sh cron.sh
    exec bash "$0" "$@"
fi

set -euo pipefail

echo "Cron Setup Utility"

if [[ $EUID -ne 0 ]]; then  #this guy check if you are it as sudo or not
    echo "Please run this script as root."
    echo "Example: sudo ./setup_cron.sh"
    exit 1
fi

if ! command -v systemctl >/dev/null 2>&1 || ! systemctl list-units >/dev/null 2>&1; then
    echo "systemd not detected — this script requires a systemd-based system."
    exit 1
fi

install_cron() {  #tell me if any package manager is missing

    echo "Installing cron..."

    if command -v apt >/dev/null 2>&1; then
        apt update
        DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt install -y cron

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y cronie

    elif command -v yum >/dev/null 2>&1; then
        yum install -y cronie

    elif command -v pacman >/dev/null 2>&1; then
        pacman -Syu --noconfirm cronie

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
    echo "✓ crontab is already installed."
else
    echo "crontab not found."
    install_cron
fi


SERVICE=""

if systemctl cat cron >/dev/null 2>&1; then
    SERVICE="cron"

elif systemctl cat crond >/dev/null 2>&1; then
    SERVICE="crond"

else
    echo "Cron service not found after installation."
    exit 1
fi

echo "Using service: $SERVICE"
echo "Enabling service..."

if ! systemctl enable "$SERVICE"; then
    echo "✗ Failed to enable $SERVICE (it may be masked)."
    echo "  Check with: systemctl status $SERVICE"
    exit 1
fi

if systemctl is-active --quiet "$SERVICE"; then
    echo "✓ Service already running."
else
    echo "Starting service..."
    systemctl start "$SERVICE"
fi

echo

if systemctl is-active --quiet "$SERVICE"; then 
    echo "Cron setup completed successfully."
else
    echo "Failed to start cron service."
    exit 1
fi

show_cron_version() {
 	local out
 	
    if out="$(crontab -V 2>&1)" && [ -n "$out" ]; then
        echo "$out"
        return
    fi
    
    for pkg in cronie cron; do
        if command -v rpm >/dev/null 2>&1 && rpm -q "$pkg" 2>/dev/null; then
            return
        fi
        
        if command -v dpkg-query >/dev/null 2>&1 && dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "$pkg $(dpkg-query -W -f='${Version}' "$pkg")"
            return
        fi
        
        if command -v pacman >/dev/null 2>&1 && pacman -Q "$pkg" 2>/dev/null; then
            return
        fi
        
    done
    
    echo "  (version info not available for this cron implementation)"
}
echo "Cron implementation:"
show_cron_version
