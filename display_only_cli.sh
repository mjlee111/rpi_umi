#!/bin/bash

echo "========================================"
echo "📥 Downloading SPI Display dtbo file..."
echo "========================================"
cd /boot/overlays
sudo wget -O spotpear_240x240_st7789_lcd1inch54.dtbo https://cdn.static.spotpear.com/uploads/download/diver/gm154/spotpear_240x240_st7789_lcd1inch54.dtbo
cd ~

echo "========================================"
echo "⚙️  Configuring /boot/firmware/config.txt"
echo "========================================"
# Comment out default display drivers (KMS/VC4)
sudo sed -i 's/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/' /boot/firmware/config.txt
sudo sed -i 's/^max_framebuffers=2/#max_framebuffers=2/' /boot/firmware/config.txt

# Add SPI display settings (if not already added)
if ! grep -q "spotpear_240x240_st7789_lcd1inch54" /boot/firmware/config.txt; then
sudo tee -a /boot/firmware/config.txt << 'EOF'

# SPI TFT LCD Display Settings
dtparam=spi=on
dtoverlay=spotpear_240x240_st7789_lcd1inch54

# Optional HDMI fallback (may be ignored for SPI LCD)
hdmi_force_hotplug=1
max_usb_current=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt 480 480 60 6 0 0 0
hdmi_drive=2
display_rotate=0
EOF
fi

echo "========================================"
echo "🛑 Disabling GUI autostart (CLI only)"
echo "========================================"
sudo systemctl set-default multi-user.target
sudo systemctl disable lightdm gdm sddm graphical.target || true

echo "========================================"
echo "🛠️  Installing fbcp (Framebuffer Copy)"
echo "========================================"
sudo apt update
sudo apt install -y git libraspberrypi-dev cmake

git clone https://github.com/tasanakorn/rpi-fbcp.git
cd rpi-fbcp
mkdir build && cd build
cmake ..
make
sudo install fbcp /usr/local/bin/fbcp

echo "========================================"
echo "📝 Creating fbcp systemd service"
echo "========================================"

# Create systemd service for fbcp
sudo tee /etc/systemd/system/fbcp.service > /dev/null << 'EOF'
[Unit]
Description=Framebuffer Copy (fbcp) Service
After=multi-user.target

[Service]
ExecStart=/usr/local/bin/fbcp
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Enabling fbcp service..."
sudo systemctl daemon-reload
sudo systemctl enable fbcp.service
sudo systemctl start fbcp.service

echo "========================================"
echo "🎉 Setup complete! Rebooting in 5 seconds..."
echo "========================================"
sleep 5
sudo reboot
