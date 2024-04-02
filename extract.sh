#!/bin/bash

# Environment variables and their defaults
source_directory="${SOURCE_DIRECTORY:-/data}"
sleep_time="${SLEEP_TIME:-3600}" # Default to 3600 seconds (1 hour)
do_not_use_markers="${DO_NOT_USE_MARKERS:-false}"
overwrite_files="${OVERWRITE_FILES:-false}"
extract_to_directory="${EXTRACT_TO_DIRECTORY:-}"
delete_rar_after_extraction="${DELETE_RAR_AFTER_EXTRACTION:-false}"

# Check for 'unrar' command availability
if ! command -v unrar &> /dev/null; then
    echo "Error: 'unrar' is not installed. Please install 'unrar' to use this script."
    exit 1
fi

# Create the output directory if it doesn't exist
if [ -n "$extract_to_directory" ] && [ ! -d "$extract_to_directory" ]; then
    echo "Output directory $extract_to_directory does not exist. Attempting to create..."
    mkdir -p "$extract_to_directory"
    if [ $? -ne 0 ]; then
        echo "Critical Error: Failed to create directory $extract_to_directory. Exiting script."
        exit 1
    fi
fi

# Function to extract RAR files, considering overwrite flag and handling errors
extract_rars() {
    find "$source_directory" -type f \( \( -name "*.rar" -and -not -name "*.part*.rar" \) -or -name "*.part01.rar" -or -name "*.part1.rar" \) -print0 | while IFS= read -r -d $'\0' rarfile; do
        base_dir=$(dirname "$rarfile")
        output_dir="${extract_to_directory:-$base_dir}"

        # Construct unique marker files for each archive file
        marker_file="$base_dir/$(basename "$rarfile").extracted.marker"
        errormarker_file="$base_dir/$(basename "$rarfile").extracted.error"
        errorskipmarker_file="$base_dir/$(basename "$rarfile").extracted.errorskip"

        if [ "$do_not_use_markers" = "false" ] && { [ -f "$marker_file" ] || [ -f "$errorskipmarker_file" ]; }; then
            continue # Skip if markers indicate extraction or skipping is warranted
        fi

        # Set the overwrite flag based on the environment variable
        overwrite_flag="-o-"
        if [ "$overwrite_files" = "true" ]; then
            overwrite_flag="-o+"
        fi

        echo -e "\n\nAttempting to extract: $rarfile to $output_dir"
        output=$(unrar x $overwrite_flag "$rarfile" "$output_dir/" 2>&1)
        result=$?
        
        if [ $result -eq 0 ]; then
            echo "Extraction successful: $rarfile"
            touch "$marker_file"
        else
            # Check output for indication of skipped files due to -o- flag
            if echo "$output" | grep -iE 'already exists|All OK|no files to extract'; then
                echo "Completed with file skips (existing files not overwritten): $rarfile"
                touch "$marker_file" # Still mark as successfully extracted
            else
                echo "Error extracting $rarfile"
                touch "$errormarker_file"
            fi
        fi

        if [ "$delete_rar_after_extraction" = "true" ]; then
            rm "$rarfile" # Delete the processed archive file
            if [[ "$rarfile" =~ \.part01\.rar$ ]] || [[ "$rarfile" =~ \.part1\.rar$ ]]; then
                base_name=$(basename "$rarfile" .rar | sed 's/.part[0-9][0-9]*//')
                find "$base_dir" -type f -regex ".*$base_name\.part[0-9]+\.rar" -exec rm {} +
            elif [[ "$rarfile" =~ \.rar$ ]]; then
                # Handle deletion for traditional multi-part archives
                base_name="${rarfile%.rar}"
                find "$base_dir" -type f -regex ".*$base_name\.[rR][0-9][0-9]" -exec rm {} +
            fi
        fi
    done
}



# Display ASCII art and welcome message
cat << "EOF"
   _____          __                    ____ ___     __________    _____ __________ 
  /  _  \  __ ___/  |_  ____           |    |   \____\______   \  /  _  \\______   \
 /  /_\  \|  |  \   __\/  _ \   ______ |    |   /    \|       _/ /  /_\  \|       _/
/    |    \  |  /|  | (  <_> ) /_____/ |    |  /   |  \    |   \/    |    \    |   \
\____|__  /____/ |__|  \____/          |______/|___|  /____|_  /\____|__  /____|_  /
        \/                                          \/       \/         \/       \/ 
Auto-UnRAR by nicxx2
Thank you for using my tool.
EOF

# Calculate hours and minutes from sleep_time for the welcome message
hours=$((sleep_time / 3600))
minutes=$(((sleep_time % 3600) / 60))

# Show initial message about check frequency
echo "Checks will be done every $hours hour(s) and $minutes minute(s)."

# Message about the log behavior
echo "Below it will show the extraction of the RAR files when the checking process is running."
echo "If nothing is shown below, it's because nothing was extracted yet, or files were already marked in the past using this tool and thus are skipped."


# Infinite loop to run extraction based on user-defined frequency
while true; do
    extract_rars

    sleep "$sleep_time"
done
