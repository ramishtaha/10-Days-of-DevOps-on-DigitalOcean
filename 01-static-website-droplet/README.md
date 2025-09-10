# Project 1: Deploy a Static Website on a DigitalOcean Droplet

## Difficulty
**Beginner**

## Objective
In this project, you'll learn the fundamentals of cloud infrastructure by manually creating a DigitalOcean Droplet, connecting to it via SSH, and deploying a static website using Nginx. This hands-on experience will teach you essential skills like server provisioning, SSH connectivity, web server configuration, and basic Linux system administration. By the end, you'll have a live website running on your own cloud server.

## Prerequisites
- DigitalOcean account with free trial credit ($200 for new users)
- Basic command line knowledge
- SSH client (built into Windows 10/11, macOS, and Linux)
- Text editor for creating HTML files

## Technologies Used
- **Cloud Provider**: DigitalOcean Droplets
- **Operating System**: Ubuntu 24.04 LTS
- **Web Server**: Nginx 1.24+
- **Protocol**: SSH for remote access
- **Security**: DigitalOcean Cloud Firewall

## Estimated Cost & Free Tier Eligibility
- **Droplet Cost**: $6/month for Basic Droplet (1 vCPU, 1GB RAM, 25GB SSD)
- **Hourly Rate**: ~$0.009/hour
- **Project Duration**: 2-3 hours
- **Estimated Cost**: $0.03 for this project
- **Free Tier**: Fully covered by DigitalOcean's $200 free credit for new users

## Step-by-Step Guide

### Step 1: Create a DigitalOcean Droplet

