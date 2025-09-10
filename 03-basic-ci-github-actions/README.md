# Project 3: Basic CI with GitHub Actions

**Difficulty:** Beginner  
**Estimated Time:** 45-60 minutes  
**Cost:** Free (within limits)

## Objective

In this project, you'll create your first Continuous Integration (CI) pipeline using GitHub Actions. This pipeline will automatically test your Node.js application from Project 2, and if the tests pass, build a new Docker image and push it to a private DigitalOcean Container Registry. You'll learn the fundamentals of automated testing, container registry management, and CI/CD workflows.

## Prerequisites

Before starting this project, ensure you have:

- ✅ **GitHub account** with a repository containing the files from Project 2
- ✅ **DigitalOcean account** (sign up at [digitalocean.com](https://digitalocean.com))
- ✅ **doctl CLI** installed and authenticated ([Installation Guide](https://docs.digitalocean.com/reference/doctl/how-to/install/))
- ✅ Basic understanding of Git and Docker from previous projects

## Technologies Used

- **GitHub Actions** - CI/CD platform integrated with GitHub
- **Docker** - Containerization platform
- **Node.js & Express** - Application runtime and framework
- **Jest & Supertest** - Testing framework and HTTP testing library
- **DigitalOcean Container Registry** - Private Docker image registry

## Estimated Cost & Free Tier Eligibility

- **DigitalOcean Container Registry**: Free tier includes 500 MiB storage and 5 GiB transfer
- **GitHub Actions**: Free for public repositories (2,000 minutes/month for private repos)
- **Total estimated cost**: $0/month within free tiers

> ⚠️ **Cost Warning**: If you exceed the free tier limits, charges may apply. We'll show you how to clean up resources at the end.

## Step-by-Step Guide

### Step 1: Create GitHub Repository and Setup Project Files

Before we can set up CI/CD, we need to create a GitHub repository and organize our project files properly.

#### Option A: Create New Repository from Scratch

1. **Create a new GitHub repository**:
   - Go to [github.com](https://github.com) and sign in
   - Click the "+" icon in the top right corner
   - Select "New repository"
   - Repository name: `dockerized-nodejs-ci` (or your preferred name)
   - Description: `Node.js app with Docker and GitHub Actions CI/CD`
   - Make it **Public** (for free GitHub Actions minutes)
   - Check "Add a README file"
   - Click "Create repository"

2. **Clone the repository locally**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dockerized-nodejs-ci.git
   cd dockerized-nodejs-ci
   ```

3. **Copy files from Project 2**: 
   If you completed Project 2, copy the following files to your new repository:
   - `app.js` (we'll update this)
   - `package.json` (we'll update this)
   - `Dockerfile` (we'll enhance this)

#### Option B: Fork or Continue from Project 2 Repository

If you already have a repository from Project 2:

1. **Navigate to your existing repository** or create a new branch:
   ```bash
   cd path/to/your/project-2-repo
   git checkout -b add-ci-pipeline
   ```

2. **Ensure you have the basic files**:
   - `app.js`
   - `package.json`
   - `Dockerfile`

#### Option C: Start Fresh with All Files

If you want to start completely fresh, create these files in your repository:

**Create the basic project structure**:
```bash
# Create project directory
mkdir dockerized-nodejs-ci
cd dockerized-nodejs-ci

# Initialize git repository
git init
git branch -M main

# Create necessary directories
mkdir -p .github/workflows
```

### Step 2: Update Your Application for Testing

Now let's enhance our Node.js application to be more testable and robust.

**Update `package.json`:**

```json
{
  "name": "dockerized-nodejs-app",
  "version": "1.0.0",
  "description": "A simple Node.js application for learning Docker and CI/CD with GitHub Actions",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest"
  },
  "keywords": [
    "nodejs",
    "express",
    "docker",
    "digitalocean",
    "github-actions",
    "ci-cd"
  ],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "nodemon": "^3.0.1"
  },
  "jest": {
    "testEnvironment": "node",
    "collectCoverage": true,
    "coverageDirectory": "coverage",
    "coverageReporters": ["text", "lcov", "html"]
  }
}
```

**Update `app.js`:**

```javascript
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON
app.use(express.json());

// Basic route
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Your Dockerized App!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Start server only if this file is run directly (not during testing)
if (require.main === module) {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

// Export app for testing
module.exports = app;
```

**Create `app.test.js`:**

```javascript
const request = require('supertest');
const app = require('./app');

describe('Dockerized Node.js App', () => {
  describe('GET /', () => {
    it('should return 200 status code', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
    });

    it('should return correct message', async () => {
      const response = await request(app).get('/');
      expect(response.body.message).toBe('Hello from Your Dockerized App!');
    });

    it('should return JSON content type', async () => {
      const response = await request(app).get('/');
      expect(response.headers['content-type']).toMatch(/json/);
    });

    it('should include version and timestamp', async () => {
      const response = await request(app).get('/');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body.version).toBe('1.0.0');
    });
  });

  describe('GET /health', () => {
    it('should return 200 status code', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
    });

    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.body.status).toBe('healthy');
    });

    it('should include uptime and timestamp', async () => {
      const response = await request(app).get('/health');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('timestamp');
      expect(typeof response.body.uptime).toBe('number');
    });
  });

  describe('Error handling', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(app).get('/non-existent-route');
      expect(response.status).toBe(404);
    });
  });
});
```

### Step 3: Create DigitalOcean Container Registry

#### Option A: Using DigitalOcean Web Console (Recommended)

1. **Log into DigitalOcean**: Visit [cloud.digitalocean.com](https://cloud.digitalocean.com)

2. **Navigate to Container Registry**:
   - Click "Create" in the top menu
   - Select "Container Registry"

3. **Configure Registry**:
   - **Name**: Choose a unique name (e.g., `my-devops-registry`)
   - **Region**: Select closest to you
   - **Subscription Plan**: Choose "Basic" (free tier)

4. **Create Registry**: Click "Create Registry"

5. **Note the Registry Name**: You'll see something like `registry.digitalocean.com/my-devops-registry`

#### Option B: Using doctl CLI

```bash
# Create a new container registry
doctl registry create my-devops-registry --region nyc3

