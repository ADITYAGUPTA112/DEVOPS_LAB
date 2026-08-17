#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating production directory /var/www/jenkins-demo..."
sudo mkdir -p /var/www/jenkins-demo

echo "==> Setting directory ownership to jenkins:www-data..."
sudo chown -R jenkins:www-data /var/www/jenkins-demo

echo "==> Setting directory permissions to 755..."
sudo chmod -R 755 /var/www/jenkins-demo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONF_SRC="${PROJECT_DIR}/nginx/jenkins-demo.conf"
CONF_DEST="/etc/nginx/sites-available/jenkins-demo"

if [ -f "$CONF_SRC" ]; then
    echo "==> Copying Nginx site configuration to ${CONF_DEST}..."
    sudo cp "$CONF_SRC" "$CONF_DEST"
    echo "==> Enabling Nginx site..."
    sudo ln -sf "$CONF_DEST" /etc/nginx/sites-enabled/jenkins-demo
else
    echo "==> Warning: Config file $CONF_SRC not found. Creating directly..."
    sudo bash -c 'cat << "EOF" > /etc/nginx/sites-available/jenkins-demo
server {
    listen 8081;
    listen [::]:8081;
    server_name localhost;
    root /var/www/jenkins-demo;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF'
    sudo ln -sf /etc/nginx/sites-available/jenkins-demo /etc/nginx/sites-enabled/jenkins-demo
fi

echo "==> Testing Nginx configuration..."
sudo nginx -t

echo "==> Reloading Nginx..."
sudo systemctl reload nginx

echo "==> Nginx setup complete. Server listening on http://localhost:8081"
