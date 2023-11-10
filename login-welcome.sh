#!/bin/bash
#
# This script displays a welcome message using cowsay.

# Generate the welcome message
welcome_message="Welcome to planet $(hostname), \"$title $USER!\""

# Use cowsay to display the message
cowsay "$welcome_message"
