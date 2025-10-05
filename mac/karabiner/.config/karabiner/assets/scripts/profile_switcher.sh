#!/bin/zsh

# Define the full path to karabiner_cli
KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

# Check if karabiner_cli exists
if [[ ! -f "$KARABINER_CLI" ]]; then 
  osascript -e 'display notification "'"$0: Can't find karabiner_cli at $KARABINER_CLI"'" with title "Karabiner Elements Profile Switcher"' 
  exit 1
fi

profiles=()
# get profile names via karabiner_cli
while IFS= read -r line; do
  profiles+=("$line")
done < <("$KARABINER_CLI" --list-profile-names)

# Get the current profile using karabiner_cli
response="$("$KARABINER_CLI" --show-current-profile-name 2>&1)"
retcode=$?
if [[ "$retcode" != 0 ]]; then
  osascript -e 'display notification "'"$0: Error running karabiner_cli: $response. retcode: $retcode."'" with title "Karabiner Elements Profile Switcher"'  
  exit "$retcode"
fi

current_profile="$response"

# Check if the current profile is recognized in the list
profile_index="$(($profiles[(Ie)$current_profile]))"

# In zsh, array indices start at 1, and (Ie) returns 0 if not found
if [[ "$profile_index" = 0 ]]; then
  osascript -e 'display notification "'"$0: Current profile: $current_profile not found in profiles list."'" with title "Karabiner Elements Profile Switcher"'
  exit 2
fi

# Calculate the next profile index (zsh arrays are 1-indexed)
next_index=$(( (profile_index % ${#profiles}) + 1 ))

# Set the next profile
next_profile="${profiles[$next_index]}"

# Change the Karabiner profile
"$KARABINER_CLI" --select-profile "$next_profile"

# Display a notification
osascript -e 'display notification "'"Profile: $("$KARABINER_CLI" --show-current-profile-name 2>/dev/null) is now active."'" with title "Karabiner Elements Profile Switcher"'