# Cron Setup Utility

A simple Bash script that installs and configures **cron** (or **cronie**) on most Linux distributions.

This script is intended for people who want to automate Python scripts or other scheduled tasks but have not yet installed or configured the cron service.

> **Note**
> This script **does not** add jobs to your crontab — it only installs and prepares the cron service. Once it's set up, see [`If_you_want_to_automate_python_file.md`](./If_you_want_to_automate_python_file.md) to schedule your Python script.

---

## Features

- Idempotent — safe to run more than once; steps that are already done (crontab installed, service enabled, service running) are detected and skipped.
- Re-executes itself under `bash` automatically if invoked with `sh` or another shell.
- Checks if the script is run with root privileges.
- Verifies the system is actually running systemd before doing anything.
- Detects whether `crontab` is already installed.
- Installs cron automatically if it is missing.
- Supports multiple Linux distributions:
  - Ubuntu / Debian
  - Fedora
  - RHEL / CentOS
  - Arch Linux
  - openSUSE
  - Alpine Linux
- Detects whether the system uses `cron.service` or `crond.service`.
- Enables the cron service so it starts automatically after reboot.
- Starts the service if it is not already running.
- Displays the installed cron version, falling back to the distro's package database if `crontab -V` isn't supported.
- Prints recent service logs automatically if the cron service fails to start, to help with troubleshooting.
- Supports `-q`/`--quiet` and `-h`/`--help` flags.

---

## Supported Package Managers

| Distribution    | Package Manager | Package Installed |
|-----------------|-----------------|-------------------|
| Ubuntu / Debian | apt             | cron              |
| Fedora          | dnf             | cronie            |
| RHEL / CentOS   | yum             | cronie            |
| Arch Linux      | pacman          | cronie            |
| openSUSE        | zypper          | cron              |
| Alpine Linux    | apk             | cronie            |

> Alpine Linux normally ships with OpenRC rather than systemd. Since this script requires systemd, the Alpine branch above only helps on a systemd-enabled Alpine setup.

---

## Requirements

- Linux
- systemd
- Bash (the script re-executes itself under `bash` automatically if run with `sh`)
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

### Options

| Flag            | Description                                                         |
|-----------------|---------------------------------------------------------------------|
| `-q`, `--quiet` | Suppress progress output; only errors and the exit code are shown   |
| `-h`, `--help`  | Show usage information and exit                                     |

Example:

```bash
sudo ./setup_cron.sh --quiet
```

---

## What the Script Does

1. Re-executes itself under `bash` if it was launched with a different shell (e.g. `sh`).
2. Parses `--quiet` / `--help` options.
3. Verifies the script is executed as root.
4. Verifies the system is running systemd.
5. Checks whether `crontab` exists.
6. Installs cron (or cronie) if necessary.
7. Detects the correct cron service (`cron` or `crond`).
8. Enables the service so it starts on boot.
9. Starts the service if it isn't already running.
10. Confirms the service is running, printing recent logs if it failed to start.
11. Prints the cron version, unless `--quiet` was passed.

---

## Example Output

```text
Cron Setup Utility
✓ crontab is already installed.
Using service: cron
Enabling service...
✓ Service already running.

Cron setup completed successfully.
Cron implementation:
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

## Automating Your Python Script

Once cron is installed and running, this script's job is done — scheduling your Python script is a separate step. See [`If_you_want_to_automate_python_file.md`](./If_you_want_to_automate_python_file.md) for a full walkthrough, including how to:

- Find the full path to your Python interpreter (and your virtual environment's interpreter, if you use one)
- Find the full path to your script
- Write and install a crontab entry
- Use common cron schedule expressions (every 15 minutes, daily at 8 AM, etc.)
- Log your script's output to a file
- Troubleshoot a job that isn't running
- Remove a scheduled job

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
| 0 | Success, or `--help` was requested. |
| 1 | An error occurred (not run as root, systemd not detected, unsupported distribution, installation failure, unknown option, or the cron service could not be enabled or started). |

---

## License

This project is released under the MIT License. Feel free to modify and use it in your own projects.
