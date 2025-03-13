import cv2
from udp_stream import UDPStream
import psutil
import os
import time
import argparse
from PyQt5 import QtWidgets, QtCore, QtGui
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
    os.environ["QT_QPA_PLATFORM"] = "eglfs"
    os.environ["DISPLAY"] = ":0"
    
    os.environ["QT_QPA_EGLFS_PHYSICAL_WIDTH"] = "155"
    os.environ["QT_QPA_EGLFS_PHYSICAL_HEIGHT"] = "86"
    
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
        app = QtWidgets.QApplication([])
        window = QtWidgets.QWidget()
        window.setWindowTitle(f"{args.id}")
        window.setFixedSize(240, 240)
        
        logo_label = QtWidgets.QLabel()
        logo_pixmap = QtGui.QPixmap("logo.png")
        logo_pixmap = logo_pixmap.scaledToWidth(200, QtCore.Qt.SmoothTransformation)
        logo_label.setPixmap(logo_pixmap)
        logo_label.setAlignment(QtCore.Qt.AlignCenter)
        
        metrics_label = QtWidgets.QLabel()
        
        toggle_button = QtWidgets.QPushButton("STOP UDP")
        toggle_button.setStyleSheet("color: red;")

        def toggle_stream():
            nonlocal is_streaming
            if not is_streaming:
                udp_stream.start_send_thread()
                toggle_button.setText("STOP UDP")
                toggle_button.setStyleSheet("color: red;")
                is_streaming = True
                print(f"[{args.id}] UDP stream started")
            else:
                udp_stream.stop_send_thread()
                toggle_button.setText("START UDP")
                toggle_button.setStyleSheet("color: green;")
                is_streaming = False
                print(f"[{args.id}] UDP stream stopped")
        
        toggle_button.clicked.connect(toggle_stream)
        
        layout = QtWidgets.QVBoxLayout()
        layout.addWidget(logo_label)
        layout.addWidget(metrics_label)
        layout.addWidget(toggle_button)
        window.setLayout(layout)
        
        def update_metrics():
            metrics_label.setText(
                f"Current IP: {get_local_ip()}\n"
                f"Host IP: {args.host_ip}\n"
                f"Port: {args.port}\n"
                f"CPU Temp: {get_cpu_temperature()}\n"
                f"CPU Usage: {psutil.cpu_percent()}%\n"
                f"Memory Usage: {psutil.virtual_memory().percent}%"
            )
        
        ip_timer = QtCore.QTimer()
        ip_timer.timeout.connect(update_metrics)
        ip_timer.start(60000)
        
        metrics_timer = QtCore.QTimer()
        metrics_timer.timeout.connect(update_metrics)
        metrics_timer.start(1000) 
        
        update_metrics()
        window.show()
        
        app.exec_()
        
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
