#!/bin/bash

# Check if a version argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION=$1

# Iterate through all subdirectories
for dir in */; do
  if [ -d "$dir" ]; then
    echo "Entering directory: $dir"
    cd "$dir" || exit
    # Run the moon add command
    moon add "Yoorkin/rabbit-tea@$VERSION"
    cd ..
  fi
done

echo "Completed updating all subdirectories with Yoorkin/rabbit-tea@$VERSION."