#!/usr/bin/env bash
# run this only if you have not done cron or crond setup 
# This will help you setup cron services, not start running your python file in cron.
set -euo pipefail

echo "Cron Setup Utility"

if [[ $EUID -ne 0 ]]; then  #this guy check if you are it as sudo or not
    echo "Please run this script as root."
    echo "Example: sudo ./setup_cron.sh"
    exit 1
fi

install_cron() {  #tell me if any package manager is missing

    echo "Installing cron..."

    if command -v apt >/dev/null 2>&1; then
        apt update
        apt install -y cron

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y cronie

    elif command -v yum >/dev/null 2>&1; then
        yum install -y cronie

    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm cronie

    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install cron

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

if systemctl list-unit-files | grep -q "^cron.service"; then  
    SERVICE="cron"

elif systemctl list-unit-files | grep -q "^crond.service"; then
    SERVICE="crond"

else
    echo "Cron service not found after installation."
    echo "Please verify your cron package installation."
    exit 1
fi

echo "Using service: $SERVICE"
echo "Enabling service..."

systemctl enable "$SERVICE"

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

echo "Version:"
crontab -V 2>/dev/null || true
