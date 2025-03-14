import cv2
from udp_stream import UDPStream
import psutil
import os
import time
import argparse
from PyQt6 import QtWidgets, QtCore, QtGui
import socket

def get_cpu_temperature():
    try:
        temps = psutil.sensors_temperatures()
        if 'cpu_thermal' in temps:
            return f"{temps['cpu_thermal'][0].current}°C"
        elif 'coretemp' in temps:
            return f"{temps['coretemp'][0].current}°C"
        else:
            return "N/A"
    except:
        return "N/A"

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "N/A"

def main():
    os.environ["XDG_RUNTIME_DIR"] = "/tmp/runtime-root"
    
    parser = argparse.ArgumentParser(description='UMI')
    parser.add_argument('--host_ip', type=str, default='192.168.0.141', help='host ip')
    parser.add_argument('--port', type=int, default=11001, help='port')
    parser.add_argument('--id', type=str, default="UMI_GRIPPER_LEFT", help='Camera ID')
    args = parser.parse_args()
    
    print(f"[{args.id}] Initializing UDP stream...")
    print(f"[{args.id}] Host IP: {args.host_ip}")
    print(f"[{args.id}] Port: {args.port}")

    udp_stream = UDPStream(args.id, args.host_ip, args.port, mode="send")
    try:
        udp_stream.open_camera()
    except Exception as e:
        print(f"[{args.id}] Error opening camera: {e}")
        return
    print(f"[{args.id}] Camera opened")
    udp_stream.start_send_thread()

    is_streaming = True
    
    try:
        while True:
            print(f"\n[{args.id}] Status Update:")
            print(f"Current IP: {get_local_ip()}")
            print(f"Host IP: {args.host_ip}")
            print(f"Port: {args.port}")
            print(f"CPU Temp: {get_cpu_temperature()}")
            print(f"CPU Usage: {psutil.cpu_percent()}%")
            print(f"Memory Usage: {psutil.virtual_memory().percent}%")
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\nShutting down...")
    finally:
        if is_streaming:
            print(f"[{args.id}] Stopping UDP stream...")
            udp_stream.stop_send_thread()
            print(f"[{args.id}] UDP stream stopped")
        try:
            udp_stream.close_camera()
        except Exception as e:
            print(f"[{args.id}] Error closing camera: {e}")

if __name__ == "__main__":
    main()
