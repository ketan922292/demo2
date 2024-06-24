#!/bin/bash
SOURCE_DIR="target/"
DEST_DIR="/h/changes-class"

# Find .class files modified in the last 6 minutes and copy them to DEST_DIR
find "$SOURCE_DIR" -type f -name "*.class" -mmin -6 ! -path "*/.*" -exec cp {} "$DEST_DIR" \;

# Output message
echo "Copied .class files modified in the last 6 minutes from $SOURCE_DIR to $DEST_DIR"

