# Cron Setup Utility

A simple Bash script that installs and configures **cron** (or **cronie**) on most Linux distributions.

This script is intended for people who want to automate Python scripts or other scheduled tasks but have not yet installed or configured the cron service.

> **Note**
> This script **does not** add jobs to your crontab. It only installs and prepares the cron service.

---

## Features

- Checks if the script is run with root privileges.
- Detects whether `crontab` is already installed.
- Installs cron automatically if it is missing.
- Supports multiple Linux distributions:
  - Ubuntu / Debian
  - Fedora
  - RHEL / CentOS
  - Arch Linux
  - openSUSE
- Detects whether the system uses `cron.service` or `crond.service`.
- Enables the cron service so it starts automatically after reboot.
- Starts the service if it is not already running.
- Displays the installed cron version (when supported).

---

## Supported Package Managers

| Distribution    | Package Manager | Package Installed |
|-----------------|-----------------|-------------------|
| Ubuntu / Debian | apt             | cron              |
| Fedora          | dnf             | cronie            |
| RHEL / CentOS   | yum             | cronie            |
| Arch Linux      | pacman          | cronie            |
| openSUSE        | zypper          | cron              |

---

## Requirements

- Linux
- systemd
- Root (sudo) privileges

---

## Usage

Make the script executable:

```bash
chmod +x setup_cron.sh
```

Run it as root:

```bash
sudo ./setup_cron.sh
```

---

## What the Script Does

1. Verifies the script is executed as root.
2. Checks whether `crontab` exists.
3. Installs cron if necessary.
4. Detects the correct cron service.
5. Enables the service.
6. Starts the service if it is stopped.
7. Confirms the service is running.
8. Prints the cron version (if available).

---

## Example Output

```text
Cron Setup Utility

✓ crontab is already installed.
Using service: cron
Enabling service...
✓ Service already running.

Cron setup completed successfully.
Version:
cronie 1.7.2
```

---

## After Running This Script

The cron service is now ready to use.

You can verify it by running:

```bash
systemctl status cron
```

or on some distributions:

```bash
systemctl status crond
```

To view your scheduled jobs:

```bash
crontab -l
```

To edit your scheduled jobs:

```bash
crontab -e
```

---

## Limitations

- Requires a system using **systemd**.
- Does not create scheduled jobs.
- Does not support non-systemd init systems such as OpenRC or SysV init.
- Assumes an active internet connection when installation is required.

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | An error occurred (missing permissions, unsupported distribution, installation failure, or service could not be started). |

---

## License

This project is released under the MIT License. Feel free to modify and use it in your own projects.

