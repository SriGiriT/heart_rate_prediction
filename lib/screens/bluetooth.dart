import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:heart_rate_prediction/screens/main_page.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late BluetoothConnection connection;
  bool isConnected = false;
  List<String> messages = [];

  Future<void> connectToDevice() async {
    BluetoothDevice selectedDevice = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiscoveryPage(),
      ),
    );

    if (selectedDevice != null) {
      BluetoothConnection newConnection =
          await BluetoothConnection.toAddress(selectedDevice.address);

      setState(() {
        connection = newConnection;
        isConnected = true;
      });

      newConnection.input!.listen((Uint8List data) {
        setState(() {
          print(String.fromCharCodes(data));
          messages.add(String.fromCharCodes(data));
        });
      });

      newConnection.input!.listen(null, onDone: () {
        setState(() {
          isConnected = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? MainPage()
        : Scaffold(
            appBar: AppBar(
              title: Text('Bluetooth Connection'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isConnected
                        ? Text('Connected')
                        : ElevatedButton(
                            onPressed: connectToDevice,
                            child: Text('Connect'),
                          ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(messages[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class DiscoveryPage extends StatefulWidget {
  @override
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  List<BluetoothDevice> devices = [];

  void discoverDevices() async {
    FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      setState(() {
        devices.add(device.device);
      });
    });
  }

  void cancelDiscovery() {
    FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  void connectToDevice(BluetoothDevice? device) {
    if (device != null) {
      connectToDevice(device);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Devices'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: discoverDevices,
              child: Text('Discover Devices'),
            ),
            SizedBox(height: 16.0),
            Expanded(
                child: devices.length > 0
                    ? ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(devices[index].name ?? "unknown"),
                            subtitle: Text(devices[index].address),
                            onTap: () {
                              Navigator.of(context).pop(devices[index]);
                            },
                          );
                        },
                      )
                    : Text("no")),
          ],
        ),
      ),
    );
  }
}




























/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HC05Bluetooth {
  late BluetoothDevice _device;
  late BluetoothCharacteristic _characteristic;

  Future<List<BluetoothDevice>> scanForDevices() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<BluetoothDevice> devices = [];

    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      BluetoothDevice device = scanResult.device;
      if (!devices.contains(device)) {
        devices.add(device);
      }
    });

    await Future.delayed(Duration(seconds: 4));
    return devices;
  }

  Future<bool> connect(String deviceId, String password) async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<BluetoothDevice> devices = await scanForDevices();
    // List<BluetoothDevice> devices = await flutterBlue.scan(timeout: Duration(seconds: 4));
    for (BluetoothDevice device in devices) {
      if (device.id.toString() == deviceId) {
        _device = device;
        break;
      }
    }

    if (_device == null) {
      print("Device not found");
      return false;
    }

    await _device.connect();

    List<BluetoothService> services = await _device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == "00001101-0000-1000-8000-00805F9B34FB") {
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          if (characteristic.uuid.toString() ==
              "00001101-0000-1000-8000-00805F9B34FB") {
            _characteristic = characteristic;
            break;
          }
        }
        break;
      }
    }

    if (_characteristic == null) {
      print("Could not find HC05 characteristic");
      return false;
    }

    await _characteristic.write(utf8.encode(password));
    await _characteristic.setNotifyValue(true);

    return true;
  }

  Future<void> sendData(String data) async {
    await _characteristic.write(utf8.encode(data));
  }
}


class BluetoothScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _textController = TextEditingController();
  late HC05Bluetooth _bluetooth;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _bluetooth = HC05Bluetooth();
  }

  Future<void> _connect() async {
    bool isConnected = await _bluetooth.connect("HC05 Device ID", "Password");
    setState(() {
      _isConnected = isConnected;
    });
  }

  Future<void> _sendData() async {
    String data = _textController.text;
    await _bluetooth.sendData(data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth Demo'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter data to send',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isConnected ? _sendData : null,
                child: Text('Send'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Connect',
          child: Icon(Icons.bluetooth),
        ),
      ),
    );
  }
}
*/