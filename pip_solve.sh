#!/bin/bash

# Install pip
sudo apt-get install python3-pip -y

# Set break-system-packages to true
python -m pip config set global.break-system-packages true

