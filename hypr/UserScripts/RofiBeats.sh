#!/bin/bash
# For Rofi Beats to play online Music or Locally save media files

# Directory local music folder
mDIR="$HOME/Music/"

# Directory for icons
iDIR="$HOME/.config/swaync/icons"

# Online Stations. Edit as required
declare -A online_music=(
  ["YT - Youtube Remix 📹🎶"]="https://youtube.com/playlist?list=PLeqTkIUlrZXlSNn3tcXAa-zbo95j0iN-0"
  ["YT - Personal Music👻"]="https://www.youtube.com/playlist?list=PLd4jlZ_fWNvnRvuwqiRy1GAxDK9Ah80_Z"
  ["YT - Cybercore 🧑‍💻🎶🪩"]="https://www.youtube.com/playlist?list=PLd4jlZ_fWNvmEPrcXXWl8rHrvN5UGxwEL "
  ["YT - Mellow Vibes - Morning Playlist"]="https://www.youtube.com/watch?v=kDGpZsxUW-Q"
  ["YT - Dance Fruits Radio"]="https://www.youtube.com/playlist?list=PLeZo-g7MgUlFRHs4cpkltKqZjeNW2aHR-"
  ["YT - Today's Hits Remix 2025"]="https://www.youtube.com/playlist?list=PLeqTkIUlrZXlSNn3tcXAa-zbo95j0iN-0"
  ["YT - Synthwave 🎹🧪🌊🧖"]="https://www.youtube.com/playlist?list=PLd4jlZ_fWNvm8mU7LNpYDOeZ3qx5cjCB6"
  ["YT - Bigmode🎞💪"]="https://www.youtube.com/playlist?list=PLd4jlZ_fWNvndxSg6O4nVs0zeT2bMNPgz"
)

# Populate local_music array with files from music directory and subdirectories
populate_local_music() {
  local_music=()
  filenames=()
  while IFS= read -r file; do
    local_music+=("$file")
    filenames+=("$(basename "$file")")
  done < <(find "$mDIR" -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.mp4" \))
}

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$iDIR/music.png" "Playing: $@"
}

# Main function for playing local music
play_local_music() {
  populate_local_music

  # Prompt the user to select a song
  choice=$(printf "%s\n" "${filenames[@]}" | rofi -i -dmenu -config ~/.config/rofi/config-rofi-Beats.rasi -p "Local Music")

  if [ -z "$choice" ]; then
    exit 1
  fi

  # Find the corresponding file path based on user's choice and set that to play the song then continue on the list
  for (( i=0; i<"${#filenames[@]}"; ++i )); do
    if [ "${filenames[$i]}" = "$choice" ]; then
		
	    notification "$choice"

      # Play the selected local music file using mpv
      mpv --playlist-start="$i" --loop-playlist --vid=no  "${local_music[@]}"

      break
    fi
  done
}

# Main function for shuffling local music
shuffle_local_music() {
  notification "Shuffle local music"

  # Play music in $mDIR on shuffle
  mpv --shuffle --loop-playlist --vid=no "$mDIR"
}

# Main function for playing online music
play_online_music() {
  choice=$(printf "%s\n" "${!online_music[@]}" | rofi -i -dmenu -config ~/.config/rofi/config-rofi-Beats.rasi -p "Online Music")

  if [ -z "$choice" ]; then
    exit 1
  fi

  link="${online_music[$choice]}"

  notification "$choice"
  
  # Play the selected online music using mpv
  mpv --shuffle --vid=no "$link"
}

# Check if an online music process is running and send a notification, otherwise run the main function
pkill mpv && notify-send -u low -i "$iDIR/music.png" "Music stopped" || {

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi


# Prompt the user to choose between local and online music
user_choice=$(printf "Play from Online Stations\nPlay from Music Folder\nShuffle Play from Music Folder" | rofi -dmenu -config ~/.config/rofi/config-rofi-Beats-menu.rasi -p "Select music source")

  case "$user_choice" in
    "Play from Music Folder")
      play_local_music
      ;;
    "Play from Online Stations")
      play_online_music
      ;;
    "Shuffle Play from Music Folder")
      shuffle_local_music
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
}
