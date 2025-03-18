#!/bin/bash
current_user=$(whoami)

if [ "$current_user" = "right" ]; then
    echo "Right User"
    cd /home/right/rpi_umi/py
    /usr/bin/python3 umi_stream.py --host_ip 192.168.0.141 --port 11001 --id UMI_GRIPPER_RIGHT
else
    echo "Left User"
    cd /home/left/rpi_umi/py
    /usr/bin/python3 umi_stream.py --host_ip 192.168.0.141 --port 11002 --id UMI_GRIPPER_LEFT
fi