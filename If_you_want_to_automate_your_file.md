---

# Automating a Script with Cron

Once the cron service is installed and running, you can schedule scripts or programs — written in Python, Node.js, Bash, PHP, Perl, Ruby, or anything else — to run automatically.

## 1. Find Your Interpreter (or Executable) 

If your script needs an interpreter, find its full path with `which`:

```bash
which python3
which node
which ruby
which perl
which php
which bash
```

Example:

```text
/usr/bin/python3
```

If you're scheduling a compiled binary or a shell script with its own shebang line, you can skip this step and just make sure it's executable:

```bash
chmod +x my_program
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

This works the same way regardless of the language — `.py`, `.js`, `.sh`, `.rb`, `.php`, or a compiled binary with no extension at all.

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

The `command_to_execute` is just: the full path to your interpreter (if any), followed by the full path to your script or program. A few examples:

**Python** — run every day at **8:00 AM**

```cron
0 8 * * * /usr/bin/python3 /home/username/projects/my_script.py
```

**Node.js** — run every 15 minutes

```cron
*/15 * * * * /usr/bin/node /home/username/projects/my_script.js
```

**Bash script** — run every Sunday at 10:30 PM

```cron
30 22 * * 0 /bin/bash /home/username/projects/my_script.sh
```

**Ruby**
 
```cron
0 8 * * * /usr/bin/ruby /home/username/projects/my_script.rb
```
 
**PHP**
 
```cron
0 8 * * * /usr/bin/php /home/username/projects/my_script.php
```
 
**Compiled binary** (C, Go, Rust, etc. — no interpreter needed)
 
```cron
0 8 * * * /home/username/projects/my_program
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

If you want to keep a log of your script's output, this works the same way for every language:

```cron
0 8 * * * /usr/bin/python3 /home/username/projects/my_script.py >> /home/username/logs/script.log 2>&1
```

- `>>` appends standard output to the log file.
- `2>&1` redirects error messages to the same log file.

---

## Using a Virtual/Version-Manager Environment

Many languages have their own way of isolating dependencies or interpreter versions — point cron at the interpreter *inside* that environment rather than the system-wide one.

**Python virtual environment (venv)**
 
```cron
0 8 * * * /home/username/project/venv/bin/python /home/username/project/main.py
```

**Node.js via nvm**
 
```cron
0 8 * * * /home/username/.nvm/versions/node/v20.11.0/bin/node /home/username/project/main.js
```
 
**Ruby via rbenv/rvm**
 
```cron
0 8 * * * /home/username/.rbenv/versions/3.2.0/bin/ruby /home/username/project/main.rb
```

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

- Make sure you're using the **full path** to both the interpreter (if any) and your script — cron doesn't run with your normal shell's `PATH`.
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

- Test the command manually, exactly as it appears in your crontab:

```bash
/usr/bin/python3 /home/username/projects/my_script.py
```

If it works manually but not through cron, the issue is often an incorrect path or missing environment variables — cron jobs run with a much smaller set of environment variables than your interactive shell.

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
