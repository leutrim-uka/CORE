#!/bin/bash
#
# Script Name: parallel_dataset_filtering.sh
#
# Description: This script processes JSON.xz files, extracts specific fields (coreId, title, subjects, topics, fullText)
#              for each document, and compresses the output into .xz files. Each of the new files contains only documents
#              where fullText != null.
#
# Author: Leutrim Uka
# Date: July 2024
#
# Usage: ./process_data.sh
#   - Ensure directories input_dir, and output_dir are set correctly.
#
# Dependencies: parallel, jq, xz.
#
# Notes: This script is designed to run on Unix-like systems. Tested on Ubuntu.
#

# Directory containing the json.xz files
input_dir="core_metadata"
# Directory to store the unzipped json files temporarily
temp_dir="temp_output_parallel_filtering"
# Directory to store the final filtered json files
output_dir="filtered_dataset"
# Log file path
log_file="parallel_processing_logs.log"

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') $@" >> "$log_file"
}

# Create directories if they don't exist
mkdir -p "$temp_dir"
mkdir -p "$output_dir"

# Find all .xz files in the input directory
shopt -s nullglob
xz_files=("$input_dir"/*.xz)

# Check if there are any .xz files
if [ ${#xz_files[@]} -eq 0 ]; then
  echo "No .xz files found in the input directory."
  exit 1
fi

# Function to process each file
process_file() {
  local xz_file="$1"
  local temp_dir="$2"
  local output_dir="$3"

  # Extract the base name of the .xz file (e.g., file.json.xz -> file.json)
  local base_name
  base_name=$(basename "$xz_file" .xz)

  # Log processing start
  log "Processing: $base_name"
  echo "Processing: $base_name"

  # Unzip the .xz file to the temporary directory
  xz -dkc "$xz_file" > "$temp_dir/$base_name"

  # Create a temporary file to store the filtered JSON content
  local temp_output_file="$temp_dir/$base_name.filtered"

  # Filter the JSON documents with non-null fullText and keep only specific fields
  jq -nc --slurpfile docs "$temp_dir/$base_name" '$docs[] | select(.fullText != null) | {coreId, title, fullText}' > "$temp_output_file"

  # Check if the temporary output file is empty
  if [ ! -s "$temp_output_file" ]; then
    log "No non-null fullText entries found in $base_name. Deleting empty file."
    rm "$temp_output_file"
  else
    # Compress the filtered JSON content and remove the temporary file
    local output_file="$output_dir/$base_name.xz"
    xz -z < "$temp_output_file" > "$output_file"
    rm "$temp_output_file"
    log "Processed: $base_name. Created $output_file"
    echo "Processed: $base_name"
  fi

  # Clean up temporary unzipped file
  rm "$temp_dir/$base_name"
}

# Run the processing sequentially (not in parallel)
for xz_file in "${xz_files[@]}"; do
  process_file "$xz_file" "$temp_dir" "$output_dir"
done

log "Processing complete. Processed ${#xz_files[@]} files."

# Remove temporary directory if empty
if [ -d "$temp_dir" ] && [ -z "$(ls -A "$temp_dir")" ]; then
  rm -r "$temp_dir"
  log "Removed temporary directory $temp_dir"
fi

echo "Processing complete. Processed ${#xz_files[@]} files. See $log_file for details."
