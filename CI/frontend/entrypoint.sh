#!/bin/sh
# entrypoint.sh

set -e

# Define the root directory of static files
ROOT_DIR=/app/build

# Replace the placeholder with the runtime environment variable
for file in $ROOT_DIR/static/js/*.js
do
    echo "Processing $file ..."
    sed -i "s|__REACT_APP_API_URL__|$REACT_APP_API_URL|g" "$file"
done

# Execute the command (serve)
exec "$@"