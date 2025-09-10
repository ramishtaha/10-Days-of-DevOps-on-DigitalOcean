# Use a specific LTS version of Node.js with Alpine Linux for a lightweight image
FROM node:20-alpine

# Create and set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available) first
# This allows Docker to cache the npm install step when only code changes
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application code
COPY . .

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

# Change ownership of the working directory to the non-root user
RUN chown -R nodeuser:nodejs /usr/src/app
USER nodeuser

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the application
CMD ["npm", "start"]
