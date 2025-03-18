#!/usr/bin/python

from gpiozero import Button
from signal import pause, signal, SIGINT
import sys
import os

KEY6 = 26
KEY8 = 21

username = os.getlogin()

button6 = Button(KEY6)
button8 = Button(KEY8)

print("UMI Button Initialized")

def handle_button_press(button, key_name):
    print(f"{key_name} PRESS")
    if key_name == "KEY6":
        print("Key Event : Exiting!!!!!!!!!") ## Ctrl+c
        os.system("sudo kill -2 $(pgrep -f 'python3 /home/" + username + "/rpi_umi/umi_button.py')")
    elif key_name == "KEY8":
        print("Key Event : Starting!!!!!!!!!") ## START
        os.system("sudo python3 /home/" + username + "/rpi_umi/umi_stream.py")
        
button6.when_pressed = lambda: handle_button_press(button6, "KEY6")
button8.when_pressed = lambda: handle_button_press(button8, "KEY8")

def signal_handler(sig, frame):
    print("\nProgram terminated by user")
    sys.exit(0)

# Register the signal handler
signal(SIGINT, signal_handler)

print("Key Test Program - Press Ctrl+C to exit")
pause()