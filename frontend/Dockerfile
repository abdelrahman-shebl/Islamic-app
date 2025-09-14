# --- Builder Stage ---
# Use a specific Node version for reproducible builds
FROM node:alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install dependencies using the clean and deterministic 'npm ci'
RUN npm ci --legacy-peer-deps

# Copy the rest of the application's source code
COPY . .

# Build the React app. The placeholder for the API URL will be included in the build files.
RUN npm run build


# --- Production Stage ---
# Use a lightweight Nginx image to serve the static files
FROM nginx:alpine

# Copy the entrypoint script that will inject the runtime environment variable
COPY ./entrypoint.sh /
# Make the script executable
RUN chmod +x /entrypoint.sh

# Copy the built static files from the builder stage to Nginx's web root
COPY --from=builder /app/build /usr/share/nginx/html

# Nginx listens on port 80 by default
EXPOSE 80

# Set the entrypoint to our custom script. This runs before the server starts.
ENTRYPOINT ["/entrypoint.sh"]

# The default command to run *after* the entrypoint script finishes.
# This starts the Nginx server in the foreground.
CMD ["nginx", "-g", "daemon off;"]