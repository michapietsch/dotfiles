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

# Function to check if a package is installed
is_package_installed() {
  dnf list installed "$1" &> /dev/null
}

simple_install() {
  TOOL_ID=$1
  NAME=$2
  SRC=$3
  DST=$4

  if [ -z "$COMMAND" ] || [ "$COMMAND" = "$TOOL_ID" ]; then
    echo "--- Installing $NAME config... ---"
    
    CONFIG_SOURCE="$REPO_ROOT/$SRC"
    CONFIG_DEST="$HOME/$DST"

    clear_destination_if_forced "$CONFIG_DEST"

    if destination_exists "$CONFIG_DEST"; then
      echo "$NAME config already exists at $CONFIG_DEST. Skipping."
      echo "Use --force to overwrite."
    else
      create_symlink "$NAME" "$CONFIG_SOURCE" "$CONFIG_DEST"
    fi
    echo # Add a newline for better readability
  fi
}

# --- Main Installation Logic ---
simple_install "neovim" "Neovim" "tools/neovim" ".config/nvim"

if is_package_installed "input-remapper"; then
  simple_install "input-remapper" "Input Remapper" "tools/input-remapper" ".config/input-remapper-2"
fi

echo "Done."
