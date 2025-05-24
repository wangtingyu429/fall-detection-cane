# Fall Detection Cane

這是一個結合 Flutter 與 Arduino Nano 33 IoT 的跌倒偵測拐杖系統。

## 📱 Flutter App
- 使用 `flutter_blue_plus` 連接藍牙拐杖
- 若偵測到拐杖傾倒超過 5 秒，畫面會顯示警報

## 🔧 Arduino 程式
- 使用內建 IMU 感測器判斷拐杖角度
- 通過 BLE 發送傾倒狀態給手機

## 🚀 使用方法
1. 上傳 `arduino_code.ino` 到 Nano 33 IoT
2. 執行 Flutter app（需開啟藍牙權限）
3. 監控畫面即會顯示拐杖狀態
