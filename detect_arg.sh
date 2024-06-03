#!/bin/bash

input_string="$@"  # Use "$@" to capture all command-line arguments as a single string

# Split the input string by spaces
read -ra input_parts <<< "$input_string"

# Initialize variables
fw_input=""
mea_input=""

# Loop through each part and assign values based on prefix
for part in "${input_parts[@]}"; do
    if [[ $part =~ ^fw ]]; then
        fw_input="$part"
    elif [[ $part =~ ^MEA ]]; then
        mea_input="$part"
    else
        echo "Invalid input: Parts must start with 'fw' or 'MEA'."
        exit 1
    fi
done

# Output the extracted values
echo "fw_input: $fw_input"
echo "mea_input: $mea_input"
