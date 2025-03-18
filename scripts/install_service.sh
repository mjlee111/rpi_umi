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

echo "alias udp_restart='sudo systemctl restart udpstream.service'" >> ~/.bashrc
echo "alias udp_log='journalctl -u udpstream.service -f'" >> ~/.bashrc
echo "alias udp_status='sudo systemctl status udpstream.service'" >> ~/.bashrc

source ~/.bashrc

echo "Alias udp_restart, udp_log, udp_status has been added to your bashrc"

echo "You can now use the following commands to manage the service:"
echo "  - sudo systemctl start/stop udpstream"
echo "  - sudo systemctl restart udpstream"
echo "  - sudo journalctl -u udpstream -f"
echo "  - sudo systemctl status udpstream"

echo "You can also use the following aliases:"
echo "  - udp_restart"
echo "  - udp_log"
echo "  - udp_status"


