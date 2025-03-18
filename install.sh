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

# Setup SPI Display
echo "Setup SPI Display. Reboot required. (y/n)"
read -p "Enter y or n: " answer
if [ "$answer" = "y" ]; then
    sudo bash display_only_cli.sh
    sudo reboot
fi


