#!/bin/bash
##
## neo-jgrec, 2023
## lem_in
## File description:
## tester
##

# Number of test cases to generate
num_test_cases=9

# Set timeout in seconds (default 20)
TIMEOUT=20

help() {
    echo "Usage: ./tester.sh"
    echo "-h --help: Display this help"
    echo
    echo "You must have a lem_in binary in the current directory"
}

# Check if help is asked
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help
    exit 0
fi

if [ ! -f lem_in ]; then
    echo "lem_in executable not found"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to generate a random anthill input
generate_input() {
    local size=$((RANDOM % 100 + 100))
    local density=$((RANDOM % 100 + 10))
    local num_ants=$((RANDOM % 100 + 10))

    local home=$((RANDOM % size))
    local end=$((RANDOM % size))
    while [ $end -eq $home ]; do
        end=$((RANDOM % size))
    done

    echo $num_ants
    for ((i = 0; i < size; i++)); do
        [[ $i -eq $home ]] && echo "##start"
        [[ $i -eq $end ]] && echo "##end"
        echo "${i} $((RANDOM % (10 * size))) $((RANDOM % (10 * size)))"
    done

    for ((i = 0; i < size; i++)); do
        for ((j = 0; j < size; j++)); do
            if [ $((RANDOM % 100)) -lt $density ]; then
                echo "${i}-${j}"
            fi
        done
    done
}

# Function to generate the expected output for a given input
generate_expected_output() {
    local input="$1"
    # Replace the following command with the correct invocation of your program
    echo "$input" | ./lem_in
}

# Generate test cases and expected outputs
for i in $(seq 1 $num_test_cases); do
    input=$(generate_input)
    expected_output=$(generate_expected_output "$input")
    echo "$input" > "input${i}.txt"
    echo "$expected_output" > "output${i}.txt"
done

# Run tests
for i in $(seq 1 $num_test_cases); do
    input="input${i}.txt"
    expected_output="output${i}.txt"

    # Run the program with a timeout
    output=$(timeout $TIMEOUT ./lem_in < "$input")

    if [ $? -eq 124 ]; then
        echo -e "Test $i: ${RED}TIMEOUT${NC}"

    elif [ "$output" == "$(cat "$expected_output")" ]; then
        echo -e "Test $i: ${GREEN}OK${NC}"
        rm "$input" "$expected_output"
    else
        echo -en "Test $i: ${RED}KO${NC} - "
        mkdir -p "/tmp/lem_in_test_${i}"
        mv "$input" "$expected_output" "/tmp/lem_in_test_${i}"
        echo -e "Check output in ${YELLOW}/tmp/lem_in_test_${i}${NC}"
    fi
done
