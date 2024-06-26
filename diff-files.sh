#!/bin/bash

# AWS instance details
aws_ip="13.201.72.80"
aws_user="ec2-user"
service_dir="/opt/tomcat/webapps/OtpProject-0.0.1-SNAPSHOT/WEB-INF/classes"
pem_file="/g/workspace/kele.pem"  # Update this with the actual path to your .pem file
tomcat_bin_dir="/opt/tomcat/bin"  # Update this with the actual path to your Tomcat bin directory

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

# Check the Maven status
if [ $? -ne 0 ]; then
  echo "Maven compilation failed. Exiting."
  exit 1
fi

# Create a directory for the patch
mkdir -p patch

# Iterate over each modified Java file
for file in $modified_files; do
  echo "Processing file: $file"

  # Convert Java source path to class path
  class_file=$(echo $file | sed 's/src\/main\/java\///' | sed 's/\.java$/.class/')
  class_file_path="/g/workspace/WebDemo/target/classes/$class_file"
  echo "Expected class file: $class_file_path"

  # Check if the class file exists and copy it
  if [ -f "$class_file_path" ]; then
    echo "Found compiled class file: $class_file_path"
    mkdir -p $(dirname "patch/$class_file")
    cp "$class_file_path" "patch/$class_file"
  else
    echo "Compiled class file not found for: $file"
  fi
done

echo "Patch created with modified class files."

# Use scp to copy the patch to the AWS instance
echo "Copying files to AWS instance..."
scp -i $pem_file -r patch/* ${aws_user}@${aws_ip}:${service_dir}

if [ $? -eq 0 ]; then
  echo "Files successfully copied to AWS instance."
else
  echo "Failed to copy files to AWS instance."
  exit 1
fi

# Restart the Tomcat server using shutdown.sh and startup.sh
echo "Restarting Tomcat server..."
ssh -i $pem_file ${aws_user}@${aws_ip} "bash -c 'cd $tomcat_bin_dir && sudo ./shutdown.sh && sleep 5 && sudo ./startup.sh'"

if [ $? -eq 0 ]; then
  echo "Tomcat server restarted successfully."
else
  echo "Failed to restart Tomcat server."
fi
