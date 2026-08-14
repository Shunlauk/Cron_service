# Cron Setup Utility

Two small scripts that could run as Bash, Dash, ash or sh files to install, enable and uninstall **cron** (or **crond** or **cronie**) on most Linux distributions, by using either **systemd** or **OpenRC** (will add SysVinit later): `setup_cron.sh` installs and enables it; `uninstall.sh` backs up every user's crontab and removes it.

This is to help people who want to automate their script (in any language) scripts or schedule a task but have not completed their cron setup.


> **Note**

> `setup_cron.sh` is for configuring cron on your Linux distros, it **doesn't** add a job to your crontab. [`If_you_want_to_automate_your_file.md`](./If_you_want_to_automate_your_file.md) can help you with that.

---

## Features

- It's idempotent (safe to run more than once); even if setup was half completed, it can detect completed steps and skip them.
- Works on **systemd** and **OpenRC** (e.g. Alpine Linux) systems, using the appropriate tool for each.
- Written in POSIX `sh` — no bash-specific syntax, so it runs under `dash`, `busybox ash` or `bash` without any fallback error.
- Checks whether it's running with root privileges.
- Checks whether `crontab` or anything is missing, and installs or enables it if missing.
- Supports multiple Linux distributions:
  - Ubuntu / Debian
  - Fedora
  - RHEL / CentOS
  - Arch Linux
  - openSUSE
  - Alpine Linux
- Can detect the correct cron service name for whichever init system is used in your Linux distro.
- Enables the cron service, so it starts automatically at every reboot.
- Prints clean diagnostics automatically if the cron service fails to set up, for easy troubleshooting.
- Supports `-q`/`--quiet` and `-h`/`--help` flags.

---

## Supported Init Systems

Both scripts can detect which init system your OS is running, no extra input necessary:

| Init system | Detection | Service commands used |
|---|---|---|
| systemd | `/run/systemd/system` exists | `systemctl enable/start/stop/disable` |
| OpenRC (e.g. Alpine Linux) | `/run/openrc` exists, or `rc-service` is installed | `rc-update add/del`, `rc-service start/stop/status` |

If neither is detected (e.g. a system running plain SysVinit), it prints a clear error message for troubleshooting.

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
- A POSIX-compatible shell (`dash`, `bash`, or `busybox ash` all work — no bash required)
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

| Flag            | Description                      |
|-----------------|----------------------------------|
| `-q`, `--quiet` | Quiet mode; only shows errors.   |
| `-h`, `--help`  | Show usage information and exit. |

Example:

```bash
sudo ./setup_cron.sh --quiet
```

---

## What the Script Does

1. Parses `--quiet` / `--help` options.
2. Verifies the script is executed as root.
3. Detects the init system — systemd or OpenRC — and exits with a clear message if neither is found.
4. Checks whether `crontab` exists.
5. Installs cron (or cronie or crond) if necessary.
6. Detects the correct cron service name (`cron`/`crond`/`cronie` on both systemd and OpenRC).
7. Enables the service so it starts on boot (`systemctl enable`, or `rc-update add ... default`).
8. Starts the service if it isn't already running (`systemctl start`, or `rc-service ... start`).
9. Confirms the service is running, printing diagnostics if it failed to start.

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
Cron-setup was already Completed

Cron setup completed successfully.
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
```

**On Quiet Mode**

Nothing — no errors occur.

---

## After Running This Script

The cron service is now ready to use.

You can verify it by running:

```bash
systemctl status cron
```

```bash
systemctl status crond
```

```bash
systemctl status cronie
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

## Automating Your Script

Once cron is installed and running, this script's job is done — scheduling your script is a separate step. See [`If_you_want_to_automate_your_file.md`](./If_you_want_to_automate_your_file.md) for a full walkthrough, including how to:

- Find the full path to your interpreter, if your script needs one (and your virtual/version-manager environment's interpreter, if you use one)
- Find the full path to your script
- Write and install a crontab entry
- Use common cron schedule expressions (every 15 minutes, daily at 8 AM, etc.)
- Log your script's output to a file
- Troubleshoot a job that isn't running
- Remove a scheduled job

---

## Uninstalling Cron

A companion script, `uninstall.sh`, removes cron/cronie/crond from the system. Before it does anything, it backs up **every user's** crontab (not just root's), so no one needs to worry which jobs were automated and which weren't.

### What It Does

1. Parses `--quiet` / `--help` options.
2. Verifies the script is executed as root.
3. Detects the init system — systemd or OpenRC — and exits with a clear message if neither is found.
4. Backs up every account's crontab (any user with a non-empty crontab) to a single timestamped file (so it isn't overwritten if another user installs and uninstalls cron again).
5. Stops the cron service if it's running.
6. Disables the cron service if it's enabled.
7. Removes the cron/cronie package via the system package manager.

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

| Flag            | Description                      |
|-----------------|----------------------------------|
| `-q`, `--quiet` | Quiet mode; only shows errors.   |
| `-h`, `--help`  | Show usage information and exit. |

**Note**: The backup location is still printed, even with `-q`/`--quiet`. 

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

**On Quiet Mode**

`Crontab backup saved to: ...`

The location is still printed so that you don't need to look for it. 

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
