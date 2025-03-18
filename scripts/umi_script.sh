#!/bin/bash
current_user=$(whoami)
echo "UMI Script"
echo "Current User: $current_user"
if [ "$current_user" = "right" ]; then
    echo "Right User"
    cd /home/right/rpi_umi/py
    python umi_stream.py --host_ip 192.168.0.141 --port 11001 --id UMI_GRIPPER_RIGHT
elif [ "$current_user" = "left" ]; then
    echo "Left User"
    cd /home/left/rpi_umi/py
    python umi_stream.py --host_ip 192.168.0.141 --port 11002 --id UMI_GRIPPER_LEFT
else
    echo "Invalid User"
fi
echo "UMI Script End"