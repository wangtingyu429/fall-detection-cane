#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h>

// 自訂 BLE UUID（不要用標準服務如 2A19）
BLEService fallService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLEByteCharacteristic fallCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);

unsigned long fallStart = 0;
bool hasFallen = false;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  if (!BLE.begin()) {
    Serial.println("BLE init failed!");
    while (1);
  }

  BLE.setLocalName("CaneMonitor");
  BLE.setAdvertisedService(fallService);
  fallService.addCharacteristic(fallCharacteristic);
  BLE.addService(fallService);
  fallCharacteristic.writeValue(0); // 初始狀態

  BLE.advertise();
  Serial.println("BLE device ready and advertising.");

  while (!IMU.begin()) {
    Serial.println("IMU init failed. Retrying...");
    delay(1000);
  }
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    Serial.print("Connected to: ");
    Serial.println(central.address());

    while (central.connected()) {
      float ax, ay, az;

      if (IMU.accelerationAvailable()) {
        IMU.readAcceleration(ax, ay, az);

        float angle = acos(az / sqrt(ax * ax + ay * ay + az * az)) * 180 / PI;
        Serial.print("Tilt angle: ");
        Serial.println(angle);

        if (angle > 70) {
          if (!hasFallen && fallStart == 0) {
            fallStart = millis();
          }
          if (!hasFallen && (millis() - fallStart) > 3000) {
            hasFallen = true;
            Serial.println("🔴 傾倒警報");
            fallCharacteristic.writeValue(1); // 通知跌倒
          }
        } else {
          fallStart = 0;
          if (hasFallen) {
            Serial.println("✅ 狀態恢復正常");
          }
          hasFallen = false;
          fallCharacteristic.writeValue(0); // 通知恢復
        }
      }

      delay(200);
    }

    Serial.println("Disconnected from central.");
  }
}
