#!/bin/bash
git add .
git commit -m "added new files"
git push git@github.com:developer-bagic-02/demo2.git
SOURCE_DIR="target/"
DEST_DIR="/h/changes-class"

# Find .class files modified in the last 6 minutes and copy them to DEST_DIR
find "$SOURCE_DIR" -type f -name "*.class" -mmin -6 ! -path "*/.*" -exec cp {} "$DEST_DIR" \;

# Output message
echo "Copied .class files modified in the last 6 minutes from $SOURCE_DIR to $DEST_DIR"
scp -i /g/workspace/id_rsa -r /h/changes-class/*Controller.class root@128.199.25.154:/opt/tomcat/webapps/OtpProject-0.0.1-SNAPSHOT/WEB-INF/classes/com/web/controller
scp -i /g/workspace/id_rsa -r /h/changes-class/*Service.class root@128.199.25.154:/opt/tomcat/webapps/OtpProject-0.0.1-SNAPSHOT/WEB-INF/classes/com/web/service
date=$(date +"%d_%H-%M")
mkdir /h/bkp-$date
cp $DEST_DIR/*.class /h/bkp-$date
rm $DEST_DIR/*.class
