# ESP32 Robot Controller - Flutter App

A Flutter application to control an ESP32-based robot via Bluetooth Low Energy (BLE).

## Features

- **BLE Device Scanning**: Scan and list available Bluetooth devices
- **Device Connection**: Connect to your ESP32 robot
- **Movement Controls**: 
  - Forward (F)
  - Backward (B)
  - Left (L)
  - Right (R)
  - Stop (S)
- **Speed Control**: Adjust motor speed (0-255) - sends V+speed value
- **Light Control**: Toggle lights on/off (W=on, w=off)
- **Horn**: Sound the horn (H)

## Commands Sent to ESP32

The app sends single ASCII characters for controls:

- `F` - Forward
- `B` - Backward
- `L` - Turn Left
- `R` - Turn Right
- `S` - Stop
- `V###` - Set speed (e.g., V128, V255)
- `W` - Lights ON
- `w` - Lights OFF
- `H` - Horn

## Setup

### Prerequisites

- Flutter SDK installed
- Android Studio or Xcode (for iOS)
- ESP32 with BLE configured to accept these commands

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### Android Configuration

The app requires the following permissions (already configured):
- Bluetooth
- Bluetooth Admin
- Bluetooth Scan
- Bluetooth Connect
- Location (required for BLE scanning on Android)

Minimum SDK: 21 (Android 5.0)
Target SDK: 34

### iOS Configuration

Bluetooth permissions are configured in `Info.plist` with usage descriptions.

## ESP32 Configuration

Your ESP32 should:
1. Have BLE enabled
2. Advertise a BLE service with a writable characteristic
3. Listen for the ASCII commands listed above
4. Control the L298 motor driver based on received commands

### Example ESP32 BLE Service Structure

The app will automatically find and use the first writable characteristic it discovers. For best compatibility, use a UART-style BLE service with TX characteristic.

## Usage

1. Launch the app
2. Tap the Bluetooth icon in the app bar
3. Grant Bluetooth and Location permissions when prompted
4. Select your ESP32 device from the list
5. Once connected, use the controls to operate your robot

## Troubleshooting

- **No devices found**: Ensure Bluetooth is enabled and Location permission is granted
- **Connection fails**: Make sure your ESP32 is powered on and advertising
- **Commands not working**: Verify your ESP32 is receiving and processing the ASCII commands correctly

## License

MIT License
