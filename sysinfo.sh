#!/bin/bash
# sysinfo.sh - Display system information

# Function to display a horizontal line
horizontal_line() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# Get the Fully-Qualified Domain Name (FQDN)
fqdn=$(hostname -f)

# Get the operating system name and version
os_info=$(grep -oP 'NAME="[^"]+"' /etc/os-release)
os_version=$(grep -oP 'VERSION="[^"]+"' /etc/os-release)

# Get the default route IP address
ip_address=$(ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+')

# Get the root filesystem free space in a human-friendly format
free_space=$(df -h / | awk 'NR==2 {print $4}')

# Display the Fully-Qualified Domain Name
echo "FQDN: $fqdn"

# Display system information using hostnamectl
horizontal_line
echo "System Information:"
echo "Operating System: $os_info $os_version"
hostnamectl | grep -E 'Static hostname:|Architecture:'

# Display the IP address
horizontal_line
echo "IP Address:"
echo "IP Address: $ip_address"

# Display root filesystem status
horizontal_line
echo "Root Filesystem Status:"
echo "Root Filesystem Free Space: $free_space"

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
