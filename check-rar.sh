#!/bin/ash

# Get torrent file path from autobrr's ` {{.TorrentPathName}} ` variable
torrentFile=$1
# Get filter name from autobrr's ` {{.FilterName}} ` variable
filterName=$2
# Get torrent release name from autobrr's ` {{.TorrentName}} ` variable
torrentName=$3

# Use imdl to get a JSON dump of the torrent's metadata
torrentJSON=$(/app/imdl torrent show -j -i $torrentFile)

# Check if any file paths end with ".rar"
result=$(echo "$torrentJSON" | jq -r '.files | values[] | select(endswith(".rar"))')

# If rars are found, exit with error code
if [ -n "$result" ]; then
  # Convert any rar files into a JSON array
  rarArray=$(echo "$result" | jq -R -s '[split("\n") | .[] | select(length > 0)]')
  # Get current timestamp for error log
  dateISO8601=$(date -Iseconds)

  # Create error log
  output=$(jq -c -n \
    --arg dateISO8601 "$dateISO8601" \
    --arg filterName "$filterName" \
    --arg torrentName "$torrentName" \
    --argjson rarArray "$rarArray" \
    '{
    "level": "debug",
    "module": "filter-rar-script",
    "time": $dateISO8601,
    "message": "Found rars in a release, ignoring it.",
    "filter": $filterName,
    "torrentName": $torrentName,
    "rarFiles": $rarArray
    }'
  )

  # Print error log to stderr
  >&2 echo $output
  # Exit with non-standard code to signify a rar'd release was grabbed
  exit 3
else # If no rars found, then exit cleanly
  exit 0
fi

