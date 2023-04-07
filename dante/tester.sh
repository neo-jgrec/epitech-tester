#!/bin/bash
##
## neo-jgrec, 2023
## dante
## File description:
## tester
##

# Set timeout in seconds (default 20)
TIMEOUT=20

help() {
    echo "Usage: ./tester.sh"
    echo "-h --help: Display this help"
    echo
    echo "You must have a solver and generator binaries in the current directory, the generator will be tested thanks to the solver"
}

# Check if help is asked
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help
    exit 0
fi

# Check if every file is present
if [ ! -f "solver" ]; then
    echo "solver binary not found"
    exit 1
fi
if [ ! -f "generator" ]; then
    echo "generator binary not found"
    exit 1
fi

is_map_solvable() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found"
        exit 1
    fi
    cat $1 | grep "no solution found" > /dev/null
    if [ $? -eq 0 ]; then
        return 1
    else
        return 0
    fi
}

echo -e "\033[0;32mTesting generator\033[0m"
array_test=(\
    "10 10 perfect" \
    "10 10" \
    "10000 10000" \
    "10000 10000 perfect" \
    "50 50 perfect" \
    "50 50" \
    "100 100 perfect" \
)

mkdir -p /tmp/dante
for test in "${array_test[@]}"; do
    echo -n "$test: "
    timeout $TIMEOUT ./generator $test > /tmp/generator_output
    if [ $? -eq 124 ]; then
        echo -e "\033[0;31mTIMEOUT\033[0m"
        continue
    fi
    if [ $? -eq 0 ]; then
        if is_map_solvable /tmp/generator_output; then
            echo -e "\033[0;32mOK\033[0m"
        else
            echo -e "\033[0;31mKO\033[0m - Map is not solvable"
        fi
    else
        echo -e "\033[0;31mKO\033[0m - Generator failed"
    fi
done

echo -e "\033[0;32mTesting solver\033[0m"
array_test=(\
    "10 10 perfect" \
    "10 10" \
    "10000 10000" \
    "10000 10000 perfect" \
    "50 50 perfect" \
    "50 50" \
    "100 100 perfect" \
)

for test in "${array_test[@]}"; do
    echo -n "$test: "
    ./generator $test > /tmp/generator_output
    timeout $TIMEOUT ./solver /tmp/generator_output > /tmp/solver_output
    if [ $? -eq 124 ]; then
        echo -e "\033[0;31mTIMEOUT\033[0m"
        continue
    fi
    if [ $(cat /tmp/solver_output | wc -l) -eq 0 ]; then
        echo -e "\033[0;31mKO\033[0m - Solver failed"
    else
        if [ $(cat /tmp/solver_output | wc -l) -eq $(cat /tmp/generator_output | wc -l) ]; then
            echo -e "\033[0;32mOK\033[0m"
        else
            echo -e "\033[0;31mKO\033[0m - Solver failed"
        fi
    fi
done
