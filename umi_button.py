#!/usr/bin/python

from gpiozero import Button
from signal import pause
from pynput import keyboard

KEY1 = 3
KEY2 = 5
KEY3 = 6
KEY4 = 16
KEY5 = 13
KEY6 = 26
KEY7 = 19
KEY8 = 21
KEY9 = 20
KEY10 = 15
KEY11 = 12
KEY12 = 14
KEY13 = 23

button1 = Button(KEY1)
button2 = Button(KEY2)
button3 = Button(KEY3)
button4 = Button(KEY4)
button5 = Button(KEY5)
button6 = Button(KEY6)
button7 = Button(KEY7)
button8 = Button(KEY8)
button9 = Button(KEY9)
button10 = Button(KEY10)
button11 = Button(KEY11)
button12 = Button(KEY12)
button13 = Button(KEY13)

print("UMI Button Initialized")

def handle_button_press(button, key_name):
    print(f"{key_name} PRESS")
    if key_name == "KEY1":
        print("Executing KEY1 command")
    elif key_name == "KEY2":
        print("Executing KEY2 command")
    elif key_name == "KEY3":
        print("Executing KEY3 command")
    elif key_name == "KEY4":
        print("Executing KEY4 command")
    elif key_name == "KEY5":
        print("Executing KEY5 command")
    elif key_name == "KEY6":
        print("Executing KEY6 command")
    elif key_name == "KEY7":
        print("Executing KEY7 command")
    elif key_name == "KEY8":
        print("Executing KEY8 command")
    elif key_name == "KEY9":
        print("Executing KEY9 command")
    elif key_name == "KEY10":
        print("Executing KEY10 command")
    elif key_name == "KEY11":
        print("Executing KEY11 command")
    elif key_name == "KEY12":
        print("Executing KEY12 command")
    elif key_name == "KEY13":
        print("Executing KEY13 command")
        
button1.when_pressed = lambda: handle_button_press(button1, "KEY1")
button2.when_pressed = lambda: handle_button_press(button2, "KEY2")
button3.when_pressed = lambda: handle_button_press(button3, "KEY3")
button4.when_pressed = lambda: handle_button_press(button4, "KEY4")
button5.when_pressed = lambda: handle_button_press(button5, "KEY5")
button6.when_pressed = lambda: handle_button_press(button6, "KEY6")
button7.when_pressed = lambda: handle_button_press(button7, "KEY7")
button8.when_pressed = lambda: handle_button_press(button8, "KEY8")
button9.when_pressed = lambda: handle_button_press(button9, "KEY9")
button10.when_pressed = lambda: handle_button_press(button10, "KEY10")
button11.when_pressed = lambda: handle_button_press(button11, "KEY11")
button12.when_pressed = lambda: handle_button_press(button12, "KEY12")
button13.when_pressed = lambda: handle_button_press(button13, "KEY13")

try:
    print("Key Test Program - Press Ctrl+C to exit")
    while True:
        pass
except KeyboardInterrupt:
    print("\nProgram terminated by user")