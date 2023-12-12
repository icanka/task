# SYSReport

This project simply does the following things:

1. Report cpu and memory related averages.
2. Command checking and prompting user with "rm" command on 'r' and 'f' options.
3. Show Environment diff since the last login.
4. Show the users logged in to the system since the last report

## Usage

See also `./configure.sh -h` for help.

Options:

- `-s <min>`: set up performance log collecting scripts for every `<min>` minute.
- `-f`: Modifies user's `.bashrc` to override and take precedence over `rm` command.
- `-e`: Modifies `/etc/profile` for showing env diff over last login.
- `-c`: Sets up cron to run at 10PM every day to collect, create, and send report.
- `-r`: Remove users crons.

Example usage:
```./configure.sh -s 1 -cfe```

## TODO

- Add an option to revert every changes made to the system.
- User should give the cron time.
- Check the exact multiline string not just the first line when checking.
- Command check may be done with traps.