1. **Log into DigitalOcean**
   - Go to [cloud.digitalocean.com](https://cloud.digitalocean.com)
   - Sign in to your account

2. **Create a New Droplet**
   - Click the green **"Create"** button in the top right corner
   - Select **"Droplets"** from the dropdown menu

3. **Configure Your Droplet**
   - **Choose an image**: Select **"Ubuntu 24.04 (LTS) x64"**
   - **Choose a plan**: 
     - Select **"Basic"** plan
     - Choose **"Regular"** CPU options
     - Select **"$6/mo - 1 vCPU, 1GB RAM, 25GB SSD"**
   - **Choose a datacenter region**: Select the region closest to you (e.g., New York, London, Singapore)

4. **Authentication**
   - Select **"SSH Key"** (recommended) or **"Password"**
   - If using SSH Key:
     - Click **"New SSH Key"**
     - Follow the instructions to generate and add your SSH key
   - If using Password:
     - Enter a strong password (minimum 8 characters)

5. **Finalize and Create**
   - **Hostname**: Change to `web-server-01` or similar
   - **Tags**: Add tag `project:static-website` for organization
   - Click **"Create Droplet"**

6. **Wait for Provisioning**
   - Your droplet will be ready in 1-2 minutes
   - Note the IP address displayed in the Droplets dashboard

### Step 2: Connect to Your Droplet via SSH

1. **Open Terminal/Command Prompt**
   - Windows: Use Command Prompt, PowerShell, or Windows Terminal
   - macOS/Linux: Use Terminal

2. **Connect via SSH**
   ```bash
   # Replace YOUR_DROPLET_IP with your actual IP address
   ssh root@YOUR_DROPLET_IP
   ```

3. **Accept the Host Key**
   - Type `yes` when prompted about the authenticity of the host
   - You should now see the Ubuntu welcome message

4. **Verify System Information**
   ```bash
   # Check Ubuntu version
   lsb_release -a
   
   # Check system resources
   free -h
   df -h
   ```

### Step 3: Update the System

1. **Update Package Lists**
   ```bash
   apt update
   ```

2. **Upgrade Installed Packages**
   ```bash
   apt upgrade -y
   ```

3. **Install Essential Tools**
   ```bash
   apt install -y curl wget unzip
   ```

### Step 4: Install and Configure Nginx

1. **Install Nginx**
   ```bash
   apt install nginx -y
   ```

2. **Start and Enable Nginx**
   ```bash
   # Start the Nginx service
   systemctl start nginx
   
   # Enable Nginx to start automatically on boot
   systemctl enable nginx
   
   # Check the status
   systemctl status nginx
   ```

3. **Verify Nginx Installation**
   ```bash
   # Check if Nginx is listening on port 80
   ss -tuln | grep :80
   ```

### Step 5: Configure the Firewall

1. **Check Current UFW Status**
   ```bash
   ufw status
   ```

2. **Configure UFW Firewall**
   ```bash
   # Allow SSH (port 22) - IMPORTANT: Do this first!
   ufw allow ssh
   
   # Allow HTTP (port 80)
   ufw allow 'Nginx HTTP'
   
   # Allow HTTPS (port 443) for future use
   ufw allow 'Nginx HTTPS'
   
   # Enable the firewall
   ufw --force enable
   
   # Verify the configuration
   ufw status verbose
   ```

### Step 6: Test the Default Nginx Page

1. **Test from the Server**
   ```bash
   curl localhost
   ```

2. **Test from Your Browser**
   - Open your web browser
   - Navigate to `http://YOUR_DROPLET_IP`
   - You should see the default Nginx welcome page

### Step 7: Create Your Custom Website

1. **Navigate to the Web Root**
   ```bash
   cd /var/www/html
   ```

2. **Backup the Default Page**
   ```bash
   mv index.nginx-debian.html index.nginx-debian.html.backup
   ```

3. **Create Your Custom HTML File**
   ```bash
   nano index.html
   ```

4. **Add Your HTML Content** (copy the content from the provided `index.html` file)

6. **Create Additional Pages**
   ```bash
   # Create an about page
   nano about.html
   ```

7. **Create a CSS File**
   ```bash
   nano styles.css
   ```

8. **Create Error Pages**
   ```bash
   # Create a 404 error page
   nano 404.html
   ```

### Step 8: Set Proper Permissions

1. **Set Ownership and Permissions**
   ```bash
   # Set ownership to www-data (Nginx user)
   chown -R www-data:www-data /var/www/html
   
   # Set appropriate permissions
   chmod -R 755 /var/www/html
   ```

2. **Verify File Permissions**
   ```bash
   ls -la /var/www/html/
   ```

### Step 9: Configure Custom Nginx Server Block (Optional)

1. **Create a Custom Server Configuration**
   ```bash
   nano /etc/nginx/sites-available/static-website
   ```

2. **Add the Server Block Configuration** (use the provided `nginx-config` file)

3. **Enable the Site**
   ```bash
   # Create symbolic link to enable the site
   ln -s /etc/nginx/sites-available/static-website /etc/nginx/sites-enabled/
   
   # Remove default site
   rm /etc/nginx/sites-enabled/default
   
   # Test Nginx configuration
   nginx -t
   
   # Reload Nginx
   systemctl reload nginx
   ```

### Step 10: Test Your Website

1. **Test All Pages**
   ```bash
   # Test main page
   curl http://YOUR_DROPLET_IP/
   
   # Test about page
   curl http://YOUR_DROPLET_IP/about.html
   ```

2. **Browse Your Website**
   - Open `http://YOUR_DROPLET_IP` in your browser
   - Navigate to different pages
   - Verify that styling is applied correctly

### Step 11: Monitor and Verify

1. **Check Nginx Logs**
   ```bash
   # View access logs
   tail -f /var/log/nginx/access.log
   
   # View error logs (in another terminal)
   tail -f /var/log/nginx/error.log
   ```

2. **Monitor System Resources**
   ```bash
   # Check system load
   htop
   
   # Or use top if htop is not available
   top
   ```

## Learning Materials

- [DigitalOcean Droplet Documentation](https://docs.digitalocean.com/products/droplets/)
- [Nginx Beginner's Guide](http://nginx.org/en/docs/beginners_guide.html)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [SSH Key Authentication](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/)
- [UFW Firewall Guide](https://help.ubuntu.com/community/UFW)

## Troubleshooting

### Common Issues and Solutions

1. **Cannot connect via SSH**
   - Verify the IP address is correct
   - Check if you're using the right SSH key or password
   - Ensure your local firewall allows outgoing SSH connections

2. **Website not accessible from browser**
   - Verify Nginx is running: `systemctl status nginx`
   - Check UFW firewall: `ufw status`
   - Confirm port 80 is open: `ss -tuln | grep :80`

3. **About.html giving 404 errors**
   - Ensure the file exists: `ls -la /var/www/html/about.html`
   - Check file permissions: `chmod 644 /var/www/html/about.html`
   - Verify Nginx configuration: `nginx -t`
   - Check Nginx error logs: `tail /var/log/nginx/error.log`

4. **Permission denied errors**
   - Check file ownership: `ls -la /var/www/html/`
   - Fix permissions: `chown -R www-data:www-data /var/www/html`

5. **Nginx configuration errors**
   - Test configuration: `nginx -t`
   - Check syntax in configuration files
   - Review error logs: `tail /var/log/nginx/error.log`

## Cleanup Instructions

**⚠️ IMPORTANT: Follow these steps to avoid ongoing charges**

1. **Destroy the Droplet**
   - Go to the DigitalOcean Control Panel
   - Navigate to **"Droplets"** in the left sidebar
   - Find your droplet (`web-server-01`)
   - Click the **"More"** menu (three dots)
   - Select **"Destroy"**
   - Type the droplet name to confirm
   - Click **"Destroy Droplet"**

2. **Verify Deletion**
   - Ensure the droplet no longer appears in your dashboard
   - Check your billing page to confirm no ongoing charges

3. **Optional: Remove SSH Key**
   - If you created a new SSH key specifically for this project
   - Go to **"Settings"** → **"Security"** → **"SSH Keys"**
   - Delete the key if no longer needed

## Next Steps

Congratulations! You've successfully deployed your first website on DigitalOcean. You've learned:

- How to provision cloud infrastructure
- Basic Linux system administration
- Web server configuration
- Security best practices with firewalls
- SSH connectivity and remote server management

**Ready for the next challenge?** Continue with [Project 2: Containerize a Simple Application with Docker](../02-dockerize-nodejs-app) to learn about containerization!
