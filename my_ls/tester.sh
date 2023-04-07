##
## neo-jgrec, 2023
## my_ls
## File description:
## tester
##

# Set timeout in seconds (default 10)
TIMEOUT=10

help() {
    echo "Usage: ./tester.sh"
    echo "-h --help: Display this help"
    echo
    echo "You must have a my_ls binary in the current directory."
}

# Check if help is asked
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help
    exit 0
fi

# Check if every file is present
if [ ! -f "my_ls" ]; then
    echo "my_ls binary not found"
    exit 1
fi

# Here put argument for each ls test you want
tests_array=(
    "-l"    \
    ""      \
    "-la"   \
    "-a"    \
)

for test in "${tests_array[@]}"; do
    echo -en "ls $test\t : "
    time=$(date +%s)
    timeout $TIMEOUT ./my_ls $test > /tmp/my_ls_output
    timeout $TIMEOUT ls $test > /tmp/ls_output
    diff /tmp/my_ls_output /tmp/ls_output > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[0;32mOK\033[0m"
    else
        echo -en "\033[0;31mKO\033[0m - "
        mkdir -p "/tmp/ls_tester_output_$time"
        mv /tmp/my_ls_output /tmp/ls_tester_output_$time
        mv /tmp/ls_output /tmp/ls_tester_output_$time
        echo -e "Check /tmp/ls_tester_output_$time"
    fi
done
