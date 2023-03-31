#!/bin/bash
##
## neo-jgrec, 2023
## pushswap
## File description:
## tester
##

# Set timeout in seconds (default 20)
TIMEOUT=20

help() {
    echo "Usage: ./tester.sh"
    echo "-h --help: Display this help"
    echo
    echo "You must have a push_swap binary in the current directory and files directory"
}

# Check if help is asked
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help
    exit 0
fi

# Check if every file is present
if [ ! -f "push_swap" ]; then
    echo "push_swap binary not found"
    exit 1
fi
if [ ! -d "files" ]; then
    echo "files directory not found"
    exit 1
fi

# Check if the python checker is present
if [ ! -f "solver.py" ]; then
    echo "solver.py not found"
    exit 1
fi

for file in files/*; do
    file_name="$(basename $file)"

    start_time=$(date +%s+%N)
    timeout $TIMEOUT ./push_swap $(cat $file) > /tmp/pushswap_output || echo -e "$file_name: \033[0;31mTIMEOUT\033[0m" || continue
    end_time=$(date +%s+%N)
    exec_time=$(echo "scale=3; ($end_time - $start_time) / 1000000000" | bc)
    if [ ${exec_time:0:1} = "." ]; then exec_time="0$exec_time"
    fi

    numbers=$(cat $file) > /tmp/input
    instructions=$(cat /tmp/pushswap_output) >> /tmp/input
    start_time_py=$(date +%s+%N)
    result=$(python3 solver.py /tmp/input)
    end_time_py=$(date +%s+%N)
    exec_time_py=$(echo "scale=3; ($end_time_py - $start_time_py) / 1000000000" | bc)
    if [ ${exec_time_py:0:1} = "." ]; then exec_time_py="0$exec_time_py"
    fi
    rm /tmp/input

    if [ "$result" = "1" ]; then
        echo -e "$file_name: \e[32mOK\e[0m ($(echo $exec_time)s, checker: $(echo $exec_time_py)s)"
    else
        echo -e "$file_name: \e[31mKO\e[0m ($(echo $exec_time)s, checker: $(echo $exec_time_py)s)"
    fi
done

rm -r /tmp/pushswap_output
