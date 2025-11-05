// Bare Minimum code for Bluetooth control for RC. 
// Feel free to modify, improve code to suite your need. 
// Customised for arduno Bluetooth controller app from play store. 
// Any arduino BLE app wll work, however. 
// Developed to use inbuilt Bluetooth low energy (BLE) for ESP32 MCU. 
// Note: There might be interferance if many devices are used together. 
// Be sure to rename your device bluetooth's name. 

#include "BluetoothSerial.h" // include bluetooth libraries. 

BluetoothSerial SerialBT; // Initialise. 

// Define motor pins -> motor driver must be connected to these pins. 
// if device behaves in reverse, swap pins in code or wirinf. 
#define IN1 27
#define IN2 26
#define IN3 25
#define IN4 33

// Keep checking for a BLE connections. 
unsigned long lastBTCheck = 0;
const unsigned long btCheckInterval = 20000;  // 1 second

void setup() {
  Serial.begin(115200);
  SerialBT.begin("SoccerBot_Gr_ESP32");  // Bluetooth name
  Serial.println("Bluetooth Started");

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
}

void MoveForward() {
  Serial.println('Forward');
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}

void Moveback() {
  Serial.println('backward');
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
}

void MoveLeft() {
  Serial.println('left');
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}

void MoveRight() {
  Serial.println('right');
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
}

void Stop() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
}

void loop() {
  if (SerialBT.available()) {
    char cmd = SerialBT.read();
    Serial.println(cmd);

    switch (cmd) {
      case 'F':  // Forward
        MoveForward();
        break;

      case 'B':  // Backward
        Moveback();
        break;

      case 'L':  // Left
        MoveLeft();
        break;

      case 'R':  // Right
        MoveRight();
        break;

      case 'S':  // Stop
        Stop(); 
        break;
    }
  } else {
    // Only print message once every second
    unsigned long currentMillis = millis();
    if (currentMillis - lastBTCheck >= btCheckInterval) {
      Serial.println("...");
      lastBTCheck = currentMillis;
    }
  }
}
