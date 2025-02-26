#!/bin/bash

# Cross-platform date formatting (handles macOS/Linux differences)
year=$(date +%y)
month=$(date +%m | sed 's/^0//')  # Remove leading zero
day=$(date +%d | sed 's/^0//')    # Remove leading zero
TAG_PREFIX="v$year.$month.$day."

# Find the highest valid sequence for TODAY using version sort
latest_tag=$(git tag --list "${TAG_PREFIX}*" --sort=-version:refname | head -n 1)

# Extract sequence number safely
if [[ -n "$latest_tag" && "$latest_tag" =~ ^${TAG_PREFIX}([0-9]+)$ ]]; then
  max_seq="${BASH_REMATCH[1]}"
else
  max_seq=0  # No valid tags found for today
fi

# Increment sequence
next_seq=$((max_seq + 1))
new_tag="${TAG_PREFIX}${next_seq}"

# Validate tag format before creation
if [[ ! "$new_tag" =~ ^v[0-9]{2}\.[1-9]?[0-9]\.[1-9]?[0-9]\.[0-9]+$ ]]; then
  echo "Error: Invalid tag format generated - $new_tag" >&2
  exit 1
fi

# Create and push tag
git tag -a "$new_tag" -m "Release ${new_tag}"
git push origin "$new_tag"

echo "Created and pushed tag: $new_tag"
