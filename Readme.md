# Cron Setup Utility

A small toolkit of two Bash scripts for managing **cron** (or **cronie**) on most Linux distributions: `setup_cron.sh` installs and enables it, `uninstall.sh` backs up every user's crontab and removes it.

This is intended for people who want to automate Python scripts or other scheduled tasks but have not yet installed or configured the cron service.

> **Note**
> `setup_cron.sh` **does not** add jobs to your crontab — it only installs and prepares the cron service. Once it's set up, see [`If_you_want_to_automate_python_file.md`](./If_you_want_to_automate_python_file.md) to schedule your Python script.

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

| Flag            | Description                                                        |
|-----------------|---------------------------------------------------------------------|
| `-q`, `--quiet` | Suppress progress output; only errors and the exit code are shown  |
| `-h`, `--help`  | Show usage information and exit                                    |

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

## Uninstalling Cron

A companion script, `uninstall.sh`, removes cron/cronie from the system. Before touching anything else, it backs up **every user's** crontab (not just root's), since removing the cron package can wipe each user's scheduled jobs.

### What It Does

1. Re-executes itself under `bash` if launched with a different shell.
2. Parses `--quiet` / `--help` options.
3. Verifies the script is executed as root.
4. Verifies the system is running systemd.
5. Backs up every account's crontab (any user with a non-empty crontab) to a single timestamped file.
6. Stops the cron service if it's running.
7. Disables the cron service if it's enabled.
8. Removes the cron/cronie package via the system package manager.

### Usage

Make the script executable:

```bash
chmod +x uninstall.sh
```

Run it as root:

```bash
sudo ./uninstall.sh
```

### Options

| Flag            | Description                                                                    |
|-----------------|----------------------------------------------------------------------------------|
| `-q`, `--quiet` | Suppress progress output; errors and the backup file location are still shown  |
| `-h`, `--help`  | Show usage information and exit                                                |

### Crontab Backups

- Saved to `<home directory>/cron_backups/crontab_backup_YYYYMMDD_HHMMSS.txt`.
- If run with `sudo`, `<home directory>` is the invoking user's home directory (via `$SUDO_USER`), not root's — and the backup is `chown`'d back to that user so you're not left needing `sudo` to read your own backup.
- Includes every user account that has a non-empty crontab, each under its own `## User: <name>` heading.
- File permissions are set to `600` (owner read/write only).
- If no crontabs are found on the system, no backup file is created.
- Only covers each user's personal crontab (`crontab -l`) — it does not back up or touch `/etc/crontab` or files under `/etc/cron.d/`.

To restore a user's jobs from a backup, copy that user's section back out (without the `## User:` heading) and load it with:

```bash
crontab their_jobs.txt
```

### Example Output

```text
Cron Uninstall Utility
Backing up existing crontabs...
✓ Crontab backup saved to: /home/username/cron_backups/crontab_backup_20260728_153000.txt
Using service: cron
Stopping service...
Disabling service...
Removing cron...

Cron uninstall completed.
```

---

## Limitations

- Requires a system using **systemd**.
- `setup_cron.sh` does not create scheduled jobs.
- `uninstall.sh` backs up each user's personal crontab only — it does not back up or remove `/etc/crontab` or `/etc/cron.d/` entries.
- Does not support non-systemd init systems such as OpenRC or SysV init.
- Assumes an active internet connection when installation is required.

---

## Exit Codes

Applies to both `setup_cron.sh` and `uninstall.sh`.

| Code | Meaning |
|------|---------|
| 0 | Success, or `--help` was requested. |
| 1 | An error occurred (not run as root, systemd not detected, unsupported distribution, unknown option, or the cron service could not be enabled/started/stopped/disabled). |
| *other* | Occasionally, a failure inside the package manager itself (e.g. `apt`, `dnf`) propagates that tool's own exit code instead of `1`. |

---

## License

This project is released under the MIT License. Feel free to modify and use it in your own projects.
