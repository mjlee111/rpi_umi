#!/bin/bash
# check if sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo bash install.sh)"
    exit 1
fi

# Install pip
sudo apt-get install python3-pip -y

# Install requirements
python3 -m venv ~/umi
source ~/umi/bin/activate

# Add source to ~/.bashrc
echo "source ~/umi/bin/activate" >> ~/.bashrc

# Install requirements
pip install -r requirements.txt

# Install python requirements
pip install -r requirements.txt

# Display config
echo "Display config required. Start now? (Requires reboot)(y/n)"
read -p "Enter y or n: " answer
if [ "$answer" = "y" ]; then
    sudo bash display_config.sh
fi

# Touch config
echo "Touch config required. Start now? (Requires reboot)(y/n)"
read -p "Enter y or n: " answer
if [ "$answer" = "y" ]; then
    sudo bash touch_config.sh
fi


