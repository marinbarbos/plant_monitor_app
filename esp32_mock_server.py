from flask import Flask, jsonify
from flask_cors import CORS
import random
from datetime import datetime

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Simulated sensor data
def generate_sensor_data():
    """Generate random sensor readings similar to ESP32"""
    return {
        "timestamp": datetime.now().isoformat(),
        "temperature": round(random.uniform(18.0, 28.0), 1),  # °C
        "humidity": round(random.uniform(40.0, 70.0), 1),      # %
        "light": random.randint(200, 1000),                    # Lux or sensor value
        "soil_moisture": round(random.uniform(30.0, 80.0), 1), # %
        "status": random.choice(["happy", "neutral", "sad"]),
        "device_id": "ESP32_MOCK_001"
    }

# Basic sensor status
def get_sensor_status(value, optimal_min, optimal_max):
    """Determine if sensor value is in optimal range"""
    if optimal_min <= value <= optimal_max:
        return "ideal"
    elif value < optimal_min:
        return "aumentar"  # increase
    else:
        return "diminuir"  # decrease

@app.route('/api/status', methods=['GET'])
def get_status():
    """Main endpoint that returns all sensor data"""
    data = generate_sensor_data()
    
    # Add status recommendations
    data["recommendations"] = {
        "temperature": get_sensor_status(data["temperature"], 20, 25),
        "light": get_sensor_status(data["light"], 400, 800),
        "soil_moisture": get_sensor_status(data["soil_moisture"], 50, 70)
    }
    
    return jsonify(data)

@app.route('/api/temperature', methods=['GET'])
def get_temperature():
    """Get only temperature data"""
    temp = round(random.uniform(18.0, 28.0), 1)
    return jsonify({
        "temperature": temp,
        "unit": "celsius",
        "status": get_sensor_status(temp, 20, 25)
    })

@app.route('/api/humidity', methods=['GET'])
def get_humidity():
    """Get only humidity data"""
    humidity = round(random.uniform(40.0, 70.0), 1)
    return jsonify({
        "humidity": humidity,
        "unit": "percent"
    })

@app.route('/api/light', methods=['GET'])
def get_light():
    """Get only light data"""
    light = random.randint(200, 1000)
    return jsonify({
        "light": light,
        "unit": "lux",
        "status": get_sensor_status(light, 400, 800),
        "description": "claro" if light > 500 else "escuro"
    })

@app.route('/api/soil', methods=['GET'])
def get_soil():
    """Get only soil moisture data"""
    moisture = round(random.uniform(30.0, 80.0), 1)
    return jsonify({
        "soil_moisture": moisture,
        "unit": "percent",
        "status": get_sensor_status(moisture, 50, 70)
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "online",
        "device": "ESP32_MOCK",
        "version": "1.0.0"
    })

@app.route('/', methods=['GET'])
def index():
    """Root endpoint with API information"""
    return jsonify({
        "message": "ESP32 Mock Server",
        "endpoints": [
            "/api/status - Get all sensor data",
            "/api/temperature - Get temperature only",
            "/api/humidity - Get humidity only",
            "/api/light - Get light level only",
            "/api/soil - Get soil moisture only",
            "/api/health - Health check"
        ]
    })

if __name__ == '__main__':
    print("=" * 50)
    print("ESP32 Mock Server Starting...")
    print("=" * 50)
    print("Server will run on: http://0.0.0.0:80")
    print("Access from your device using your computer's IP address")
    print("Example: http://192.168.1.100:80/api/status")
    print("=" * 50)
    
    # Run on port 80 to simulate ESP32, use 0.0.0.0 to allow external connections
    app.run(host='0.0.0.0', port=80, debug=True)
