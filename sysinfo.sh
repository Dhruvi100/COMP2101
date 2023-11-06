#!/bin/bash
# sysinfo.sh - Display system information

# Function to display a horizontal line
horizontal_line() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# Display the Fully-Qualified Domain Name (FQDN)
echo "FQDN: $(hostname -f)"

# Display host information using hostnamectl
horizontal_line
echo "Host Information:"
hostnamectl | grep -E 'Static hostname:|Icon name:|Chassis:|Machine ID:|Boot ID:|Operating System:|Kernel:|Architecture:'

# Display IP addresses (excluding the 127 network) using hostname
horizontal_line
echo "IP Addresses:"
hostname -I | tr ' ' '\n' | grep -v '^127'

# Display root filesystem status using df
horizontal_line
echo "Root Filesystem Status:"
df -h / | tail -n 1
