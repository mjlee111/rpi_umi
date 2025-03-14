#!/bin/bash
# check if sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "Installing xserver-xorg-input-evdev"
sudo apt-get install xserver-xorg-input-evdev

echo "Copying 10-evdev.conf to 45-evdev.conf"
sudo cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf

echo "Installing xinput-calibrator"
sudo apt-get install xinput-calibrator

echo "Creating touchscreen calibration configuration"
sudo tee /usr/share/X11/xorg.conf.d/99-calibration.conf << 'EOF'
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

echo "Touchscreen configuration complete. Please reboot your Raspberry Pi."
echo "Reboot now? (y/n)"
read -p "Enter y or n: " answer
if [ "$answer" = "y" ]; then
    sudo reboot
fi





