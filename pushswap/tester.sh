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

echo -e "\e[33mDISCLAIMER:\e[0m The python script used to check if the instructions are valid may be slow. Be patient."

for file in files/*; do
    file_name="$(basename $file)"

    start_time=$(date +%s+%N)
    timeout $TIMEOUT ./push_swap $(cat $file) > /tmp/pushswap_output || echo -e "$file_name: \033[0;31mTIMEOUT\033[0m" || continue
    end_time=$(date +%s+%N)
    exec_time=$(echo "scale=3; ($end_time - $start_time) / 1000000000" | bc)
    if [ ${exec_time:0:1} = "." ]; then exec_time="0$exec_time"
    fi

    numbers=$(cat $file)
    echo $numbers > /tmp/numbers
    instructions=$(cat /tmp/pushswap_output)
    echo $instructions > /tmp/instructions
    # each instruction is separated by a space
    instructions_nb=$(echo $instructions | wc -w)

    result=$(python3 solver.py /tmp/numbers /tmp/instructions)
    rm /tmp/numbers /tmp/instructions

    if [ "$result" = "1" ]; then
        echo -e "$file_name: \e[32mOK\e[0m ($(echo $exec_time)s, $instructions_nb instructions)"
    else
        echo -e "$file_name: \e[31mKO\e[0m ($(echo $exec_time)s, $instructions_nb instructions)"
    fi
done

rm -r /tmp/pushswap_output
