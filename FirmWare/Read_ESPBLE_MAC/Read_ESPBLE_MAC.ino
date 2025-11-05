// Requires: ESP32 Arduino core + "ESP32 BLE Arduino" library
#include <BLEDevice.h>
#include "esp_system.h"  // for esp_read_mac

String macToShortName() {
  uint8_t mac[6];
  // Read the base MAC for WiFi (or use ESP_MAC_BT)
  // esp_read_mac(mac, ESP_MAC_WIFI_STA); // or ESP_MAC_BT
  esp_read_mac(mac, ESP_MAC_BT);  // or ESP_MAC_BT
  // Use last 3 bytes -> format as 6 hex chars
  char buf[16];
  sprintf(buf, "MSGarageBot-%02X%02X%02X", mac[3], mac[4], mac[5]);
  return String(buf);
}

void setup() {
  Serial.begin(115200);
  delay(500);

  String deviceName = macToShortName();
  Serial.println("Device name: " + deviceName);

  BLEDevice::init(deviceName.c_str());  // sets the local BLE name
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService("1234");
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->start();

  Serial.println("BLE advertising started as: " + deviceName);
}

void loop() {
  delay(1000);
}
