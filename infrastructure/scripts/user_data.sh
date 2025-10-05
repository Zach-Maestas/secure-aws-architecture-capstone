#!/bin/bash
set -e

# Update & install deps
yum update -y
yum install -y python3 git
pip3 install flask psycopg2-binary python-dotenv

# Pull app repo
cd /home/ec2-user
if [ ! -d "app" ]; then
    git clone https://github.com/Zach-Maestas/secure-aws-architecture-capstone.git app
else
    cd app && git pull && cd ..
fi

# Create systemd service for Flask (no DB env vars yet)
sudo tee /etc/systemd/system/flask-app.service > /dev/null <<EOL
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app/application
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable & start the service
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
