# SYSReport

This project simply does the following things:

1. Report cpu and memory related averages. As a note, generated report by the `collect.sh` contains the average of all rows on the first line.
2. Command checking and prompting user with `rm` command on `r` and `f` options.
3. Show Environment diff since the last login. And also watch the `/etc` directory for `w` permission access with auditd.
It was unclear what was meant in the task with `changes in the environment`?
4. Show the users logged in to the system since the last report
 
## Usage

See also `./configure.sh -h` for help.

Options:

- `-s <min>`: set up performance log collecting scripts for every `<min>` minute.
- `-f`: Modifies user's `.bashrc` to override and take precedence over `rm` command.
- `-e`: Modifies `/etc/profile` for showing env diff over last login and a report over changes under /etc.
- `-c`: Sets up cron to run at 10PM every day to collect, create, and send report.
- `-r`: Remove users crons.

Example usage:

```bash
./configure.sh -s 1 -cfe
```

You can manually run scripts to generate report and then collect.

```bash
./cpu_mem.sh # generates perf_logs under /tmp
./users.sh   # generates user log in logs under /tmp
./collect.sh # also generates a .html report for viewing and rotates the log files
```

## TODO

- Add an option to revert every changes made to the system.
- User should give the cron time.
- Check the exact multiline string not just the first line when checking.
- Command check may be done with traps.
