"""
MQTT Client for connecting to ThingsBoard Gateway
Uses MQTT v5 protocol
"""

import paho.mqtt.client as mqtt
import json
import time
import sys

# MQTT Configuration
MQTT_CONFIG = {
    "host": "31.97.60.61",
    "port": 1883,
    "client_id": "8mb6rybljg63kg6ivruu",
    "username": "jtfdracmu93nnckz69kl",
    "password": "xdwvrmmcrlhxhmfqsw0a",
    "topic": "v1/gateway/telemetry"
}


def on_connect(client, userdata, flags, reason_code, properties):
    """Callback when connected to MQTT broker"""
    if reason_code == 0:
        print(f"[SUCCESS] Connected to MQTT broker at {MQTT_CONFIG['host']}:{MQTT_CONFIG['port']}")
        print(f"[INFO] Client ID: {MQTT_CONFIG['client_id']}")
        # Subscribe to the topic
        client.subscribe(MQTT_CONFIG['topic'])
        print(f"[INFO] Subscribed to topic: {MQTT_CONFIG['topic']}")
    else:
        print(f"[ERROR] Connection failed with reason code: {reason_code}")


def on_disconnect(client, userdata, disconnect_flags, reason_code, properties):
    """Callback when disconnected from MQTT broker"""
    print(f"[INFO] Disconnected from MQTT broker. Reason code: {reason_code}")


def on_message(client, userdata, message):
    """Callback when a message is received"""
    print(f"\n[MESSAGE RECEIVED]")
    print(f"  Topic: {message.topic}")
    print(f"  QoS: {message.qos}")
    try:
        payload = json.loads(message.payload.decode('utf-8'))
        print(f"  Payload (JSON): {json.dumps(payload, indent=2)}")
    except json.JSONDecodeError:
        print(f"  Payload (Raw): {message.payload.decode('utf-8')}")


def on_publish(client, userdata, mid, reason_code, properties):
    """Callback when a message is published"""
    print(f"[INFO] Message published (mid: {mid})")


def on_subscribe(client, userdata, mid, reason_codes, properties):
    """Callback when subscribed to a topic"""
    print(f"[INFO] Subscription confirmed (mid: {mid})")


def on_log(client, userdata, level, buf):
    """Callback for logging"""
    print(f"[LOG] {buf}")


def create_mqtt_client():
    """Create and configure MQTT client with v5 protocol"""
    # Create MQTT v5 client
    client = mqtt.Client(
        client_id=MQTT_CONFIG['client_id'],
        protocol=mqtt.MQTTv5,
        callback_api_version=mqtt.CallbackAPIVersion.VERSION2
    )
    
    # Set credentials
    client.username_pw_set(
        username=MQTT_CONFIG['username'],
        password=MQTT_CONFIG['password']
    )
    
    # Set callbacks
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message
    client.on_publish = on_publish
    client.on_subscribe = on_subscribe
    # Uncomment for verbose logging:
    # client.on_log = on_log
    
    return client


def publish_telemetry(client, device_name, key, value):
    """
    Publish a single telemetry value in ThingsBoard gateway format
    Format: {"Device_name":[{"key":value}]}
    
    Args:
        client: MQTT client instance
        device_name: Name of the device (e.g., from BLE scan)
        key: Telemetry key (e.g., Body_Temp, SpO2, BP_SYS, BP_DIA)
        value: Telemetry value
    """
    # Exact ThingsBoard gateway telemetry format: {"Device_name":[{"key":value}]}
    payload = {device_name: [{key: value}]}
    
    message = json.dumps(payload)
    result = client.publish(MQTT_CONFIG['topic'], message, qos=1)
    print(f"[PUBLISH] {message}")
    return result


def publish_all_vitals(client, device_name, body_temp, spo2, bp_sys, bp_dia):
    """
    Publish all vital signs for a device
    
    Args:
        client: MQTT client instance
        device_name: Device name from BLE scan
        body_temp: Body temperature value
        spo2: SpO2 percentage
        bp_sys: Systolic blood pressure
        bp_dia: Diastolic blood pressure
    """
    publish_telemetry(client, device_name, "Body_Temp", body_temp)
    publish_telemetry(client, device_name, "SpO2", spo2)
    publish_telemetry(client, device_name, "BP_SYS", bp_sys)
    publish_telemetry(client, device_name, "BP_DIA", bp_dia)


def main():
    """Main function to run MQTT client and publish vitals"""
    # Device name (would come from BLE scan in real scenario)
    DEVICE_NAME = "NC-Anubhav"
    
    print("=" * 60)
    print("MQTT Client - ThingsBoard Gateway Connection")
    print("=" * 60)
    print(f"Host: {MQTT_CONFIG['host']}")
    print(f"Port: {MQTT_CONFIG['port']}")
    print(f"Topic: {MQTT_CONFIG['topic']}")
    print(f"Device: {DEVICE_NAME}")
    print(f"Protocol: MQTT v5")
    print("=" * 60)
    
    # Create client
    client = create_mqtt_client()
    
    try:
        # Connect to broker
        print(f"\n[INFO] Connecting to {MQTT_CONFIG['host']}:{MQTT_CONFIG['port']}...")
        client.connect(MQTT_CONFIG['host'], MQTT_CONFIG['port'], keepalive=60)
        
        # Start the network loop in a separate thread
        client.loop_start()
        
        # Wait for connection
        time.sleep(2)
        
        # Publish sample vital signs for device NC-Anubhav
        print(f"\n[INFO] Publishing vitals for device: {DEVICE_NAME}")
        print("-" * 40)
        
        # Sample vital values
        publish_telemetry(client, DEVICE_NAME, "Body_Temp", 36.5)
        time.sleep(0.5)
        publish_telemetry(client, DEVICE_NAME, "SpO2", 98)
        time.sleep(0.5)
        publish_telemetry(client, DEVICE_NAME, "BP_SYS", 120)
        time.sleep(0.5)
        publish_telemetry(client, DEVICE_NAME, "BP_DIA", 80)
        
        print("-" * 40)
        print("[INFO] All vitals published successfully!")
        print("\n[INFO] Connection established. Client is running.")
        print("[INFO] Press Ctrl+C to disconnect.\n")
        
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\n[INFO] Shutting down...")
    except Exception as e:
        print(f"[ERROR] {type(e).__name__}: {e}")
        sys.exit(1)
    finally:
        client.loop_stop()
        client.disconnect()
        print("[INFO] Disconnected. Goodbye!")


if __name__ == "__main__":
    main()
