#!/bin/bash

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

# Function to format memory size in a human-friendly format
format_memory_size() {
  local size="$1"
  if [ -n "$size" ]; then
    if [ "$size" -gt 1048576 ]; then
      echo "$(bc <<< "scale=2; $size / 1048576") GB"
    elif [ "$size" -gt 1024 ]; then
      echo "$(bc <<< "scale=2; $size / 1024") MB"
    else
      echo "${size} KB"
    fi
  else
    echo "N/A"
  fi
}

# Function to format disk size in a human-friendly format
format_disk_size() {
  local size="$1"
  if [ -n "$size" ]; then
    if [[ "$size" =~ ^[0-9]+[KMGT]? ]]; then
      echo "$size KB"
    else
      echo "N/A"
    fi
  else
    echo "N/A"
  fi
}

# System Description Section
echo "System Description"
echo "------------------"
manufacturer=$(sudo dmidecode -t 1 | awk -F: '/Manufacturer/ {print $2}')
model=$(sudo dmidecode -t 1 | awk -F: '/Product Name/ {print $2}')
serial_number=$(sudo dmidecode -t 1 | awk -F: '/Serial Number/ {print $2}')

[ -n "$manufacturer" ] && echo "Manufacturer: $manufacturer" || echo "Manufacturer: N/A"
[ -n "$model" ] && echo "Model: $model" || echo "Model: N/A"
[ -n "$serial_number" ] && echo "Serial Number: $serial_number" || echo "Serial Number: N/A"

echo

# CPU Information Section
echo "CPU Information"
echo "--------------"
cpu_info=$(lscpu)
cpu_count=$(echo "$cpu_info" | grep -c "CPU(s):")
cpu_manufacturer=$(echo "$cpu_info" | grep "Vendor ID" | head -1 | awk -F: '{print $2}')
cpu_model=$(echo "$cpu_info" | grep "Model name" | head -1 | awk -F: '{print $2}')
cpu_architecture=$(echo "$cpu_info" | grep "Architecture" | head -1 | awk -F: '{print $2}')
cpu_core_count=$(echo "$cpu_info" | grep "Core(s) per socket" | head -1 | awk -F: '{print $2}')
l1_cache=$(echo "$cpu_info" | grep -oE 'L1d cache:\s+[0-9]+[KMGT]*')
l1_cache=${l1_cache#*:}
l1_cache=${l1_cache// /}
l2_cache=$(echo "$cpu_info" | grep -oE 'L2 cache:\s+[0-9]+[KMGT]*')
l2_cache=${l2_cache#*:}
l2_cache=${l2_cache// /}
l3_cache=$(echo "$cpu_info" | grep -oE 'L3 cache:\s+[0-9]+[KMGT]*')
l3_cache=${l3_cache#*:}
l3_cache=${l3_cache// /}

[ -n "$cpu_manufacturer" ] && echo "CPU Manufacturer: $cpu_manufacturer" || echo "CPU Manufacturer: N/A"
[ -n "$cpu_model" ] && echo "CPU Model: $cpu_model" || echo "CPU Model: N/A"
[ -n "$cpu_architecture" ] && echo "CPU Architecture: $cpu_architecture" || echo "CPU Architecture: N/A"
[ -n "$cpu_core_count" ] && echo "CPU Core Count (per CPU): $cpu_core_count" || echo "CPU Core Count: N/A"
[ -n "$l1_cache" ] && echo "L1 Cache Size: $l1_cache" || echo "L1 Cache Size: N/A"
[ -n "$l2_cache" ] && echo "L2 Cache Size: $l2_cache" || echo "L2 Cache Size: N/A"
[ -n "$l3_cache" ] && echo "L3 Cache Size: $l3_cache" || echo "L3 Cache Size: N/A"

# Operating System Information Section
echo "Operating System Information"
echo "---------------------------"

if [ -e /etc/os-release ]; then
  . /etc/os-release
fi

[ -n "$NAME" ] && echo "Linux Distro: $NAME" || echo "Linux Distro: N/A"
[ -n "$VERSION" ] && echo "Distro Version: $VERSION" || echo "Distro Version: N/A"

# RAM Information Section
echo "RAM Information"
echo "--------------"
total_memory=$(free -m | awk 'NR==2 {print $2}')
echo "Total RAM: $total_memory MB"

echo "Memory Components:"
echo -e "Manufacturer\tModel\tSize\tSpeed\tLocation"

# Display RAM details using dmidecode
ram_info=$(sudo dmidecode -t 17)
while IFS= read -r line; do
  if [[ $line == *"Size:"* ]]; then
    manufacturer=$(echo "$line" | grep -A3 "Size" | grep "Manufacturer" | awk -F: '{print $2}' | xargs)
    model=$(echo "$line" | grep -A3 "Size" | grep "Type" | awk -F: '{print $2}' | xargs)
    size=$(echo "$line" | grep -A3 "Size" | grep "Size" | awk -F: '{print $2}' | xargs)
    speed=$(echo "$line" | grep -A3 "Size" | grep "Speed" | awk -F: '{print $2}' | xargs)
    location=$(echo "$line" | grep -A3 "Size" | grep "Locator" | awk -F: '{print $2}' | xargs)
    
    [ -n "$manufacturer" ] && echo -e "$manufacturer\t$model\t$size\t$speed\t$location"
  fi
done <<< "$ram_info"

# Disk Storage Information Section
echo "Disk Storage Information"
echo "------------------------"
echo -e "Drive Manufacturer\tDrive Model\tDrive Size\tPartition Number\tMount Point\tFilesystem Size\tFilesystem Free Space"

# List disk drives using lsblk
lsblk -o NAME,SIZE,MODEL,MOUNTPOINT | grep -E '^[a-z]' | while read -r line; do
  drive_name=$(echo "$line" | awk '{print $1}')
  drive_size=$(echo "$line" | awk '{print $2}')
  drive_model=$(echo "$line" | awk '{print $3}')
  mount_point=$(echo "$line" | awk '{print $4}')

  # Get partition number and filesystem size/free space using df
  partition_number=""
  filesystem_size=""
  filesystem_free_space=""

  if [ -n "$mount_point" ]; then
    partition_number=$(df -h | grep "$mount_point" | awk '{print $1}')
    filesystem_size=$(df -h | grep "$mount_point" | awk '{print $2}')
    filesystem_free_space=$(df -h | grep "$mount_point" | awk '{print $4}')
  fi

  # Format drive size, filesystem size, and free space
  drive_size_formatted=$(format_disk_size "${drive_size}")
  filesystem_size_formatted=$(format_disk_size "${filesystem_size}")
  filesystem_free_space_formatted=$(format_disk_size "${filesystem_free_space}")

  echo -e "${drive_name}\t${drive_model}\t${drive_size_formatted}\t${partition_number}\t${mount_point}\t${filesystem_size_formatted}\t${filesystem_free_space_formatted}"
done
