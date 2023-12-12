#!/bin/sh

# mail service is assumed configured, exp: ssmtp

# variables - set them here
log_file="/tmp/perf_logs.txt"
users_file="/tmp/users.txt"
recipient="person@example.com"
from="your-email@example.com"


performance_table=""
if [ -f "$log_file" ]; then

        avg_cpu_usage="$(awk -F'CPU: ' '{print $2}' "$log_file" | awk -F'%' '{total += $1; count++} END {printf "%d\n", total/count}')"
        avg_ram_usage="$(awk -F'RAM: ' '{print $2}' "$log_file" | awk '{total += $1; count++} END {printf "%d\n", total/count}')"
        avg_swap_usage="$(awk -F'Swap: ' '{print $2}' "${log_file}" | awk '{total += $1; count++} END {print total/count}')"

        # First row of the table is the average of all the logs
        performance_table="<tr>"
        performance_table="${performance_table}<td>$(date +"%Y-%m-%d %H:%M:%S")</td>" # posix compliant addition
        performance_table="${performance_table}<td>${avg_cpu_usage}%</td>"
        performance_table="${performance_table}<td>${avg_ram_usage} MB</td>"
        performance_table="${performance_table}<td>${avg_swap_usage} MB</td>"
        performance_table="${performance_table}</tr>"

        # iterate over each line of the log file and create a table row for each line
        while read -r line; do
            performance_table="${performance_table}<tr>"
            performance_table="${performance_table}<td>$(echo "$line" | awk -F' - ' '{print $1}')</td>"
            performance_table="${performance_table}<td>$(echo "$line" | awk -F'CPU: ' '{print $2}' | awk -F'%' '{print $1}')%</td>"
            performance_table="${performance_table}<td>$(echo "$line" | awk -F'RAM: ' '{print $2}' | awk '{print $1}') MB</td>"
            performance_table="${performance_table}<td>$(echo "$line" | awk -F'Swap: ' '{print $2}' | awk '{print $1}') MB</td>"
            performance_table="${performance_table}</tr>" 
        done < "$log_file"

        # Generate report string
        # report_string="$(date +"%Y-%m-%d %H:%M:%S") - CPU: ${avg_cpu_usage}% - RAM: ${avg_ram_usage} MB - Swap: ${avg_swap_usage} MB"
        mv "$log_file" "$log_file-$(date +"%Y-%m-%d")"
fi
#echo "$report_string" | mailx -s "Daily System Performance Report" -r "$from" "$recipient" >/dev/null 2>&1  # posix compliant redirection

users_table=""
if [ -f "$users_file" ]; then
        while read -r user; do
            users_table="${users_table}<tr>"
            users_table="${users_table}<td>$user</td>"
            users_table="${users_table}</tr>"
        done < "$users_file"
        mv "$users_file" "$users_file-$(date +"%Y-%m-%d")"
fi
#echo "$users" | mailx -s "Logged in users today" -r "$from" "$recipient" >/dev/null 2>&1

# check if both tables are empty
if [ -z "$performance_table" ] && [ -z "$users_table" ]; then
    echo "Report is empty."
    subject="Daily Performance Report - Empty"
    html_report="<h2>Report is empty. You might want to check</h2>"
else
    echo "Report is not empty."
    subject="Daily Performance Report"
    # create a nice looking basic html report with some css style
    html_report="$(cat <<EOF
<!DOCTYPE html>
<html>
<head>
<style>
/* Basic Reset */
table {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 20px;
    font-family: Arial, sans-serif;
    color: #333;
}

/* Table Header */
th {
    background-color: #4CAF50;
    color: white;
    text-align: left;
    padding: 8px;
}

/* Table Rows */
td {
    padding: 8px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

/* Zebra Striping for Rows */
tr:nth-child(even) {
    background-color: #f2f2f2;
}

/* Hover Effect for Rows */
tr:hover {
    background-color: #ddd;
}

/* Responsive Adjustments */
@media screen and (max-width: 600px) {
    table {
        width: 100%;
    }
    th, td {
        padding: 10px;
        font-size: 14px;
    }
}
</style>
</head>
<body>
<table>
    <tr>
        <th>Date</th>
        <th>CPU Usage</th>
        <th>RAM Usage</th>
        <th>Swap Usage</th>
    </tr>
    $performance_table
</table>
<table>
    <tr>
        <th>User</th>
    </tr>
    $users_table
</table>
</body>
</html>
EOF
)"
fi

echo "$html_report" > report.html
echo "$html_report" | mailx -a "Content-Type: text/html" -s "$subject" -r "$from" "$recipient" >/dev/null 2>&1

