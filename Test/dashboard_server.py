import asyncio
import json
import websockets
from bleak import BleakClient, BleakScanner

# Configuration
WEBSOCKET_HOST = "localhost"
WEBSOCKET_PORT = 8765

# Global set of connected clients
connected_clients = set()

async def broadcast_data(message):
    if connected_clients:
        # Prepare for broadcasting to all connected web clients
        await asyncio.gather(
            *[client.send(json.dumps(message)) for client in connected_clients],
            return_exceptions=True
        )

async def handle_ble_notifications(sender, data):
    hex_str = ' '.join(f'{b:02X}' for b in data)
    ble_json = {
        "sender": str(sender),
        "raw_hex": hex_str,
        "length": len(data)
    }
    
    if len(data) >= 4:
        ble_type = data[0]
        lsb = data[2]
        msb = data[3]
        rawvalue = msb * 256 + lsb
        
        if rawvalue > 31767:
            rawvalue = rawvalue - 65536
            
        finalvalue = rawvalue / 100.0
            
        ble_json["type"] = ble_type
        if ble_type == 1:
            ble_json["type_name"] = "Temperature"
            ble_json["value"] = finalvalue
        elif ble_type == 2:
            ble_json["type_name"] = "SpO2"
            ble_json["value"] = finalvalue
        elif ble_type == 3:
            ble_json["type_name"] = "BP_SYS"
            ble_json["value"] = rawvalue
        elif ble_type == 4:
            ble_json["type_name"] = "BP_DIA"
            ble_json["value"] = rawvalue
        else:
            ble_json["type_name"] = f"Unknown ({ble_type})"
            ble_json["value"] = rawvalue
    
    print(f"Received {len(data)} bytes [{hex_str}] | Broadcasting: {ble_json.get('type_name', 'Data')} = {ble_json.get('value', 'Unknown')}")
    await broadcast_data(ble_json)

async def ble_manager():
    while True:
        try:
            print("Scanning for BLE devices...")
            devices = await BleakScanner.discover()
            target_device = None
            
            # Look for devices starting with NC, BP, or SP as per application logic
            for d in devices:
                if d.name and (d.name.startswith('NC') or d.name.startswith('BP') or d.name.startswith('SP')):
                    target_device = d
                    break
            
            if not target_device:
                print("No suitable BLE devices found. Retrying in 5s...")
                await asyncio.sleep(5)
                continue
                
            print(f"Found device: {target_device.name} [{target_device.address}]")
            
            async with BleakClient(target_device.address) as client:
                print(f"Connected to {target_device.name}")
                
                # Find the notify characteristic (Nordic UART RX/TX or similar)
                # For this specific hardware, we look for 6e400003
                target_char_uuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
                
                try:
                    await client.start_notify(target_char_uuid, handle_ble_notifications)
                    print(f"Started notifications for {target_char_uuid}")
                    
                    while client.is_connected:
                        await asyncio.sleep(1)
                        
                except Exception as e:
                    print(f"Error in notification loop: {e}")
                finally:
                    await client.stop_notify(target_char_uuid)
                    
        except Exception as e:
            print(f"BLE connection error: {e}. Retrying in 5s...")
            await asyncio.sleep(5)

async def websocket_handler(websocket):
    print(f"New client connected: {websocket.remote_address}")
    connected_clients.add(websocket)
    try:
        await websocket.wait_closed()
    finally:
        connected_clients.remove(websocket)
        print(f"Client disconnected: {websocket.remote_address}")

async def main():
    print(f"Starting WebSocket server on ws://{WEBSOCKET_HOST}:{WEBSOCKET_PORT}")
    server = await websockets.serve(websocket_handler, WEBSOCKET_HOST, WEBSOCKET_PORT)
    
    # Run BLE manager and WebSocket server concurrently
    await asyncio.gather(
        server.wait_closed(),
        ble_manager()
    )

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Server stopped.")
