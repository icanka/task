#!/bin/bash

# Script to be scheduled
# Cron schedule (every <arg> minutes)

function setup_cron_scripts() {
    SCRIPT="cpu_mem.sh users.sh"
    SCHEDULE="*/$1 * * * *"
    for script_file in $SCRIPT; do
        script_file="$(realpath "$script_file")"
        # Check if the cron job already exists
        crontab -l | grep -F "$script_file" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Cron job for $script_file already exists."
        else
            # Make the script executable and add the cron job
            chmod +x "$script_file"
            echo "Script is now executable: $script_file"
            (
                crontab -l 2>/dev/null
                echo "$SCHEDULE $script_file"
            ) | crontab -
            echo "Cron job added: $SCHEDULE $script_file"
        fi
    done
}

function setup_collect() {
    collect_script="collect.sh"
    COLLECT_SCHEDULE="0 22 * * *"
    collect_script="$(realpath "$collect_script")"
    crontab -l | grep -F "$collect_script" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Cron job for collect.sh already exists."
    else
        # Add the cron job
        chmod +x "$script_file"
        echo "Script is now executable: $script_file"
        (
            crontab -l 2>/dev/null
            echo "$COLLECT_SCHEDULE $collect_script"
        ) | crontab -
        echo "Cron job added: $COLLECT_SCHEDULE $collect_script"
    fi
}


#######################################################################################

function setup_rm() {
    function_string="$(cat <<'END'
function rm() {
    local rFlag=false
    local fFlag=false

    # Manually parse options
    echo "$@"
    for arg in "$@"; do
        if [[ $arg == -* ]]; then
            echo "arg: $arg"
            # Check each character in the option string
            for (( i=1; i<${#arg}; i++ )); do
                char="${arg:$i:1}"
                [[ $char == "r" ]] && rFlag=true
                [[ $char == "f" ]] && fFlag=true
            done
        fi
    done

    # Check if both -r and -f are set
    if [[ "$rFlag" == "true" && "$fFlag" == "true" ]]; then
        echo -n "Are you sure you want to delete? Type 'yes' to confirm: "
        read answer
        if [[ $answer != "yes" ]]; then
            echo "Operation cancelled."
            return
        fi
    fi

    # Execute the actual rm command with all original arguments
    command rm "$@"
}
END
)"
    # add multiline string to the end of user's .bashrc file if rm func. does not exist
    # not an exact match, but close enough
    if ! grep -q "function rm()" ~/.bashrc; then
        echo "$function_string" >> ~/.bashrc
    else
        echo "rm function already exists."
    fi
}

#######################################################################################

function setup_env_diff() {
    env_diff_script="$(cat <<'END'
#env_diff script
if [ -f /home/"$(whoami)"/env.txt ]; then
    mv /home/"$(whoami)"/env.txt /home/"$(whoami)"/env.txt.old
    printenv > /home/"$(whoami)"/env.txt
    # print the changes between the old and new env file
    diff /home/"$(whoami)"/env.txt.old /home/"$(whoami)"/env.txt
else
    printenv > /home/"$(whoami)"/env.txt
fi
END
)"
    # check at least one line of env_diff_script is in /etc/profile, multiline check is overkill
    if ! grep -q "#env_diff script" /etc/profile; then
        echo "$env_diff_script" | sudo tee -a /etc/profile
    else
        echo "env_diff_script already exists."
    fi
}


#######################################################################################
function usage(){
    echo "Usage: $0 [-s <cron schedule>] [-c] [-f] [-e] [-r]"
    echo "Options:"
    echo "  -s <minutes>     schedule for cpu_mem.sh and users.sh"
    echo "  -c                     setup collect.sh"
    echo "  -f                     setup rm function"
    echo "  -e                     setup env_diff.sh"
    echo "  -r                     remove all cron jobs"
    exit 1
}

while getopts ":s:cfer" opt; do
    case $opt in
        s)
            echo "setting up cron scripts"
            # print arg to the s option
            setup_cron_scripts "$OPTARG"
            ;;
        c)
            echo "setting up collect"
            setup_collect
            ;;
        r)
            echo "removing all cron jobs"
            crontab -r
            ;;
        f)
            echo "setting up rm"
            setup_rm
            ;;
        e)
            echo "setting up env_diff"
            setup_env_diff
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done


# if no flag is given, print usage
if [ $# -eq 0 ]; then
    usage
fi