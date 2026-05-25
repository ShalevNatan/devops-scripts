#!/bin/bash

STATUS=0
LOGFILE="/tmp/health_check.log"
exec > >(tee -a $LOGFILE) 2>&1
echo "checking system status:"
echo "========================"
date '+%Y-%m-%d %H:%M:%S'
echo "========================"

check_disk() {
        local USAGE_CURRENT=$(df -h | grep ' /$' | awk '{gsub(/%/,""); print $5}')

        if [[ "$USAGE_CURRENT" -ge 80 ]]; then
                echo "[DISK]    CRITICAL — ${USAGE_CURRENT}% used"

                if [[ $STATUS -lt 2 ]]; then
                        STATUS=2
                fi

        elif [[ "$USAGE_CURRENT" -ge 60 ]]; then
                echo "[DISK]    WARNING  — ${USAGE_CURRENT}% used"

                if [[ $STATUS -lt 1 ]]; then
                        STATUS=1
                fi

        else
                echo "[DISK]    OK       — ${USAGE_CURRENT}% used"
        fi
}

check_memory() {
        local MEMORY_CURRENT=$(free -m | grep 'Mem:' | awk '{print $7}')

        if [[ "$MEMORY_CURRENT" -lt 200 ]]; then
                echo "[MEMORY]  CRITICAL — ${MEMORY_CURRENT}MB available"

                if [[ $STATUS -lt 2 ]]; then
                        STATUS=2
                fi

        elif [[ "$MEMORY_CURRENT" -lt 500 ]]; then
                echo "[MEMORY]  WARNING  — ${MEMORY_CURRENT}MB available"

                if [[ $STATUS -lt 1 ]]; then
                        STATUS=1
                fi

        else
                echo "[MEMORY]  OK       — ${MEMORY_CURRENT}MB available"
        fi
}

check_cpu() {
        local CPU_CURRENT=$(uptime | awk -F'load average: ' '{print $2}' | awk '{print $1}' | sed 's/,//')

        if [[ $(echo "$CPU_CURRENT >= 2.0" | bc) -eq 1 ]]; then
                echo "[CPU]     CRITICAL — load ${CPU_CURRENT}"

                if [[ $STATUS -lt 2 ]]; then
                        STATUS=2
                fi

        elif [[ $(echo "$CPU_CURRENT >= 1.0" | bc) -eq 1 ]]; then
                echo "[CPU]     WARNING  — load ${CPU_CURRENT}"

                if [[ $STATUS -lt 1 ]]; then
                        STATUS=1
                fi

        else
                echo "[CPU]     OK       — load ${CPU_CURRENT}"
        fi
}
check_process() {
        local PROCESS="$1"
        if pgrep -x "$PROCESS" > /dev/null; then
                echo "[PROC]    OK       — $PROCESS is running"
        else
                echo "[PROC]    CRITICAL — $PROCESS is not running"
                if [[ $STATUS -lt 2 ]]; then STATUS=2; fi
        fi
}

check_disk
check_memory
check_cpu
check_process "bash"

echo "========================" 
echo "Final STATUS: $STATUS"
exit $STATUS
