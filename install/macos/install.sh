#!/bin/bash

# Function to get the absolute path of the script's directory
get_script_dir() {
  SCRIPT_SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SCRIPT_SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" >/dev/null 2>&1 && pwd )"
    SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
    [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$DIR/$SCRIPT_SOURCE" # if $SCRIPT_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" >/dev/null 2>&1 && pwd )"
  echo "$DIR"
}

# Get the root directory of the repository
SCRIPT_DIR=$(get_script_dir)
REPO_ROOT=$(cd "$SCRIPT_DIR/../../" && pwd)

# Source the configuration file
CONFIG_FILE="$SCRIPT_DIR/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Flags
FORCE=false
COMMAND=""

for arg in "$@"; do
  if [ "$arg" = "--force" ]; then
    FORCE=true
  elif [ -z "$COMMAND" ]; then
    # Set COMMAND to the first non-force argument
    COMMAND=$arg
  else
    echo "Error: Too many commands. Usage: $0 [--force] [command]"
    exit 1
  fi
done

# Function to check if the destination exists
destination_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

# Function to clear the destination if force is enabled
clear_destination_if_forced() {
  if [ "$FORCE" = true ]; then
    if destination_exists "$1"; then
      echo "Removing existing config at $1 due to --force flag."
      rm -rf "$1"
    fi
  fi
}

# Function to create a symlink
create_symlink() {
  echo "Creating symlink for $1..."
  mkdir -p "$(dirname "$3")"
  ln -s "$2" "$3"
  echo "Config for $1 linked from $2 to $3."
}

# --- Main Installation Logic ---

# Build a list of available tool IDs for validation later
ALL_TOOL_IDS=$(echo "$CONFIG_DATA" | sed '/^$/d' | cut -d';' -f1)

# Read the config data line by line
echo "$CONFIG_DATA" | while IFS=';' read -r tool_id name src dst; do
  # Skip empty lines in the string
  [ -z "$tool_id" ] && continue

  # Check if we should install this tool
  if [ -z "$COMMAND" ] || [ "$COMMAND" = "$tool_id" ]; then
    
    echo "--- Installing $name config... ---"
    
    CONFIG_SOURCE="$REPO_ROOT/$src"
    CONFIG_DEST="$HOME/$dst"

    clear_destination_if_forced "$CONFIG_DEST"

    if destination_exists "$CONFIG_DEST"; then
      echo "$name config already exists at $CONFIG_DEST. Skipping."
      echo "Use --force to overwrite."
    else
      create_symlink "$name" "$CONFIG_SOURCE" "$CONFIG_DEST"
    fi
    echo # Add a newline for better readability
  fi
done

# If a command was specified but not found, show an error.
if [ -n "$COMMAND" ] && ! echo "$ALL_TOOL_IDS" | grep -q -w "$COMMAND"; then
    echo "Error: Tool '$COMMAND' not found in configuration."
    echo "Available tools: $(echo $ALL_TOOL_IDS | tr '\n' ' ' | sed 's/ $//')"
    exit 1
fi

echo "Done."
