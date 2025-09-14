#!/bin/sh
# entrypoint.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the root directory of your static files
ROOT_DIR=/usr/share/nginx/html

# Replace the placeholder with the runtime environment variable
# Use a temporary file and then replace the original to be safe
for file in $ROOT_DIR/static/js/*.js
do
  echo "Processing $file ...";

  # Use the '|' delimiter for sed to avoid issues with URLs containing '/'
  sed -i "s|__REACT_APP_API_URL__|$REACT_APP_API_URL|g" "$file"
done

# Execute the command passed to this script (i.e., start the Nginx server)
exec "$@"