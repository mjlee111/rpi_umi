#!/bin/bash

read -p "Enter your username: " username

sudo bash -c "cat > /etc/systemd/system/udpstream.service" <<EOL
[Unit]
Description=UDP Stream Python Service
After=network.target

[Service]
ExecStart=/home/$username/rpi_umi/scripts/umi_script.sh
WorkingDirectory=/home/$username/rpi_umi/scripts
StandardOutput=inherit
StandardError=inherit
Restart=always
User=$username

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable udpstream.service
sudo systemctl start udpstream.service

echo "Service udpstream has been installed and started."
echo "You can check the status with: sudo systemctl status udpstream"
echo "You can check the logs with: sudo journalctl -u udpstream -f"
echo "To start/stop the service: sudo systemctl start/stop udpstream"
echo "To restart the service: sudo systemctl restart udpstream"