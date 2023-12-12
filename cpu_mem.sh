#!/bin/sh

current_time=$(date +"%Y-%m-%d %H:%M:%S")
avg_cpu_load_15min="$(top -bn1 | grep "load average" | awk '{print $NF}')"
ram_usage="$(free --mega | grep -E "Mem" | awk '{print $3}')"
swap_usage="$(free --mega | grep -E "Swap" | awk '{print $3}')"
disk_usage="$(df -h | awk '$NF=="/"{printf "%s/%s %s", $3,$2,$5}')"

free --mega | grep -E "Mem" | awk '{print $3}'
echo "$ram_usage"
echo "$swap_usage"
echo "$current_time - CPU: $avg_cpu_load_15min% - RAM: $ram_usage - Swap: $swap_usage - Disk: $disk_usage" >> /tmp/perf_logs.txt