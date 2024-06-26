#!/bin/bash

# Fetch the latest changes
git fetch origin

# Get the list of modified Java files
modified_files=$(git diff --name-only HEAD^ HEAD | grep '\.java$')

if [ -z "$modified_files" ]; then
  echo "No modified Java files to compile."
  exit 0
fi

echo "Modified Java files:"
echo "$modified_files"

