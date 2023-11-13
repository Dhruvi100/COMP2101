#!/bin/bash

# Function to log error messages with a timestamp
errormessage() {
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] Error: $1" >&2
  echo "[$timestamp] Error: $1" >> /var/log/systeminfo.log
}

# Function to display help information
display_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h          Display help for your script and exit"
  echo "  -v          Run script verbosely, showing any errors to the user instead of sending them to the logfile"
  echo "  -system     Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
  echo "  -disk       Run only the diskreport"
  echo "  -network    Run only the networkreport"
  exit 0
}

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  errormessage "This script must be run with root privileges."
  exit 1
fi

# Source the function library
source "$(dirname "$0")/reportfunctions.sh"

# Default behavior: Run all reports
if [ "$#" -eq 0 ]; then
  computerreport
  osreport
  cpureport
  ramreport
  videoreport
  diskreport
  networkreport
fi

# Parse command line options
while getopts ":hvsystemdisknetwork" opt; do
  case $opt in
    h)
      display_help
      ;;
    v)
      verbose=true
      ;;
    system)
      computerreport
      osreport
      cpureport
      ramreport
      videoreport
      ;;
    disk)
      diskreport
      ;;
    network)
      networkreport
      ;;
    \?)
      errormessage "Invalid option: -$OPTARG"
      display_help
      ;;
    :)
      errormessage "Option -$OPTARG requires an argument."
      display_help
      ;;
  esac
done

# Exit if verbose flag is not set
if [ -z "$verbose" ]; then
  exit 0
fi
