# Cron Setup Utility

A small toolkit of two Bash scripts for managing **cron** (or **cronie**) on most Linux distributions, using either **systemd** or **OpenRC**: `setup_cron.sh` installs and enables it, `uninstall.sh` backs up every user's crontab and removes it.

This is intended for people who want to automate Python scripts or other scheduled tasks but have not yet installed or configured the cron service.

> **Note**
> `setup_cron.sh` **does not** add jobs to your crontab — it only installs and prepares the cron service. Once it's set up, see [`If_you_want_to_automate_python_file.md`](./If_you_want_to_automate_python_file.md) to schedule your Python script.

---

## Features

- Idempotent — safe to run more than once; steps that are already done (crontab installed, service enabled, service running) are detected and skipped.
- Works on both **systemd** and **OpenRC** (e.g. Alpine Linux) systems, automatically using `systemctl` or `rc-service`/`rc-update` as appropriate.
- Re-executes itself under `bash` automatically if invoked with `sh` or another shell.
- Checks if the script is run with root privileges.
- Detects whether `crontab` is already installed.
- Installs cron automatically if it is missing.
- Supports multiple Linux distributions:
  - Ubuntu / Debian
  - Fedora
  - RHEL / CentOS
  - Arch Linux
  - openSUSE
  - Alpine Linux
- Detects the correct cron service name for whichever init system is running.
- Enables the cron service so it starts automatically after reboot.
- Starts the service if it is not already running.
- Displays the installed cron version, falling back to the distro's package database if `crontab -V` isn't supported.
- Prints diagnostics automatically if the cron service fails to start, to help with troubleshooting.
- Supports `-q`/`--quiet` and `-h`/`--help` flags.

---

## Supported Init Systems

Both scripts detect which init system is running and use the matching tool — no need to tell them which one you're on:

| Init system | Detection | Service commands used |
|---|---|---|
| systemd | `/run/systemd/system` exists | `systemctl enable/start/stop/disable` |
| OpenRC (e.g. Alpine Linux) | `/run/openrc` exists, or `rc-service` is installed | `rc-update add/del`, `rc-service start/stop/status` |

If neither is detected (e.g. a system running plain SysVinit), the script exits with a message naming what it found instead of a generic error.

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

---

## Requirements

- Linux
- systemd or OpenRC
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
4. Detects the init system — systemd or OpenRC — and exits with a clear message if neither is found.
5. Checks whether `crontab` exists.
6. Installs cron (or cronie) if necessary.
7. Detects the correct cron service name (`cron`/`crond` on systemd; `crond`/`cronie`/`cron` on OpenRC).
8. Enables the service so it starts on boot (`systemctl enable`, or `rc-update add ... default`).
9. Starts the service if it isn't already running (`systemctl start`, or `rc-service ... start`).
10. Confirms the service is running, printing diagnostics if it failed to start.
11. Prints the cron version, unless `--quiet` was passed.

---

## Example Output

**On a systemd system:**

```text
Cron Setup Utility
Init system: systemd
✓ crontab is already installed.
Using service: cron
Enabling service...
✓ Service already running.

Cron setup completed successfully.
Cron implementation:
cronie 1.7.2
```

**On an OpenRC system (e.g. Alpine Linux):**

```text
Cron Setup Utility
Init system: openrc
✓ crontab is already installed.
Using service: crond
Enabling service...
 * service crond added to runlevel default
Starting service...
 * Starting crond ...

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

or, on some distributions:

```bash
systemctl status crond
```

or, on OpenRC systems (e.g. Alpine):

```bash
rc-service crond status
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

A companion script, `uninstall.sh`, removes cron/cronie from the system. Before touching anything else, it backs up **every user's** crontab (not just root's), since removing the cron package can wipe each user's scheduled jobs. Like `setup_cron.sh`, it works on both systemd and OpenRC.

### What It Does

1. Re-executes itself under `bash` if launched with a different shell.
2. Parses `--quiet` / `--help` options.
3. Verifies the script is executed as root.
4. Detects the init system — systemd or OpenRC — and exits with a clear message if neither is found.
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

**On a systemd system:**

```text
Cron Uninstall Utility
Init system: systemd
Backing up existing crontabs...
✓ Crontab backup saved to: /home/username/cron_backups/crontab_backup_20260728_153000.txt
Using service: cron
Stopping service...
Disabling service...
Removing cron...

Cron uninstall completed.
```

**On an OpenRC system (e.g. Alpine Linux):**

```text
Cron Uninstall Utility
Init system: openrc
Backing up existing crontabs...
✓ Crontab backup saved to: /home/username/cron_backups/crontab_backup_20260728_153000.txt
Using service: crond
Stopping service...
 * Stopping crond ...
Disabling service...
 * service crond removed from runlevel default
Removing cron...

Cron uninstall completed.
```

---

## Limitations

- Requires systemd or OpenRC; other init systems (e.g. plain SysVinit) are not supported.
- `setup_cron.sh` does not create scheduled jobs.
- `uninstall.sh` backs up each user's personal crontab only — it does not back up or remove `/etc/crontab` or `/etc/cron.d/` entries.
- Assumes an active internet connection when installation is required.

---

## Exit Codes

Applies to both `setup_cron.sh` and `uninstall.sh`.

| Code | Meaning |
|------|---------|
| 0 | Success, or `--help` was requested. |
| 1 | An error occurred (not run as root, no supported init system detected, unsupported distribution, unknown option, or the cron service could not be enabled/started/stopped/disabled). |
| *other* | Occasionally, a failure inside the package manager itself (e.g. `apt`, `dnf`) propagates that tool's own exit code instead of `1`. |

---

## License

This project is released under the MIT License. Feel free to modify and use it in your own projects.
