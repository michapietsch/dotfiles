#!/bin/bash
shopt -s nullglob
shopt -s dotglob

# This script symlinks configuration files from the dotfiles repository to the home directory.

if [ -z "$1" ]; then
    echo "Usage: $0 <system_folder>"
    exit 1
fi

SYSTEM_FOLDER="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$SCRIPT_DIR/$SYSTEM_FOLDER"

if [ ! -d "$SYSTEM_DIR" ]; then
    echo "Error: Directory $SYSTEM_DIR does not exist."
    exit 1
fi

# List of protected global config folders.
# The contents of these folders will be linked to the corresponding location in $HOME,
# but the folder itself will not be linked.
PROTECTED_FOLDERS=(".config")

# Function to link configs
link_config() {
    local source_path="$1"
    local target_path="$2"

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        echo "Error: $target_path already exists, skipping."
    else
        # Ensure parent directory of target exists
        mkdir -p "$(dirname "$target_path")"
        ln -s "$source_path" "$target_path"
        echo "Success: Linked $source_path to $target_path"
    fi
}

# Scan for packages in the system directory
for package_path in "$SYSTEM_DIR"/*; do
    if [ -d "$package_path" ]; then
        package_name=$(basename "$package_path")
        echo "Processing package: $package_name"

        # Scan the contents of the package directory
        for item_path in "$package_path"/*; do
            item_name=$(basename "$item_path")

            # Skip . and ..
            if [ "$item_name" == "." ] || [ "$item_name" == ".." ]; then
                continue
            fi

            is_protected=false
            for protected in "${PROTECTED_FOLDERS[@]}"; do
                if [ "$item_name" == "$protected" ]; then
                    is_protected=true
                    break
                fi
            done

            if $is_protected; then
                # Handle protected folders: link their children
                echo "Handling protected folder: $item_name"
                for sub_item_path in "$item_path"/*; do
                    sub_item_name=$(basename "$sub_item_path")
                    if [ "$sub_item_name" == "." ] || [ "$sub_item_name" == ".." ]; then
                        continue
                    fi
                    link_config "$sub_item_path" "$HOME/$item_name/$sub_item_name"
                done
            else
                # Handle regular files and directories: link them directly
                link_config "$item_path" "$HOME/$item_name"
            fi
        done
    fi
done