# Get registry info
doctl registry get my-devops-registry
```

### Step 4: Configure GitHub Secrets

Your GitHub Actions workflow needs secure access to DigitalOcean. Let's set up the required secrets:

1. **Get DigitalOcean API Token**:
   - Go to [cloud.digitalocean.com/account/api/tokens](https://cloud.digitalocean.com/account/api/tokens)
   - Click "Generate New Token"
   - Name: `GitHub Actions CI`
   - Expiration: 90 days (or as needed)
   - Scopes: Select "Full Access"
   - Copy the token immediately (you won't see it again)

2. **Add Secrets to GitHub Repository**:
   - Go to your GitHub repository
   - Click "Settings" tab
   - In left sidebar, click "Secrets and variables" → "Actions"
   - Click "New repository secret" and add:

   **Secret 1:**
   - Name: `DIGITALOCEAN_ACCESS_TOKEN`
   - Value: Your DigitalOcean API token

   **Secret 2:**
   - Name: `DOCR_REGISTRY_NAME`
   - Value: Your full registry hostname (e.g., `registry.digitalocean.com/my-devops-registry`)

### Step 5: Create GitHub Actions Workflow

Create the directory structure and workflow file:

```bash
# Create the GitHub Actions directory (if it doesn't exist)
mkdir -p .github/workflows
```

**Create `.github/workflows/ci.yml`:**

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20.x'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Log in to DigitalOcean Container Registry
      if: github.ref == 'refs/heads/main'
      uses: docker/login-action@v3
      with:
        registry: ${{ secrets.DOCR_REGISTRY_NAME }}
        username: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}
        password: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}
        
    - name: Set up Docker Buildx
      if: github.ref == 'refs/heads/main'
      uses: docker/setup-buildx-action@v3
      
    - name: Build and push Docker image
      if: github.ref == 'refs/heads/main'
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          ${{ secrets.DOCR_REGISTRY_NAME }}/dockerized-nodejs-app:latest
          ${{ secrets.DOCR_REGISTRY_NAME }}/dockerized-nodejs-app:${{ github.sha }}
        platforms: linux/amd64,linux/arm64
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### Step 6: Understanding the Workflow

Let's break down what each section does:

- **`name`**: Gives your workflow a descriptive name
- **`on`**: Defines when the workflow runs (pushes to main, pull requests)
- **`jobs`**: Contains the work to be done
- **`runs-on`**: Specifies the virtual machine to use
- **`steps`**: Individual tasks in the job

**Key Steps Explained:**

1. **Checkout code**: Downloads your repository code
2. **Set up Node.js**: Installs Node.js and sets up npm caching
3. **Install dependencies**: Runs `npm ci` for clean, fast installs
4. **Run tests**: Executes your Jest test suite
5. **Docker login**: Authenticates with DigitalOcean Container Registry
6. **Build and push**: Creates Docker image and pushes to registry

**Conditional Execution**: The Docker steps only run on pushes to the main branch (`if: github.ref == 'refs/heads/main'`), not on pull requests.

### Step 7: Commit and Push All Files to GitHub

Now let's get all our files into the GitHub repository:

1. **Add all files to your repository**:
   ```bash
   # Add all the new files
   git add .
   
   # Check what files will be committed
   git status
   ```

   You should see these files ready to be committed:
   - `app.js`
   - `package.json`
   - `app.test.js`
   - `Dockerfile`
   - `.github/workflows/ci.yml`

2. **Commit the changes**:
   ```bash
   git commit -m "Add Node.js app with CI/CD pipeline

   - Add Express.js application with health endpoint
   - Add comprehensive Jest test suite
   - Add Docker configuration with security best practices
   - Add GitHub Actions workflow for CI/CD
   - Integrate with DigitalOcean Container Registry"
   ```

3. **Push to GitHub**:
   ```bash
   # If this is a new repository
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git push -u origin main
   
   # If continuing from existing repo
   git push origin main
   # or if you created a branch: git push origin add-ci-pipeline
   ```

4. **Verify files are uploaded**:
   - Go to your GitHub repository in your browser
   - Confirm all files are present
   - Check that the `.github/workflows/ci.yml` file is visible

### Step 8: Test Your CI Pipeline

1. **Install dependencies locally** (optional, for testing):
```bash
npm install
npm test
```

2. **The workflow should trigger automatically** when you pushed to main in the previous step.

3. **Monitor the workflow**:
   - Go to your GitHub repository
   - Click the "Actions" tab
   - You should see your workflow running
   - Click on the workflow run to see detailed logs

### Step 9: Verify Success

1. **Check GitHub Actions**:
   - Ensure all steps completed successfully
   - Look for green checkmarks ✅

2. **Verify Docker Image in Registry**:

   **Via DigitalOcean Web Console:**
   - Go to [cloud.digitalocean.com](https://cloud.digitalocean.com)
   - Navigate to "Container Registry"
   - Click on your registry
   - You should see `dockerized-nodejs-app` with tags `latest` and a Git SHA

   **Via doctl CLI:**
   ```bash
   # List repositories in your registry
   doctl registry repository list
   
   # List tags for your app
   doctl registry repository list-tags dockerized-nodejs-app
   ```

### Step 10: Test the Complete Pipeline

Let's verify everything works by making a small change:

1. **Update the version in `app.js`**:
```javascript
version: '1.1.0'  // Change from 1.0.0
```

2. **Update the test in `app.test.js`**:
```javascript
expect(response.body.version).toBe('1.1.0');  // Update expected version
```

3. **Commit and push**:
```bash
git add .
git commit -m "Update app version to 1.1.0"
git push origin main
```

4. **Watch the pipeline run again** and verify a new image is pushed.

## Understanding the Benefits

This CI pipeline provides several key benefits:

- **Automated Testing**: Every code change is automatically tested
- **Quality Gates**: Only tested code gets deployed
- **Consistent Builds**: Docker ensures identical environments
- **Version Tracking**: Images are tagged with Git commits
- **Multi-platform Support**: Builds for both AMD64 and ARM64

## Learning Materials

- **GitHub Actions Documentation**: [docs.github.com/actions](https://docs.github.com/en/actions)
- **DigitalOcean Container Registry**: [docs.digitalocean.com/products/container-registry](https://docs.digitalocean.com/products/container-registry/)
- **Docker Build Push Action**: [github.com/docker/build-push-action](https://github.com/docker/build-push-action)
- **Jest Testing Framework**: [jestjs.io](https://jestjs.io/)
- **Supertest HTTP Testing**: [github.com/ladjs/supertest](https://github.com/ladjs/supertest)

## Troubleshooting

### Common Issues and Solutions

**Issue**: Tests failing locally
```bash
# Solution: Install dependencies and run tests
npm install
npm test
```

**Issue**: Docker login failing
- Verify your `DIGITALOCEAN_ACCESS_TOKEN` secret is correct
- Ensure your `DOCR_REGISTRY_NAME` includes the full hostname

**Issue**: Workflow not triggering
- Check that your workflow file is in `.github/workflows/`
- Verify the YAML syntax is correct
- Ensure you've pushed to the `main` branch
- Check the "Actions" tab in your repository settings is enabled

**Issue**: Files not appearing in GitHub
```bash
# Check what files are tracked
git status

