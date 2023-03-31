##
## neo-jgrec, 2023
## antman
## File description:
## tester
##

# Set timeout in seconds (default 20)
TIMEOUT=20

help() {
    echo "Usage: ./tester.sh"
    echo "-h --help: Display this help"
    echo
    echo "You must have a bsq binary in the current directory and mouli_maps and mouli_maps_solved directories"
}

# Check if help is asked
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    help
    exit 0
fi

# Check if every file is present
if [ ! -f "antman" ] || [ ! -f "giantman" ]; then
    echo "antman or giantman binary not found"
    exit 1
fi
if [ ! -d "files" ]; then
    echo "files directory not found"
    exit 1
fi

for file in files/*; do
    file_name="$(basename $file)"
    start_time=$(date +%s+%N)
    file_type=$(echo $file_name | cut -d "." -f 2)

    if [ $file_type = "lyr" ] || [ $file_type = "txt" ]; then
        antman_option=1
    elif [ $file_type = "html" ]; then
        antman_option=2
    elif [ $file_type = "ppm" ]; then
        antman_option=3
    else
        echo "Unknown file type"
        continue
    fi

    start_antman=$(date +%s+%N)
    timeout $TIMEOUT ./antman $file $antman_option > /tmp/antman_output || echo "$file_name: \033[0;31mTIMEOUT\033[0m" || continue
    end_antman=$(date +%s+%N)
    start_giantman=$(date +%s+%N)
    timeout $TIMEOUT ./giantman /tmp/antman_output $antman_option > /tmp/giantman_output || echo "$file_name: \033[0;31mTIMEOUT\033[0m" || continue
    end_giantman=$(date +%s+%N)

    echo -n "$file_name: "
    exec_time_antman=$(echo "scale=3; ($end_antman - $start_antman) / 1000000000" | bc)
    exec_time_giantman=$(echo "scale=3; ($end_giantman - $start_giantman) / 1000000000" | bc)
    exec_time="Giantman: $(echo $exec_time_giantman)s - Antman: $(echo $exec_time_antman)s"
    if [ $(echo $exec_time | cut -c 1) = "." ]; then
        exec_time="0$exec_time"
    fi
    if [ $(echo $exec_time | cut -c 12) = "." ]; then
        exec_time="$(echo $exec_time | cut -c 1-11)0$(echo $exec_time | cut -c 12-)"
    fi
    diff /tmp/giantman_output $file > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[0;32mOK\033[0m ($(echo $exec_time)s)"
    elif [ $? -eq 1 ]; then
        echo -e "\033[0;31mKO\033[0m - "
        mkdir -p /tmp/antman_output_$file_name
        cp /tmp/antman_output /tmp/antman_output_$file_name/antman_output
        cp /tmp/giantman_output /tmp/antman_output_$file_name/giantman_output
        cp $file /tmp/antman_output_$file_name/file
    fi
done
