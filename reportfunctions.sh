#!/bin/bash
# Function Library

# Function to display a title
display_title() {
  echo "=== $1 ==="
}

# Function to display labeled data
display_labeled_data() {
  echo "$1: $2"
}

# Function to display a table header for RAM components
display_ram_table_header() {
  echo "Component manufacturer | Component model | Component size | Component speed | Physical location"
}

# Function to display RAM component details in a table format
display_ram_component() {
  echo "$1 | $2 | $3 | $4 | $5"
}

# Function for cpureport containing
cpureport() {
  display_title "CPU Report"
  display_labeled_data "CPU manufacturer" "$(lscpu | grep "Vendor ID" | cut -d: -f2 | tr -s ' ')"
  display_labeled_data "CPU model" "$(lscpu | grep "Model name" | cut -d: -f2 | tr -s ' ')"
  display_labeled_data "CPU architecture" "$(lscpu | grep "Architecture" | cut -d: -f2 | tr -s ' ')"
  display_labeled_data "CPU core count" "$(nproc)"
  display_labeled_data "CPU maximum speed" "$(lscpu | grep "CPU max" | cut -d: -f2 | tr -s ' ')"
  display_labeled_data "L1 cache" "$(lscpu | grep "L1d cache" | cut -d: -f2 | tr -s ' ')"
  display_labeled_data "L2 cache" "$(lscpu | grep "L2 cache" | cut -d: -f2 | tr -s ' ')"
  display_labeled_data "L3 cache" "$(lscpu | grep "L3 cache" | cut -d: -f2 | tr -s ' ')"
}

# Function for computerreport containing
computerreport() {
  display_title "Computer Report"
  display_labeled_data "Computer manufacturer" "$(dmidecode -s system-manufacturer)"
  display_labeled_data "Computer description" "$(dmidecode -s system-product-name)"
  display_labeled_data "Computer serial number" "$(dmidecode -s system-serial-number)"
}

# Function for osreport containing
osreport() {
  display_title "OS Report"
  display_labeled_data "Linux distro" "$(lsb_release -i -s)"
  display_labeled_data "Distro version" "$(lsb_release -r -s)"
}

# Function for ramreport containing
ramreport() {
  display_title "RAM Report"
  display_ram_table_header
  while read -r line; do
    manufacturer=$(echo "$line" | awk '{print $1}')
    model=$(echo "$line" | awk '{print $2}')
    size=$(echo "$line" | awk '{print $3}')
    speed=$(echo "$line" | awk '{print $4}')
    location=$(echo "$line" | awk '{print $5}')
    display_ram_component "$manufacturer" "$model" "$size" "$speed" "$location"
  done < <(dmidecode -t 17 | awk -F ': ' '/Size: [0-9]+/ {print $2}' | sed 's/MB//g')
  total_size=$(dmidecode -t 17 | awk -F ': ' '/Size: [0-9]+/ {sum += $2} END {print sum " MB"}')
  display_labeled_data "Total RAM size" "$total_size"
}

# Function for videoreport containing
videoreport() {
  display_title "Video Report"
  display_labeled_data "Video card manufacturer" "$(lspci | grep -i vga | awk -F ': ' '{print $3}')"
  display_labeled_data "Video card model" "$(lspci | grep -i vga | awk -F ': ' '{print $4}')"
}

# Function for diskreport containing
diskreport() {
  display_title "Disk Report"
  lsblk --output "NAME,MAJ:MIN,SIZE,FSTYPE,MOUNTPOINT"
}

# Function for networkreport containing
networkreport() {
  display_title "Network Report"
  ip -o addr show
}

# Function for errormessage containing
errormessage() {
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] Error: $1" >&2
  echo "[$timestamp] Error: $1" >> /var/log/systeminfo.log
}