# Add any missing files
git add .

# Verify remote repository URL
git remote -v
```

**Issue**: Registry not found
```bash
# Check if registry exists
doctl registry get my-devops-registry
```

**Issue**: Repository setup problems
```bash
# Verify you're in the right directory
pwd

# Check git configuration
git config --list

# Verify repository structure
ls -la
ls -la .github/workflows/
```

## Cleanup Instructions

To avoid any potential costs, clean up your resources:

### Delete Container Registry

**Via DigitalOcean Web Console:**
1. Go to [cloud.digitalocean.com](https://cloud.digitalocean.com)
2. Navigate to "Container Registry"
3. Click on your registry name
4. Click "Settings" tab
5. Scroll down and click "Destroy Registry"
6. Type the registry name to confirm

**Via doctl CLI:**
```bash
# Delete the registry (this removes all images too)
doctl registry delete my-devops-registry --force
```

### Clean Up GitHub

The GitHub Actions workflows and secrets don't incur costs, but you can clean them up:

1. **Remove secrets** (if desired):
   - Go to repository Settings → Secrets and variables → Actions
   - Delete the secrets you created

2. **Disable workflow** (optional):
   - Go to Actions tab
   - Click on your workflow
   - Click "..." → "Disable workflow"

## Next Steps

Congratulations! You've successfully created your first CI pipeline. In the next project, you'll learn about:

- **Docker Compose** for multi-container applications
- **Service orchestration** and networking
- **Development vs. production configurations**
- **Database integration** with persistent volumes

The foundation you've built here will be essential for more complex deployment scenarios.

## Summary

In this project, you learned:

- ✅ How to write tests for Node.js applications using Jest and Supertest
- ✅ How to create GitHub Actions workflows for CI/CD
- ✅ How to integrate with DigitalOcean Container Registry
- ✅ How to automate Docker image building and pushing
- ✅ How to use GitHub Secrets for secure authentication
- ✅ How to implement quality gates in your deployment pipeline

You now have a solid foundation in Continuous Integration that will serve you well in professional development environments!
