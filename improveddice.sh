#!/bin/bash
#
# this script rolls a pair of six-sided dice and displays both the rolls
#

# Task 1:
#  put the number of sides in a variable which is used as the range for the random number
#  put the bias, or minimum value for the generated number in another variable
#  roll the dice using the variables for the range and bias i.e. RANDOM % range + bias

# Define variables for the number of sides and bias for each die
num_sides=6
bias=1

# Rolling the dice using the defined variables
die1=$(( RANDOM % num_sides + bias ))
die2=$(( RANDOM % num_sides + bias ))

# Task 2:
#  generate the sum of the dice
#  generate the average of the dice

# Calculate the sum and average of the dice
sum=$(( die1 + die2 ))
average=$(( sum / 2 ))

#  display a summary of what was rolled, and what the results of your arithmetic were

echo "Rolling..."
echo "Die 1: $die1"
echo "Die 2: $die2"
echo "Sum of the dice: $sum"
echo "Average of the dice: $average"

# Tell the user we have started processing
echo "Rolling..."
# roll the dice and save the results
die1=$(( RANDOM % 6 + 1))
die2=$(( RANDOM % 6 + 1 ))
# display the results
echo "Rolled $die1, $die2"
