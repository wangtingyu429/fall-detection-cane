import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const MaterialApp(home: FallStatusPage()));

class FallStatusPage extends StatefulWidget {
  const FallStatusPage({Key? key}) : super(key: key);

  @override
  _FallStatusPageState createState() => _FallStatusPageState();
}

class _FallStatusPageState extends State<FallStatusPage> {
  String status = '尚未連線';
  final String targetDeviceName = 'CaneMonitor';
  final Guid fallCharacteristicUuid = Guid("00002a19-0000-1000-8000-00805f9b34fb"); // Battery Level UUID

  @override
  void initState() {
    super.initState();
    scanAndConnect();
  }

  void scanAndConnect() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.name == targetDeviceName) {
            FlutterBluePlus.stopScan();

            try {
              await r.device.connect(timeout: const Duration(seconds: 10));
              setState(() => status = '✅ 已連線');

              // 稍微延遲確保 Peripheral 初始化完畢
              await Future.delayed(const Duration(seconds: 2));

              List<BluetoothService> services = await r.device.discoverServices();
              for (var service in services) {
                for (var characteristic in service.characteristics) {
                  if (characteristic.uuid == fallCharacteristicUuid) {
                    await characteristic.setNotifyValue(true);
                    characteristic.onValueReceived.listen((value) {
                      int val = value.isNotEmpty ? value.first : 0;
                      setState(() {
                        status = val == 1 ? '🔴 拐杖已倒！' : '✅ 拐杖正常';
                      });
                    });
                  }
                }
              }
            } catch (e) {
              setState(() => status = '❌ 無法連線');
              debugPrint("連線錯誤: $e");
            }
            break; // 找到目標裝置後就停止迴圈
          }
        }
      });
    } catch (e) {
      setState(() => status = '❌ 掃描失敗');
      debugPrint("掃描錯誤: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拐杖傾倒監控')),
      body: Center(
        child: Text(
          status,
          style: const TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
