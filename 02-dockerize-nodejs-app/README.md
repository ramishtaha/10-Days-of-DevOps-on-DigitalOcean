# Containerize a Simple Application with Docker

**Difficulty:** Beginner  
**Project:** Day 2 of 10 Days of DevOps on DigitalOcean

## Objective

In this project, you'll learn the fundamentals of Docker by taking a simple Node.js application, writing a Dockerfile for it, building a container image, and running it on your local machine. This hands-on experience will teach you the essential concepts of containerization and prepare you for more advanced DevOps practices.

By the end of this project, you'll understand:
- How to write a Dockerfile
- How to build Docker images
- How to run containers from images
- Docker best practices for Node.js applications

## Prerequisites

Before starting this project, make sure you have:
- **Docker Desktop** installed and running on your local machine
  - Download from: https://www.docker.com/products/docker-desktop/
  - Verify installation by running `docker --version` in your terminal

## Technologies Used

- **Docker** - Containerization platform
- **Node.js** - JavaScript runtime environment
- **Express.js** - Web application framework for Node.js

## Estimated Cost & Free Tier Eligibility

💰 **Cost:** $0.00

This project runs entirely on your local machine and does not require any DigitalOcean resources. No cloud services or external infrastructure are needed.

## Step-by-Step Guide

### Step 1: Create the Node.js Application

First, let's create a simple Express.js application:

**app.js:**
```javascript
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Your Dockerized App!');
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
```

**package.json:**
```json
{
  "name": "dockerized-node-app",
  "version": "1.0.0",
  "description": "A simple Node.js app to demonstrate Docker containerization",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "author": "DevOps Learner",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

### Step 2: Create the Dockerfile

Create a `Dockerfile` (no file extension) in the same directory:

```dockerfile
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
```

### Step 3: Understanding the Dockerfile

Let's break down each instruction in the Dockerfile:

- **`FROM node:20-alpine`**: Uses Node.js version 20 on Alpine Linux as the base image. Alpine is chosen for its small size and security.
- **`WORKDIR /usr/src/app`**: Sets the working directory inside the container where our app will live.
- **`COPY package*.json ./`**: Copies package.json (and package-lock.json if it exists) first to leverage Docker's layer caching.
- **`RUN npm install --only=production`**: Installs only production dependencies, excluding dev dependencies.
- **`COPY . .`**: Copies the rest of our application code into the container.
- **`RUN addgroup -g 1001 -S nodejs && adduser -S nodeuser -u 1001`**: Creates a non-root user for security best practices.
- **`RUN chown -R nodeuser:nodejs /usr/src/app`**: Changes ownership of the app directory to our non-root user.
- **`USER nodeuser`**: Switches to the non-root user to run the application.
- **`EXPOSE 3000`**: Documents that the app uses port 3000 (doesn't actually publish the port).
- **`CMD ["npm", "start"]`**: Specifies the default command to run when the container starts.

### Step 4: Build the Docker Image

Navigate to your project directory and build the Docker image:

```bash
docker build -t node-app:1.0 .
```

This command:
- `docker build`: Builds a Docker image from a Dockerfile
- `-t node-app:1.0`: Tags the image with name "node-app" and version "1.0"
- `.`: Uses the current directory as the build context

### Step 5: Verify the Image was Created

Check that your image was built successfully:

```bash
docker images
```

You should see your `node-app` image listed with the tag `1.0`.

### Step 6: Run the Container

Start a container from your image:

```bash
docker run -p 3000:3000 --name my-app-container node-app:1.0
```

This command:
- `docker run`: Creates and starts a new container
- `-p 3000:3000`: Maps port 3000 on your host to port 3000 in the container
- `--name my-app-container`: Gives the container a friendly name
- `node-app:1.0`: Specifies which image to use

### Step 7: Test the Application

Open your web browser and visit:
```
http://localhost:3000
```

You should see the message: "Hello from Your Dockerized App!"

### Step 8: View Running Containers

In a new terminal window, you can see your running container:

```bash
docker ps
```

## Learning Materials

Enhance your Docker knowledge with these official resources:

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/) - Complete guide to Dockerfile instructions
- [Docker Build Documentation](https://docs.docker.com/engine/reference/commandline/build/) - Learn all about the build process
- [Docker Run Documentation](https://docs.docker.com/engine/reference/commandline/run/) - Master container execution options
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/) - Official best practices guide

## Cleanup Instructions

When you're done experimenting, clean up your Docker environment:

### Stop the Container
```bash
docker stop my-app-container
```

### Remove the Container
```bash
docker rm my-app-container
```

### Remove the Image (Optional)
```bash
docker rmi node-app:1.0
```

### Verify Cleanup
```bash
docker ps -a  # Should not show your container
docker images # Should not show your image (if removed)
```

## What's Next?

Congratulations! You've successfully containerized your first application. In the next project, you'll learn how to:
- Push your Docker image to a container registry
- Deploy containers to cloud infrastructure
- Implement CI/CD pipelines with GitHub Actions

## Troubleshooting

**Port already in use?**
- Stop any processes using port 3000, or use a different port mapping: `-p 8080:3000`

**Permission denied errors?**
- Make sure Docker Desktop is running
- On Linux, you may need to add your user to the docker group

**Build fails?**
- Check that all files are in the correct directory
- Verify your Dockerfile has no file extension
- Ensure Docker Desktop has enough resources allocated
