import asyncio
from bleak import BleakClient, BleakScanner

async def main():
    print("Scanning for BLE devices...")
    devices = await BleakScanner.discover()
    for i, device in enumerate(devices):
        print(f"{i}: {device.name} [{device.address}]")
    if not devices:
        print("No BLE devices found.")
        return
    idx = int(input("Select device index to connect: "))
    address = devices[idx].address
    async with BleakClient(address) as client:
        print(f"Connected to {devices[idx].name} [{address}]")
        print("Services:")
        for service in client.services:
            print(f"- {service}")
        print("Listening for notifications...")
        import json
        def notification_handler(sender, data):
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
            print(json.dumps(ble_json, indent=2))
        notify_chars = []
        print("Characteristics with notify property:")
        for service in client.services:
            for char in service.characteristics:
                if "notify" in char.properties:
                    print(f"- {char.uuid} ({char.description})")
                    notify_chars.append(char)
        if not notify_chars:
            print("No notify characteristics found. Cannot receive data.")
        else:
            for char in notify_chars:
                try:
                    await client.start_notify(char.uuid, notification_handler)
                    print(f"Subscribed to notifications for {char.uuid}")
                except Exception as e:
                    print(f"Failed to subscribe to {char.uuid}: {e}")
            print("Streaming BLE data. Press Ctrl+C to stop...")
            try:
                while True:
                    await asyncio.sleep(3600)  # Sleep long, only wake on Ctrl+C
            except KeyboardInterrupt:
                print("Stopping notifications and disconnecting...")
            except asyncio.CancelledError:
                pass
            finally:
                for char in notify_chars:
                    try:
                        await client.stop_notify(char.uuid)
                        print(f"Unsubscribed from {char.uuid}")
                    except Exception as e:
                        print(f"Failed to unsubscribe from {char.uuid}: {e}")
    print("Disconnected.")

if __name__ == "__main__":
    asyncio.run(main())
