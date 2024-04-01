#!/bin/bash

# Environment variables and their defaults
source_directory="${SOURCE_DIRECTORY:-/data}"
sleep_time="${SLEEP_TIME:-3600}" # Default to 3600 seconds (1 hour)
do_not_use_markers="${DO_NOT_USE_MARKERS:-false}"
overwrite_files="${OVERWRITE_FILES:-false}"
extract_to_directory="${EXTRACT_TO_DIRECTORY:-}"
delete_rar_after_extraction="${DELETE_RAR_AFTER_EXTRACTION:-false}"

# Check for 'unrar' dependency
if ! command -v unrar &> /dev/null; then
    echo "Error: 'unrar' is not installed. Please install 'unrar' to use this script."
    exit 1
fi

# Check and create the specific output directory if specified
if [ -n "$extract_to_directory" ] && [ ! -d "$extract_to_directory" ]; then
    echo "Output directory $extract_to_directory does not exist. Attempting to create..."
    mkdir -p "$extract_to_directory"
    if [ $? -ne 0 ]; then
        echo "Critical Error: Failed to create directory $extract_to_directory. Exiting script."
        exit 1
    fi
fi

# Function to extract RAR files, handling errors and retries
extract_rars() {
    find "$source_directory" -type f \( -name "*.rar" -o -name "*.part01.rar" \) -print0 | while IFS= read -r -d $'\0' rarfile; do
        base_dir=$(dirname "$rarfile")
        output_dir="${extract_to_directory:-$base_dir}"
        rar_base_name=$(basename "$rarfile" .rar | sed 's/.part01//')

        # Adjusted marker file names to include the RAR base name
        marker_file="$base_dir/${rar_base_name}.extracted.marker"
        errormarker_file="$base_dir/${rar_base_name}.extracted.error"
        errorskipmarker_file="$base_dir/${rar_base_name}.extracted.errorskip"

        if [ "$do_not_use_markers" = "false" ]; then
            if [ -f "$marker_file" ] || [ -f "$errorskipmarker_file" ]; then
                continue # Skip if markers for this archive are present
            fi
        fi

        # Determine overwrite option
        overwrite_flag=""
        if [ "$overwrite_files" = "true" ]; then
            overwrite_flag="-o+"
        else
            overwrite_flag="-o-"
        fi

        # Attempt extraction and handle errors
        echo -e "\n\nAttempting to extract: $rarfile to $output_dir"
        if unrar x $overwrite_flag "$rarfile" "$output_dir/"; then
            if [ "$do_not_use_markers" = "false" ]; then
                touch "$marker_file"
            fi
            [ -f "$errormarker_file" ] && rm "$errormarker_file"
            if [ "$delete_rar_after_extraction" = "true" ]; then
                rm "$rarfile" # Delete the main rar file
                [[ "$rarfile" =~ .part01.rar$ ]] && rm "${rarfile%part01.rar}"part*.rar
            fi
        else
            if [ "$do_not_use_markers" = "false" ]; then
                if [ -f "$errormarker_file" ]; then
                    retries=$(cat "$errormarker_file")
                    ((retries++))
                    echo $retries > "$errormarker_file"
                    if [ $retries -ge 5 ]; then
                        mv "$errormarker_file" "$errorskipmarker_file"
                    fi
                else
                    echo 1 > "$errormarker_file"
                fi
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
