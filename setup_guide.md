# Plant Monitor Setup Guide

## 📦 What You Need to Add

### 1. Dependencies in `pubspec.yaml`

Add these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0  # For API requests

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

Then run: `flutter pub get`

### 2. Create the Service File

Create a new directory and file:
- `lib/services/esp32_service.dart` (use the code from the ESP32 Service artifact)

### 3. Update Existing Files

Replace your existing files with the updated versions:
- `lib/screens/dashboard_screen.dart`
- `lib/screens/ip_entry_screen.dart`

### 4. Plant Image Assets

You'll need to add plant images to show different health states. Create these folders:

```
assets/
  images/
    sprout.png (you already have this)
    plant_thriving.png   (healthy, vibrant plant)
    plant_healthy.png    (good condition plant)
    plant_stressed.png   (slightly wilted)
    plant_struggling.png (very wilted)
    plant_critical.png   (nearly dead plant)
```

**Note:** The app will fallback to `sprout.png` if specific status images aren't found.

### 5. Update `pubspec.yaml` Assets

Make sure your assets are declared:

```yaml
flutter:
  assets:
    - assets/images/
```

---

## 🚀 Running the Mock Server

### Option 1: Run on Port 80 (Recommended - matches ESP32)

**Linux/Mac:**
```bash
sudo python3 esp32_mock_server.py
```

**Windows (Run as Administrator):**
```bash
python esp32_mock_server.py
```

### Option 2: Run on Port 8080 (No admin needed)

If you don't want to use sudo/admin rights, edit the server file:

Change line: `app.run(host='0.0.0.0', port=80, debug=True)`

To: `app.run(host='0.0.0.0', port=8080, debug=True)`

Then access using: `http://YOUR_IP:8080/api/status`

---

## 🌐 Finding Your Computer's IP Address

### Windows:
```cmd
ipconfig
```
Look for "IPv4 Address" under your active connection

### Mac:
```bash
ifconfig | grep "inet "
```
or: System Preferences → Network

### Linux:
```bash
ip addr show
```
or: `hostname -I`

---

## 📱 Testing the App

1. **Start the mock server** on your computer
2. **Connect your phone** to the same WiFi network as your computer
3. **Launch the Flutter app**
4. **Enter your computer's IP** in the IP entry screen
   - Example: `192.168.1.100` (use YOUR actual IP)
   - If using port 8080: You'll need to modify the service to use `:8080`
5. **Click "Conectar"** - it will test the connection
6. **View the dashboard** - data will update every 2 minutes automatically

---

## 🎮 Plant Health Status Levels

The app calculates health based on sensor readings:

| Health Score | Status | Emoji | Description |
|-------------|--------|-------|-------------|
| 80-100 | **Florescendo** (Thriving) | 😊 | Perfect conditions! |
| 60-79 | **Saudável** (Healthy) | 🙂 | Developing well |
| 40-59 | **Estressada** (Stressed) | 😐 | Needs attention |
| 20-39 | **Sofrendo** (Struggling) | ☹️ | Poor conditions |
| 0-19 | **Crítico** (Critical) | 😰 | Critical - act now! |

### Optimal Ranges Used:
- **Temperature:** 20-25°C (ideal)
- **Light:** 400-800 lux (ideal)
- **Soil Moisture:** 50-70% (ideal)

Values outside these ranges decrease the health score.

---

## 🔧 Customizing Parameters

### Adjusting Update Frequency

In `dashboard_screen.dart`, change:

```dart
_esp32Service.startPeriodicUpdates(
  interval: const Duration(minutes: 2),  // Change this
);
```

### Changing Optimal Ranges

In `esp32_service.dart`, modify the `getHealthScore()` method to adjust penalties and ranges.

### Mock Server Data Ranges

In `esp32_mock_server.py`, edit the `generate_sensor_data()` function:

```python
"temperature": round(random.uniform(18.0, 28.0), 1),  # Adjust min/max
"light": random.randint(200, 1000),                   # Adjust range
"soil_moisture": round(random.uniform(30.0, 80.0), 1), # Adjust range
```

---

## 🧪 Testing Different Scenarios

### Test Connection Failure:
- Enter a wrong IP address
- See the error handling and retry options

### Test Data Updates:
- Pull down on the dashboard to refresh
- Wait 2 minutes to see automatic update

### Test Different Plant States:
- The mock server generates random values
- Refresh multiple times to see different health statuses

---

## 🔄 When You Connect to Real ESP32

When your ESP32 is ready:

1. The ESP32 should respond to `GET http://[ESP32_IP]/api/status` with JSON like:

```json
{
  "timestamp": "2025-01-15T10:30:00",
  "temperature": 23.5,
  "humidity": 60.0,
  "light": 650,
  "soil_moisture": 55.0,
  "recommendations": {
    "temperature": "ideal",
    "light": "ideal",
    "soil_moisture": "ideal"
  }
}
```

2. Just enter the ESP32's IP in the app - no code changes needed!

3. The app will automatically:
   - Connect to the ESP32
   - Fetch data every 2 minutes
   - Calculate plant health
   - Update the UI

---

## 🐛 Troubleshooting

### "Connection error" message:
- Check if mock server is running
- Verify you're on the same WiFi network
- Check firewall isn't blocking port 80/8080

### "IP address not configured":
- Make sure you entered an IP in the IP entry screen
- Go to Settings → "Reconfigurar IP"

### Images not showing:
- Verify assets are in `assets/images/` folder
- Check `pubspec.yaml` includes assets
- Run `flutter clean` then `flutter pub get`

### Data not updating:
- Check server console for requests
- Look at "Última atualização" time on dashboard
- Pull down to manually refresh

---

## 📊 API Endpoints Reference

Your mock server (and future ESP32) should support:

- `GET /api/status` - All sensor data + recommendations
- `GET /api/temperature` - Temperature only
- `GET /api/light` - Light level only
- `GET /api/soil` - Soil moisture only
- `GET /api/health` - Health check endpoint

---

## ✨ Next Steps

1. **Create plant images** for different health states
2. **Test thoroughly** with the mock server
3. **Adjust parameters** to match your needs
4. **Prepare your ESP32** to match the JSON format
5. **Connect and enjoy** your plant monitoring Tamagotchi!

Good luck with your project! 🌱
