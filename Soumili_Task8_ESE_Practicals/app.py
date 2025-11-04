from flask import Flask, jsonify
import random
import time
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "status": "healthy",
        "service": "iot-sensor-api",
        "version": "1.0"
    })

@app.route('/sensor/temperature')
def temperature():
    # Simulate some CPU work
    result = 0
    for i in range(100000):
        result += i * random.random()
    
    return jsonify({
        "sensor": "temperature",
        "value": round(random.uniform(20.0, 30.0), 2),
        "unit": "celsius",
        "timestamp": time.time()
    })

@app.route('/sensor/humidity')
def humidity():
    # Simulate some CPU work
    result = 0
    for i in range(100000):
        result += i * random.random()
    
    return jsonify({
        "sensor": "humidity",
        "value": round(random.uniform(40.0, 70.0), 2),
        "unit": "percent",
        "timestamp": time.time()
    })

@app.route('/health')
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
