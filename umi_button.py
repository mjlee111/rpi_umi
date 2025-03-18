#!/usr/bin/python

import RPi.GPIO as GPIO
from signal import pause, signal, SIGINT
import sys
import os

# GPIO 설정
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

KEY6 = 26
KEY8 = 21

# GPIO 핀 설정
GPIO.setup(KEY6, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(KEY8, GPIO.IN, pull_up_down=GPIO.PUD_UP)

print("UMI Button Initialized")

def handle_button_press(channel):
    if channel == KEY6:
        print("KEY6 PRESS")
        print("Key Event : Exiting!!!!!!!!!") ## Ctrl+c
        os.system("sudo kill -2 $(pgrep -f 'python3 /home/right/rpi_umi/umi_stream.py')")
    elif channel == KEY8:
        print("KEY8 PRESS")
        print("Key Event : Starting!!!!!!!!!") ## START
        os.system("sudo python3 /home/right/rpi_umi/umi_stream.py")

# 이벤트 핸들러 등록
GPIO.add_event_detect(KEY6, GPIO.FALLING, callback=handle_button_press, bouncetime=300)
GPIO.add_event_detect(KEY8, GPIO.FALLING, callback=handle_button_press, bouncetime=300)

def signal_handler(sig, frame):
    print("\nProgram terminated by user")
    GPIO.cleanup()
    sys.exit(0)

# Register the signal handler
signal(SIGINT, signal_handler)

print("Key Test Program - Press Ctrl+C to exit")
pause()