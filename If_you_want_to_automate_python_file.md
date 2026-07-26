---

# Automating a Python Script

Once the cron service is installed and running, you can schedule your Python scripts to run automatically.

## 1. Find the Python Interpreter

Different systems may install Python in different locations. Find the full path by running: 

```bash
which python3
```

Example:

```text
/usr/bin/python3
```

---

## 2. Find the Full Path to Your Script

Use:

```bash
realpath my_script.py
```

Example:

```text
/home/username/projects/my_script.py
```

---

## 3. Edit Your Crontab

Open your personal crontab:

```bash
crontab -e
```

If prompted, choose your preferred text editor.

---

## 4. Add a Cron Job

A cron job follows this format:

```text
* * * * * command_to_execute
│ │ │ │ │
│ │ │ │ └── Day of week (0-7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

Example:

Run every day at **8:00 AM**

```cron
0 8 * * * /usr/bin/python3 /home/username/projects/my_script.py
```

Run every 15 minutes

```cron
*/15 * * * * /usr/bin/python3 /home/username/projects/my_script.py
```

Run every Sunday at 10:30 PM

```cron
30 22 * * 0 /usr/bin/python3 /home/username/projects/my_script.py
```

---

## 5. Save and Exit

After saving the file, cron automatically installs the new schedule.

You can verify it with:

```bash
crontab -l
```

---

## Redirecting Output to a Log File

If you want to keep a log of your script's output:

```cron
0 8 * * * /usr/bin/python3 /home/username/projects/my_script.py >> /home/username/logs/script.log 2>&1
```

- `>>` appends standard output to the log file.
- `2>&1` redirects error messages to the same log file.

---

## Using a Virtual Environment

If your project uses a virtual environment, use the Python executable inside it instead of the system Python.

Example:

```cron
0 8 * * * /home/username/project/venv/bin/python /home/username/project/main.py
```

Find the interpreter with:

```bash
which python
```

while the virtual environment is activated.

---

## Useful Cron Expressions

| Schedule                 | Expression     |
|--------------------------|----------------|
| Every minute             | `* * * * *`    |
| Every 5 minutes          | `*/5 * * * *`  |
| Every 15 minutes         | `*/15 * * * *` |
| Every hour               | `0 * * * *`    |
| Every day at midnight    | `0 0 * * *`    |
| Every day at 8 AM        | `0 8 * * *`    |
| Every Monday             | `0 0 * * 1`    |
| Every Sunday             | `0 0 * * 0`    |
| First day of every month | `0 0 1 * *`    |

---

## Troubleshooting

### My script doesn't run

- Make sure you're using the **full path** to both Python and your script.
- Check that the cron service is running:

```bash
systemctl status cron
```

or

```bash
systemctl status crond
```

- Check your crontab:

```bash
crontab -l
```

- Test the script manually:

```bash
/usr/bin/python3 /home/username/projects/my_script.py
```

If it works manually but not through cron, the issue is often an incorrect path or missing environment variables.

---

## Removing a Scheduled Job

Edit your crontab:

```bash
crontab -e
```

Delete the line containing the job, then save the file.

To remove **all** scheduled jobs:

```bash
crontab -r
```

> **Warning:** `crontab -r` permanently deletes all cron jobs for the current user.
