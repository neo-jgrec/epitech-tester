#!/usr/bin/env expect
##
## neo-jgrec, 2023
## sokoban
## File description:
## tester
##

# Set timeout in seconds (default 60)
set timeout 60

spawn ./my_sokoban maps/level1

sleep 0.5

send -- "\033\[B"

sleep 0.5

expect "map_pattern"

puts "$expect_out(buffer)"

# Close the process
close
