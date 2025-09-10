#!/bin/bash

# DigitalOcean Static Website Deployment Script
# Project 1: Deploy a Static Website on a DigitalOcean Droplet
# 
# This script automates the installation and configuration of Nginx
# and deploys the static website files.
#
# Usage: Run this script on your Ubuntu 24.04 droplet as root
# curl -sSL https://raw.githubusercontent.com/your-repo/setup.sh | bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run this script as root (use sudo)"
        exit 1
    fi
}

# Function to check Ubuntu version
check_ubuntu() {
    if [ ! -f /etc/lsb-release ]; then
        print_error "This script is designed for Ubuntu systems"
        exit 1
    fi
    
    . /etc/lsb-release
    if [ "$DISTRIB_ID" != "Ubuntu" ]; then
        print_error "This script is designed for Ubuntu systems"
        exit 1
    fi
    
    print_success "Detected Ubuntu $DISTRIB_RELEASE"
}

# Function to update system packages
update_system() {
    print_status "Updating system packages..."
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y curl wget unzip
    print_success "System packages updated"
}

# Function to install Nginx
install_nginx() {
    print_status "Installing Nginx..."
    apt-get install -y nginx
    
    # Start and enable Nginx
    systemctl start nginx
    systemctl enable nginx
    
    # Check if Nginx is running
    if systemctl is-active --quiet nginx; then
        print_success "Nginx installed and started successfully"
    else
        print_error "Failed to start Nginx"
        exit 1
    fi
}

# Function to configure firewall
configure_firewall() {
    print_status "Configuring UFW firewall..."
    
    # Allow SSH (important!)
    ufw allow ssh
    
    # Allow HTTP and HTTPS
    ufw allow 'Nginx Full'
    
    # Enable firewall
    ufw --force enable
    
    print_success "Firewall configured successfully"
    print_status "UFW status:"
    ufw status
}

# Function to backup default Nginx files
backup_defaults() {
    print_status "Backing up default Nginx files..."
    
    if [ -f /var/www/html/index.nginx-debian.html ]; then
        mv /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.backup
        print_success "Default Nginx page backed up"
    fi
}

# Function to create website files
create_website_files() {
    print_status "Creating website files..."
    
    # Note: In a real deployment, these files would be downloaded from a repository
    # For this example, we'll create basic placeholder files
    
    cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Journey - Project 1 Complete!</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 40px; background: #f4f4f4; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        h1 { color: #667eea; text-align: center; margin-bottom: 30px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .info { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .tech-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
        .tech-item { background: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Project 1 Complete!</h1>
        
        <div class="success">
            <strong>Congratulations!</strong> You have successfully deployed a static website on a DigitalOcean Droplet using Nginx.
        </div>
        
        <div class="info">
            <strong>Note:</strong> This is a basic version created by the deployment script. 
            To see the full website with complete styling, please upload the provided HTML, CSS, and JavaScript files manually.
        </div>
        
        <h2>What You've Accomplished:</h2>
        <ul>
            <li>✅ Created a DigitalOcean Droplet</li>
            <li>✅ Connected via SSH</li>
            <li>✅ Installed and configured Nginx</li>
            <li>✅ Configured UFW firewall</li>
            <li>✅ Deployed a static website</li>
        </ul>
        
        <h2>Technologies Used:</h2>
        <div class="tech-list">
            <div class="tech-item">
                <strong>DigitalOcean</strong><br>
                Cloud Infrastructure
            </div>
            <div class="tech-item">
                <strong>Ubuntu 24.04</strong><br>
                Operating System
            </div>
            <div class="tech-item">
                <strong>Nginx</strong><br>
                Web Server
            </div>
            <div class="tech-item">
                <strong>UFW</strong><br>
                Firewall
            </div>
        </div>
        
        <h2>Next Steps:</h2>
        <p>Ready to continue your DevOps journey? Head to <strong>Project 2: Containerize a Simple Application with Docker</strong></p>
        
        <div class="info">
            <strong>Remember:</strong> Don't forget to clean up your resources when you're done to avoid unexpected charges!
        </div>
    </div>
</body>
</html>
EOF

    print_success "Basic website files created"
}

# Function to configure Nginx server block
configure_nginx() {
    print_status "Configuring Nginx server block..."
    
    # Create custom server block configuration
    cat > /etc/nginx/sites-available/static-website << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name _;
    root /var/www/html;
    index index.html index.htm;
    
    access_log /var/log/nginx/static-website.access.log;
    error_log /var/log/nginx/static-website.error.log;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Cache static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security: Hide Nginx version
    server_tokens off;
    
    # Security: Block access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/static-website /etc/nginx/sites-enabled/
    
    # Remove default site
    rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    if nginx -t; then
        systemctl reload nginx
        print_success "Nginx configuration updated successfully"
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
}

# Function to set proper permissions
set_permissions() {
    print_status "Setting proper file permissions..."
    
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    print_success "File permissions set correctly"
}

# Function to run tests
run_tests() {
    print_status "Running deployment tests..."
    
    # Test if Nginx is running
    if systemctl is-active --quiet nginx; then
        print_success "✅ Nginx is running"
    else
        print_error "❌ Nginx is not running"
        return 1
    fi
    
    # Test if port 80 is listening
    if ss -tuln | grep -q ":80 "; then
        print_success "✅ Port 80 is listening"
    else
        print_error "❌ Port 80 is not listening"
        return 1
    fi
    
    # Test HTTP response
    if curl -s -o /dev/null -w "%{http_code}" localhost | grep -q "200"; then
        print_success "✅ Website is responding correctly"
    else
        print_error "❌ Website is not responding correctly"
        return 1
    fi
    
    print_success "All tests passed!"
}

# Function to display final information
display_final_info() {
    echo ""
    echo "=================================================="
    echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE! 🎉${NC}"
    echo "=================================================="
    echo ""
    echo "Your static website is now live!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Visit your website at: http://$(curl -s ifconfig.me)"
    echo "2. Upload the complete website files for full styling"
    echo "3. Consider setting up SSL/TLS for HTTPS"
    echo ""
    echo -e "${YELLOW}Important:${NC}"
    echo "• Remember to destroy your droplet when done to avoid charges"
    echo "• Check your DigitalOcean billing dashboard regularly"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "• Check Nginx status: systemctl status nginx"
    echo "• View access logs: tail -f /var/log/nginx/access.log"
    echo "• View error logs: tail -f /var/log/nginx/error.log"
    echo "• Test Nginx config: nginx -t"
    echo ""
    echo "Ready for Project 2? Learn Docker containerization next!"
    echo "=================================================="
}

# Main execution
main() {
    echo "=================================================="
    echo "DigitalOcean Static Website Deployment Script"
    echo "Project 1: DevOps Journey"
    echo "=================================================="
    echo ""
    
    check_root
    check_ubuntu
    update_system
    install_nginx
    configure_firewall
    backup_defaults
    create_website_files
    configure_nginx
    set_permissions
    run_tests
    display_final_info
}

# Run main function
main "$@"
