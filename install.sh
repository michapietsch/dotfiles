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
PROTECTED_FOLDERS=(".config" "atuin")

is_protected_folder() {
	local name="$1"
	for protected in "${PROTECTED_FOLDERS[@]}"; do
		if [ "$name" == "$protected" ]; then
			return 0
		fi
	done
	return 1
}

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

process_item() {
	local source_path="$1"
	local relative_path="$2"
	local item_name
	item_name=$(basename "$source_path")
	local target_path="$HOME/$relative_path"

	if is_protected_folder "$item_name" && [ -d "$source_path" ]; then
		echo "Handling protected folder: $relative_path"

		if [ -e "$target_path" ] && [ ! -d "$target_path" ]; then
			echo "Error: $target_path exists and is not a directory, skipping protected folder."
			return
		fi

		mkdir -p "$target_path"

		local child_path
		for child_path in "$source_path"/*; do
			local child_name
			child_name=$(basename "$child_path")
			if [ "$child_name" == "." ] || [ "$child_name" == ".." ]; then
				continue
			fi
			process_item "$child_path" "$relative_path/$child_name"
		done
	else
		link_config "$source_path" "$target_path"
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

			process_item "$item_path" "$item_name"
		done
	fi
done
