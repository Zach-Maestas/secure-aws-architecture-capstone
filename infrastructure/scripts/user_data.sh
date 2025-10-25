#!/bin/bash
set -e

# Update & install base packages
yum update -y
yum install -y python3 python3-pip git jq

# Ensure pip is available globally
python3 -m ensurepip
python3 -m pip install --upgrade pip

# Pull the latest app code
cd /home/ec2-user
if [ ! -d "app" ]; then
    git clone https://github.com/Zach-Maestas/secure-aws-architecture-capstone.git app
else
    cd app && git pull && cd ..
fi

# Install dependencies globally (system-wide)
cd /home/ec2-user/app/application
if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt --no-cache-dir --break-system-packages
else
    python3 -m pip install flask psycopg2-binary python-dotenv boto3 --no-cache-dir --break-system-packages
fi

# Create systemd service for Flask
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
Environment="PYTHONPATH=/usr/local/lib/python3.7/site-packages:/usr/lib/python3.7/site-packages"

[Install]
WantedBy=multi-user.target
EOL

# Enable & start the service
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
