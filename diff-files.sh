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

# Clean and compile the project
mvn clean compile

# AWS instance details
aws_ip="13.201.72.80"
aws_user="ec2-user"  # Replace with your AWS instance's SSH username

# Directory paths on AWS instance
service_dir="/opt/tomcat/webapps/OtpProject-0.0.1-SNAPSHOT/WEB-INF/classes/com/web/service"
controller_dir="/opt/tomcat/webapps/OtpProject-0.0.1-SNAPSHOT/WEB-INF/classes/com/web/controller"

# Copy the compiled class files to the AWS instance
for file in $modified_files; do
  # Extract the class file path from the Java file path
  class_file=$(echo $file | sed 's|^src/main/java|target/classes|' | sed 's|\.java$|.class|')
  echo "Looking for class file: $class_file"

  if [ -f "$class_file" ]; then
    # Determine destination directory based on file type
    if echo "$file" | grep -q "/service/"; then
      dest_dir="$service_dir"
    elif echo "$file" | grep -q "/controller/"; then
      dest_dir="$controller_dir"
    else
      echo "Unknown file type: $file"
      continue
    fi

    echo "Copying $class_file to $dest_dir."
    # Use scp to copy the file to AWS instance
    scp -i /g/workspace/kele.pem "$class_file" "$aws_user@$aws_ip:$dest_dir/"
  else
    echo "Class file not found: $class_file"
  fi
done

