#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

input_file=$1
output_file=$2

# Get the width and height of the input file
width=$(wc -w < $input_file)
height=$(wc -l < $input_file)
height=$(($height + 1))

# Create the PPM header
echo "P3" > $output_file
echo "$width $height" >> $output_file
echo "255" >> $output_file

# Convert each character to a color and write to the output file
while read -n 1 char; do
    if [ "$char" = "o" ]; then
        # Yellow
        echo "255 0 0" >> $output_file
    elif [ "$char" = "*" ]; then
        # White
        echo "255 255 255" >> $output_file
    elif [ "$char" = "X" ]; then
        # Black
        echo "0 0 0" >> $output_file
    fi
done < $input_file

# If terminal is kitty, display the image
if [ "$TERM" = "xterm-kitty" ]; then
    upscaled_image=$(mktemp)
    convert $output_file -resize 400% $upscaled_image
    kitty +kitten icat --align=left $upscaled_image
    rm $upscaled_image
fi
