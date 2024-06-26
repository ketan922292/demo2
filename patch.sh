# Copy the modified class files to the patch directory
for file in $modified_files; do
  class_file=$(echo $file | sed 's/src\/main\/java/src\/main\/classes/' | sed 's/\.java$/.class/')
  if [ -f "$class_file" ]; then
    mkdir -p $(dirname "patch/$class_file")
    cp "$class_file" "patch/$class_file"
  fi
done

echo "Patch created with modified class files."

