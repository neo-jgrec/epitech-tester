##
## neo-jgrec, 2023
## BSQ
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
if [ ! -f "bsq" ]; then
    echo "bsq binary not found"
    exit 1
fi
if [ ! -d "mouli_maps" ]; then
    echo "mouli_maps directory not found"
    exit 1
fi
if [ ! -d "mouli_maps_solved" ]; then
    echo "mouli_maps_solved directory not found"
    exit 1
fi

for map in mouli_maps/*; do
    map_name=$(basename $map)
    solved_map=mouli_maps_solved/$map_name
    if [ ! -f $solved_map ]; then
        echo "Solved map not found for $map_name"
        continue
    fi
    start_time=$(date +%s+%N)
    timeout $TIMEOUT ./bsq $map > /tmp/bsq_output
    sed -i 's/[^[:print:]]//g' /tmp/bsq_output
    echo -n "$map_name: "
    exec_time=$(echo "scale=3; ($(date +%s+%N) - $start_time) / 1000000000" | bc)
    if [ $(echo $exec_time | cut -c 1) = "." ]; then
        exec_time="0$exec_time"
    fi
    diff /tmp/bsq_output $solved_map > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[0;32mOK\033[0m ($(echo $exec_time)s)"
    else
        echo -e "\033[0;31mKO\033[0m - "
        mkdir -p /tmp/bsq_output_$map_name
        cp /tmp/bsq_output /tmp/bsq_output_$map_name/bsq_output
        cp $solved_map /tmp/bsq_output_$map_name/solved_map
        echo "Check output in /tmp/bsq_output_$map_name"
    fi
done

rm /tmp/bsq_output
