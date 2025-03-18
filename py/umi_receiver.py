import cv2
import argparse
import os
from rpi_umi.py.udp_stream import UDPStream
import time

def main():
    parser = argparse.ArgumentParser(description='UMI Receiver')
    parser.add_argument('--host_ip', type=str, default='0.0.0.0', help='host ip (use 0.0.0.0 to listen on all interfaces)')
    parser.add_argument('--port', type=int, default=11001, help='port')
    parser.add_argument('--id', type=str, default="UMI_RECEIVER", help='Receiver ID')
    args = parser.parse_args()
    
    print(f"[{args.id}] Initializing UDP receiver...")
    print(f"[{args.id}] Host IP: {args.host_ip}")
    print(f"[{args.id}] Port: {args.port}")

    udp_stream = UDPStream(args.id, args.host_ip, args.port, mode="recv")
    udp_stream.start_recv_thread()

    try:
        while True:
            if udp_stream.frame is not None:
                cv2.imshow(f'UDP Stream - {args.id}', udp_stream.frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            time.sleep(0.01)  # Small sleep to prevent CPU overload
            
    except KeyboardInterrupt:
        print("\nShutting down...")
    finally:
        print(f"[{args.id}] Stopping UDP stream...")
        udp_stream.stop_recv_thread()
        print(f"[{args.id}] UDP stream stopped")
        cv2.destroyAllWindows()

if __name__ == "__main__":
    main() 