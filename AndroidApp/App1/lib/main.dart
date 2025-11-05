import 'package:flutter/material.dart';
import 'services/ble_service.dart';
import 'screens/device_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Robot Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RobotControlScreen(),
    );
  }
}

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  final BleService _bleService = BleService();
  bool _isConnected = false;
  double _speed = 128; // Speed from 0-255
  bool _lightOn = false;
  String _deviceName = 'No Device';

  @override
  void initState() {
    super.initState();
    _bleService.connectionState.listen((connected) {
      setState(() {
        _isConnected = connected;
        if (connected && _bleService.connectedDevice != null) {
          _deviceName = _bleService.connectedDevice!.platformName.isNotEmpty
              ? _bleService.connectedDevice!.platformName
              : 'ESP32 Robot';
        } else {
          _deviceName = 'No Device';
        }
      });
    });
  }

  void _sendCommand(String command) {
    if (_isConnected) {
      _bleService.sendCommand(command);
    } else {
      _showSnackBar('Not connected to device');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _navigateToDeviceList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ESP32 Robot Controller'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
            onPressed: _navigateToDeviceList,
            tooltip: _isConnected ? 'Connected to $_deviceName' : 'Connect to device',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Card(
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected to $_deviceName' : 'Not Connected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Direction Controls
            const Text(
              'Movement Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Forward buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_upward,
                  label: 'Forward',
                  onPressed: () => _sendCommand('F'),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Left, Stop, Right buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_back,
                  label: 'Left',
                  onPressed: () => _sendCommand('L'),
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  onPressed: () => _sendCommand('S'),
                  color: Colors.red,
                  width: 100,
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  icon: Icons.arrow_forward,
                  label: 'Right',
                  onPressed: () => _sendCommand('R'),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Backward button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_downward,
                  label: 'Back',
                  onPressed: () => _sendCommand('B'),
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Speed Control
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Speed',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_speed.toInt()}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _speed,
                      min: 0,
                      max: 255,
                      divisions: 51,
                      label: _speed.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _speed = value;
                        });
                      },
                      onChangeEnd: (value) {
                        // Send speed command (format: V followed by value)
                        _sendCommand('V${value.toInt()}');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Light Control
            Card(
              child: SwitchListTile(
                title: const Text(
                  'Lights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                value: _lightOn,
                onChanged: (value) {
                  setState(() {
                    _lightOn = value;
                  });
                  _sendCommand(value ? 'W' : 'w');
                },
                secondary: Icon(
                  _lightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: _lightOn ? Colors.yellow : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Horn Button
            SizedBox(
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () => _sendCommand('H'),
                icon: const Icon(Icons.volume_up, size: 32),
                label: const Text(
                  'HORN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    double width = 90,
  }) {
    return SizedBox(
      width: width,
      height: 80,
      child: ElevatedButton(
        onPressed: _isConnected ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.all(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
