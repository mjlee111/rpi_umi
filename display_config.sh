#!/bin/bash
# check if sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "Updating and upgrading packages"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y 

echo "Installing xserver-xorg and xinit"
sudo apt-get install --no-install-recommends xserver-xorg -y
sudo apt-get install --no-install-recommends xinit -y

echo "Installing lightdm"
sudo apt-get install lightdm -y

echo "Installing Raspberry Pi Display Manager"
sudo apt-get install raspberrypi-ui-mods -y


echo "Downloading SPI Display dbto file"
cd /boot/overlays
wget https://cdn.static.spotpear.com/uploads/download/diver/gm154/spotpear_240x240_st7789_lcd1inch54.dtbo
cd

echo "Configuring Display"
echo "Commenting out display lines in /boot/firmware/config.txt"
sudo sed -i 's/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/' /boot/firmware/config.txt
sudo sed -i 's/^max_framebuffers=2/#max_framebuffers=2/' /boot/firmware/config.txt

echo "Adding display overlay to /boot/firmware/config.txt"
sudo tee -a /boot/firmware/config.txt << 'EOF'
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

echo "Enabling Wayland"
sudo raspi-config nonint do_wayland 1

cd

echo "Installing fbcp"
sudo apt update
sudo apt-get install git -y
sudo git clone https://github.com/tasanakorn/rpi-fbcp.git
cd ./rpi-fbcp/
sudo mkdir -m 777 ./build
cd ./build/
sudo apt install libraspberrypi-dev -y
sudo apt-get install cmake -y
sudo cmake ..
sudo make
sudo install fbcp /usr/local/bin/fbcp

echo "Creating .bash_profile with display configuration"
cat > ~/.bash_profile << 'EOF'
if [ "$(cat /proc/device-tree/model | cut -d ' ' -f 3)" = "5" ]; then
export FRAMEBUFFER=/dev/fb1
startx 2> /tmp/xorg_errors
else
export FRAMEBUFFER=/dev/fb0
sleep 20
fbcp &
startx 2> /tmp/xorg_errors
fi
EOF

echo "Reboot required. Reboot now? (y/n)"
read -p "Enter y or n: " answer
if [ "$answer" = "y" ]; then
    sudo reboot
fi













