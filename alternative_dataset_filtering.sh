#!/bin/bash
#
# Script Name: alternative_dataset_filtering.sh
#
# Description: This script processes JSON.xz files, extracts specific fields (coreId, title, subjects, topics, fullText)
#              for each document, and compresses the output into .xz files. Each of the new files contains only documents
#              where fullText != null.
#              This is an alternative script in case you don't have sudo rights to install the "parallel" package.
#
# Author: Leutrim Uka
# Date: July 2024
#
# Usage: ./process_data.sh
#   - Ensure directories input_dir, and output_dir are set correctly.
#
# Dependencies: Requires jq for JSON processing and xz utilities.
#
# Notes: This script is designed to run on Unix-like systems. Tested on Ubuntu.
#

# Directory containing the json.xz files
input_dir="core_metadata"
# Directory to store the final filtered json files as json.xz files
output_dir="output_jsons"

# Directory to store the unzipped json files temporarily - it will be deleted automatically
temp_dir="temp_json_filtering"
# Path to file for logging during execution
log_file="alt_filtering_logs.log"
# Maximum processes available for parallel processing - modify based on availability
max_processes=20


# Create directories if they don't exist
mkdir -p "$temp_dir"
mkdir -p "$output_dir"

# Create timestamps for logging - will preceed each event
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$log_file"
}

# Start execution
log "Script started execution."
echo "Script started execution."

# Find all .xz files in the input directory
shopt -s nullglob
xz_files=("$input_dir"/*.xz)

# Check the directory for .xz files. Exit if empty
if [ ${#xz_files[@]} -eq 0 ]; then
  log "No .xz files found in the input directory. Exiting."
  echo "No .xz files found in the input directory."
  exit 1
fi

# Function to process each file
process_file() {
  local xz_file="$1"
  local temp_dir="$2"
  local output_dir="$3"
  local base_name
  base_name=$(basename "$xz_file" .xz)

  # Log processing start for specific files
  log "Processing: $base_name"
  echo "Processing: $base_name"

  # Unzip the .xz file to the temporary directory set above
  xz -dkc "$xz_file" > "$temp_dir/$base_name"

  # Create a temporary file to store the filtered JSON content
  local temp_output_file="$temp_dir/$base_name.filtered"

  # Filter the JSON documents with non-null fullText and keep only specific fields
  jq -nc --slurpfile docs "$temp_dir/$base_name" '$docs[] | select(.fullText != null) | {id, title, fullText}' > "$temp_output_file"

  # Check if the temporary output file is empty
  if [ ! -s "$temp_output_file" ]; then
    log "No non-null fullText entries found in $base_name. Deleting empty file."
    rm "$temp_output_file"
  else
    # Compress the filtered JSON content and remove the temporary file
    local output_file="$output_dir/$base_name.xz"
    xz -z < "$temp_output_file" > "$output_file"
    rm "$temp_output_file"
    log "Processed $base_name and saved to $output_file"
  fi
  echo "Finished: $base_name"

  # Clean up temporary unzipped file
  rm "$temp_dir/$base_name"
}

current_processes=0

# Process each file in parallel
for xz_file in "${xz_files[@]}"; do
  # Start a new process
  process_file "$xz_file" "$temp_dir" "$output_dir" &
  ((current_processes++))

  # Limit the number of concurrent processes
  if [ "$current_processes" -ge "$max_processes" ]; then
    wait  # Wait for all background processes to finish (potential bottleneck?)
    current_processes=0
  fi
done

# Wait for remaining background processes to finish  
wait

log "Processing complete. Processed ${#xz_files[@]} files."
echo "Processing complete. Processed ${#xz_files[@]} files."

# Remove temporary directory if empty
if [ -d "$temp_dir" ] && [ -z "$(ls -A "$temp_dir")" ]; then
  rm -r "$temp_dir"
  log "Removed temporary directory $temp_dir"
fi

log "Script execution finished."
