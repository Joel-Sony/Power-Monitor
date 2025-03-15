import requests
import random
import time

API_URL = "http://localhost:5000/esp32/data"  # Use the correct Flask server URL

while True:
    data = {
        "voltage": round(random.uniform(220, 240), 2),
        "current": round(random.uniform(1, 10), 2)
    }
    try:
        response = requests.post(API_URL, json=data)
        print(f"Sent: {data} | Response: {response.json()}")
    except requests.exceptions.RequestException as e:
        print(f"Error sending data: {e}")
    
    time.sleep(5)  # Send data every 5 seconds
