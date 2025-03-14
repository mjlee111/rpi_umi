#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Starting Raspberry Pi Display Configuration..."

# Step 1: Copy DTB overlay
echo "Copying DTB overlay..."
cd /boot/overlays
wget -O spotpear_240x240_st7789_lcd1inch54.dtbo https://cdn.static.spotpear.com/uploads/download/diver/gm154/spotpear_240x240_st7789_lcd1inch54.dtbo
cd

# Step 2: Update config.txt
echo "Updating config.txt..."
CONFIG_FILE="/boot/firmware/config.txt"

# Disable KMS
sed -i 's/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/' "$CONFIG_FILE"
sed -i 's/^max_framebuffers=2/#max_framebuffers=2/' "$CONFIG_FILE"

# Add display configuration if not already present
grep -qxF 'dtoverlay=spotpear_240x240_st7789_lcd1inch54' "$CONFIG_FILE" || cat << EOF >> "$CONFIG_FILE"

dtparam=spi=on
dtoverlay=spotpear_240x240_st7789_lcd1inch54
hdmi_force_hotplug=1
max_usb_current=1
hdmi_group=2
hdmi_mode=87
hdmi_cvt 480 480 60 6 0 0 0
hdmi_drive=2
display_rotate=0
EOF

# Step 3: Install and compile fbcp (optional if you only want X11)
echo "Installing and compiling fbcp..."
apt update
apt-get install git libraspberrypi-dev cmake -y
git clone https://github.com/tasanakorn/rpi-fbcp.git
cd ./rpi-fbcp/
mkdir -m 777 ./build
cd ./build/
cmake ..
make
install fbcp /usr/local/bin/fbcp
cd ~

# Step 4: Install X11, LXDE, and fbdev driver
echo "Installing X11, LXDE, and fbdev driver..."
apt-get install --no-install-recommends xserver-xorg xinit xserver-xorg-video-fbdev -y
apt-get install lxde-core lxappearance -y

# Step 5: Disable Wayland and configure boot behavior
echo "Configuring system settings..."
raspi-config nonint do_boot_behaviour B2 # Desktop / CLI → Console Autologin
raspi-config nonint do_wayland 1         # Disable Wayland (force X11)

# Step 6: Configure Xorg fbdev to use fb1
echo "Creating Xorg fbdev config..."
mkdir -p /etc/X11/xorg.conf.d
cat << EOF > /etc/X11/xorg.conf.d/99-fbdev.conf
Section "Device"
    Identifier  "LCD"
    Driver      "fbdev"
    Option      "fbdev" "/dev/fb1"
EndSection
EOF

# Step 7: Configure auto-start for X on LCD using systemd
echo "Creating systemd service for LCD GUI..."
cat << EOF > /etc/systemd/system/lcd-x.service
[Unit]
Description=Start X session on LCD framebuffer
After=graphical.target

[Service]
User=pi
Environment=FRAMEBUFFER=/dev/fb1
ExecStart=/usr/bin/xinit /usr/bin/startlxde -- /usr/bin/Xorg -noreset -keeptty -novtswitch
Restart=always
RestartSec=5

[Install]
WantedBy=graphical.target
EOF

# Enable the service
systemctl daemon-reload
systemctl enable lcd-x.service

# Step 8: Configure touch screen (optional)
echo "Configuring touch screen..."
apt-get install xserver-xorg-input-evdev xinput-calibrator -y
cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf

cat << 'EOF' > /usr/share/X11/xorg.conf.d/99-calibration.conf
Section "InputClass"
        Identifier      "calibration"
        MatchProduct    "ADS7846 Touchscreen"
        Option  "Calibration"   "326 3536 3509 256"
        Option  "SwapAxes"      "1"
        Option "EmulateThirdButton" "1"
        Option "EmulateThirdButtonTimeout" "1000"
        Option "EmulateThirdButtonMoveThreshold" "300"
EndSection
EOF

echo "Configuration complete! System will now reboot..."
sleep 3
reboot
