#!/bin/bash

# Use environment variables with defaults
source_directory="${SOURCE_DIRECTORY:-/data}"
sleep_time="${SLEEP_TIME:-3600}" # Default to 3600 seconds (1 hour)

# Function to extract RAR files, skipping if already extracted
extract_rars() {
    find "$source_directory" -type f -name "*.rar" -print0 | while IFS= read -r -d $'\0' rarfile; do
        output_dir="${rarfile%/*.rar}"
        marker_file="$output_dir/extracted.marker"

        # Check if the marker file exists to determine if the archive has been extracted
        if [ ! -f "$marker_file" ]; then
            echo -e "\n\nAttempting to extract: $rarfile"
            # Use unrar or 7z to extract files
            unrar x -o- "$rarfile" "$output_dir/"

            touch "$marker_file"
        
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
