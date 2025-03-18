#!/bin/bash

KEY6=26
KEY8=21

echo $KEY6 > /sys/class/gpio/export 2>/dev/null || true
echo $KEY8 > /sys/class/gpio/export 2>/dev/null || true

echo "in" > /sys/class/gpio/gpio$KEY6/direction
echo "in" > /sys/class/gpio/gpio$KEY8/direction

echo "UMI Button Initialized"

cleanup() {
    echo $KEY6 > /sys/class/gpio/unexport 2>/dev/null || true
    echo $KEY8 > /sys/class/gpio/unexport 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

while true; do
    if [ $(cat /sys/class/gpio/gpio$KEY6/value) -eq 0 ]; then
        echo "KEY6 PRESS"
        echo "Key Event : Exiting!!!!!!!!!!"
        sudo kill -2 $(pgrep -f 'python3 /home/right/rpi_umi/umi_stream.py')
        sleep 0.3
    fi
    
    if [ $(cat /sys/class/gpio/gpio$KEY8/value) -eq 0 ]; then
        echo "KEY8 PRESS"
        echo "Key Event : Starting!!!!!!!!!!"
        sudo python3 /home/right/rpi_umi/umi_stream.py
        sleep 0.3
    fi
    
    sleep 0.1
done