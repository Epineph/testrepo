#!/bin/bash

# Function to copy and rename files to /usr/local/bin/
copy_and_rename_files() {
    local target_dir="/usr/local/bin/"

    # Loop through all .sh and .py files in the current directory
    for file in *.sh *.py; do
        # Check if the file is a regular file
        if [ -f "$file" ]; then
            # Remove the extension from the filename
            local base_name=$(basename "$file" .sh)
            base_name=$(basename "$base_name" .py)
            # Copy the file to the target directory with the new name
            cp "$file" "$target_dir/$base_name"
        fi
    done
}

# Call the function
copy_and_rename_files