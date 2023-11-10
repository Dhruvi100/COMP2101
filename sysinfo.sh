#!/bin/bash
# sysinfo.sh - Display system information

# Function to display a horizontal line
horizontal_line() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires root privileges. Please run with sudo."
  exit 1
fi

# Function to handle errors
handle_error() {
  echo "Error: $1"
  exit 1
}

# Function to parse and format cache sizes
format_cache_sizes() {
  awk -F: '/Size/ {gsub(/[[:space:]]/, "", $2); print $2}' | tr '\n' ' '
}

# System Description Section
echo "System Description"
echo "------------------"
manufacturer=$(sudo dmidecode -t 1 | awk -F: '/Manufacturer/ {print $2}')
model=$(sudo dmidecode -t 1 | awk -F: '/Product Name/ {print $2}')
serial_number=$(sudo dmidecode -t 1 | awk -F: '/Serial Number/ {print $2}')
[ -z "$manufacturer" ] && handle_error "Computer manufacturer not available."
[ -z "$model" ] && handle_error "Computer model not available."
[ -z "$serial_number" ] && handle_error "Serial number not available."
echo "Manufacturer: $manufacturer"
echo "Model: $model"
echo "Serial Number: $serial_number"
echo

# CPU Information Section
echo "CPU Information"
echo "--------------"
cpu_manufacturer=$(lscpu | grep "Vendor ID" | awk -F: '{print $2}')
cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}')
cpu_architecture=$(lscpu | grep "Architecture" | awk -F: '{print $2}')
cpu_core_count=$(lscpu | grep "Core(s) per socket" | awk -F: '{print $2}')
cpu_max_speed=$(lscpu | grep "CPU max MHz" | awk -F: '{print $2}')
l1_cache=$(lscpu | grep "L1d cache" | format_cache_sizes)
l2_cache=$(lscpu | grep "L2 cache" | format_cache_sizes)
l3_cache=$(lscpu | grep "L3 cache" | format_cache_sizes)

[ -z "$cpu_manufacturer" ] && handle_error "CPU manufacturer not available."
[ -z "$cpu_model" ] && handle_error "CPU model not available."
[ -z "$cpu_architecture" ] && handle_error "CPU architecture not available."
[ -z "$cpu_core_count" ] && handle_error "CPU core count not available."
[ -z "$cpu_max_speed" ] && handle_error "CPU maximum speed not available."
[ -z "$l1_cache" ] && handle_error "L1 cache size not available."
[ -z "$l2_cache" ] && handle_error "L2 cache size not available."
[ -z "$l3_cache" ] && handle_error "L3 cache size not available."

echo "CPU Manufacturer: $cpu_manufacturer"
echo "CPU Model: $cpu_model"
echo "CPU Architecture: $cpu_architecture"
echo "CPU Core Count: $cpu_core_count"
echo "CPU Max Speed: $cpu_max_speed MHz"
echo "L1 Cache Size: $l1_cache"
echo "L2 Cache Size: $l2_cache"
echo "L3 Cache Size: $l3_cache"
echo

# Operating System Information Section
echo "Operating System Information"
echo "---------------------------"

if [ -e /etc/os-release ]; then
  . /etc/os-release
  echo "Linux Distro: ${NAME:-N/A}"
  echo "Distro Version: ${VERSION:-N/A}"
else
  handle_error "/etc/os-release not found, cannot retrieve OS information."
fi
