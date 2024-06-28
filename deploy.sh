#!/bin/bash
git pull origin master
git add .
git commit -m "added files"
git push origin master --force
git pull origin master

# Set variables
REPO_OWNER="developer-bagic-02"
REPO_NAME="demo2"
# Get the latest commit SHA from the main branch
LATEST_COMMIT_SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/commits/master | jq -r .sha)
echo $LATEST_COMMIT_SHA
# Get the parent commit SHA
PARENT_COMMIT_SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/commits/$LATEST_COMMIT_SHA | jq -r .parents[0].sha)
echo $PARENT_COMMIT_SHA
# Get the list of changed files
CHANGED_FILES=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/compare/$PARENT_COMMIT_SHA...$LATEST_COMMIT_SHA | jq -r '.files[].filename')
# Output the changed files
echo "changed files------------------------"
echo "$CHANGED_FILES"

#!/bin/bash

# AWS instance details
aws_ip="65.0.127.255"
aws_user="ec2-user"
service_dir="/opt/tomcat/webapps/OtpProject-0.0.1-SNAPSHOT/WEB-INF/classes"
pem_file="/g/workspace/demo-clover.pem"  # Update this with the actual path to your .pem file
tomcat_bin_dir="/opt/tomcat/bin"  # Update this with the actual path to your Tomcat bin directory
# Get the list of modified Java files
echo "Modified Java files:"
echo "$CHANGED_FILES"

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
for file in $CHANGED_FILES; do
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

