#!/bin/bash

KEY6=26
KEY8=21

sudo sh -c "echo $KEY6 > /sys/class/gpio/export" 2>/dev/null || true
sudo sh -c "echo $KEY8 > /sys/class/gpio/export" 2>/dev/null || true

sudo sh -c "echo in > /sys/class/gpio/gpio$KEY6/direction"
sudo sh -c "echo in > /sys/class/gpio/gpio$KEY8/direction"

echo "UMI Button Initialized"

cleanup() {
    sudo sh -c "echo $KEY6 > /sys/class/gpio/unexport" 2>/dev/null || true
    sudo sh -c "echo $KEY8 > /sys/class/gpio/unexport" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

read_gpio() {
    local pin=$1
    local value
    value=$(sudo cat /sys/class/gpio/gpio$pin/value 2>/dev/null || echo "1")
    echo $value
}

while true; do
    if [ "$(read_gpio $KEY6)" = "0" ]; then
        echo "KEY6 PRESS"
        echo "Key Event : Exiting!!!!!!!!!!"
        sudo kill -2 $(pgrep -f 'python3 /home/right/rpi_umi/umi_stream.py')
        sleep 0.3
    fi
    
    if [ "$(read_gpio $KEY8)" = "0" ]; then
        echo "KEY8 PRESS"
        echo "Key Event : Starting!!!!!!!!!!"
        sudo python3 /home/right/rpi_umi/umi_stream.py
        sleep 0.3
    fi
    
    sleep 0.1
done