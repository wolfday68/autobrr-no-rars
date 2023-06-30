#!/bin/ash

# Get torrent file path from autobrr's {{.TorrentPathName}} variable
torrentFile=$1

# Use imdl to get a JSON dump of the torrent's metadata
torrentJSON=$(/app/imdl torrent show -j -i $torrentFile)

# Check if any file paths end with ".rar"
result=$(echo "$torrentJSON" | jq -r '.files | values[] | select(endswith(".rar"))')

# If rars are found, then exit with non-standard code to signify a rar'd release was grabbed
if [ -n "$result" ]; then
  exit 3
else # If no rars found, then exit cleanly
  exit 0
fi

