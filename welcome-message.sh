#!/bin/bash
#
# This script produces a dynamic welcome message
# it should look like
#   Welcome to planet hostname, title name!

# Task 1: Use the variable $USER instead of the myname variable to get your name
# Task 2: Dynamically generate the value for your hostname variable using the hostname command - e.g. $(hostname)
# Task 3: Add the time and day of the week to the welcome message using the format shown below
#   Use a format like this:
#   It is weekday at HH:MM AM.
# Task 4: Set the title using the day of the week
#   e.g. On Monday it might be Optimist, Tuesday might be Realist, Wednesday might be Pessimist, etc.
#   You will need multiple tests to set a title
#   Invent your own titles, do not use the ones from this example

###############
# Variables   #
###############

# Task 1: Use the variable $USER to get your name
myname="$USER"

# Task 2: Dynamically generate the value for your hostname variable
hostname="$(hostname)"

# Task 3: Add the time and day of the week to the welcome message
current_time="$(date +'%I:%M %p')"
day_of_week="$(date +'%A')"
welcome_message="It is $day_of_week at $current_time."

# Task 4: Set the title based on the day of the week
case "$day_of_week" in
  "Monday") title="Practical" ;;
  "Tuesday") title="Cheerful" ;;
  "Wednesday") title="Cloudy" ;;
  "Thursday") title="Dreamer" ;;
  "Friday") title="Adventurer" ;;
  "Saturday") title="Explorer" ;;
  "Sunday") title="Sunny" ;;
  *) title="Unknown" ;;
esac

###############
# Main        #
###############
cat <<EOF

Welcome to planet $hostname, "$title $myname!"
$welcome_message

EOF
