#!/bin/bash
set -e

# Update & install base packages
yum update -y
yum install -y python3 python3-pip git jq

# Make sure pip is up-to-date and available
python3 -m ensurepip
python3 -m pip install --upgrade pip

# Clone or update the repo
cd /home/ec2-user
if [ ! -d "app" ]; then
    git clone https://github.com/Zach-Maestas/secure-aws-architecture-capstone.git app
else
    cd app && git pull && cd ..
fi

# Install dependencies before systemd runs Flask
cd /home/ec2-user/app/application
if [ -f "requirements.txt" ]; then
    /usr/bin/pip3 install -r requirements.txt
else
    /usr/bin/pip3 install flask psycopg2-binary python-dotenv boto3
fi

# Create systemd service for Flask (after install)
sudo tee /etc/systemd/system/flask-app.service > /dev/null <<EOL
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app/application
ExecStart=/usr/bin/python3 app.py
Restart=always
EnvironmentFile=-/etc/environment

[Install]
WantedBy=multi-user.target
EOL

# Enable & start the service
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
