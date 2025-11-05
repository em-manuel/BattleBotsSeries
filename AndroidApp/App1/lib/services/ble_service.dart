import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? txCharacteristic;
  
  final StreamController<List<ScanResult>> _scanResultsController = 
      StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;
  
  final StreamController<bool> _connectionStateController = 
      StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;

  List<ScanResult> _latestScanResults = [];

  // Start scanning for BLE devices
  Future<void> startScan() async {
    try {
      _latestScanResults.clear();
      
      // Stop any ongoing scan
      await FlutterBluePlus.stopScan();
      
      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        _latestScanResults = results;
        _scanResultsController.add(results);
      });

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      print('Error starting scan: $e');
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  // Connect to a BLE device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      connectedDevice = device;
      
      // Listen to connection state
      device.connectionState.listen((state) {
        _connectionStateController.add(state == BluetoothConnectionState.connected);
      });

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      // Find the characteristic to send commands
      // This assumes your ESP32 has a UART service with TX characteristic
      // You may need to adjust the UUID based on your ESP32 configuration
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            txCharacteristic = characteristic;
            print('Found TX characteristic: ${characteristic.uuid}');
            break;
          }
        }
        if (txCharacteristic != null) break;
      }

      _connectionStateController.add(true);
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  // Disconnect from device
  Future<void> disconnect() async {
    try {
      if (connectedDevice != null) {
        await connectedDevice!.disconnect();
        connectedDevice = null;
        txCharacteristic = null;
        _connectionStateController.add(false);
      }
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Send command to ESP32
  Future<void> sendCommand(String command) async {
    if (txCharacteristic == null) {
      print('No TX characteristic found');
      return;
    }

    try {
      await txCharacteristic!.write(command.codeUnits, withoutResponse: true);
      print('Sent command: $command');
    } catch (e) {
      print('Error sending command: $e');
    }
  }

  // Check if Bluetooth is available and turned on
  Future<bool> isBluetoothAvailable() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        return false;
      }
      
      var adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      print('Error checking Bluetooth: $e');
      return false;
    }
  }

  void dispose() {
    _scanResultsController.close();
    _connectionStateController.close();
  }
}
