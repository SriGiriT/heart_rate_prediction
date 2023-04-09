import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    BluetoothDevice? device = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BluetoothDeviceListPage(),
      ),
    );

    if (device != null) {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device: ${device.name}');
    } else {
      print('No device selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Connection'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Connect to Bluetooth'),
          onPressed: connectToDevice,
        ),
      ),
    );
  }
}

class BluetoothDeviceListPage extends StatefulWidget {
  const BluetoothDeviceListPage({Key? key}) : super(key: key);

  @override
  _BluetoothDeviceListPageState createState() => _BluetoothDeviceListPageState();
}

class _BluetoothDeviceListPageState extends State<BluetoothDeviceListPage> {
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    getBondedDevices();
  }

  Future<void> getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = [];

    try {
      bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print('Error getting bonded devices: $e');
    }

    setState(() {
      devices = bondedDevices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Bluetooth Device'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].name!),
            subtitle: Text(devices[index].address),
            onTap: () {
              Navigator.of(context).pop(devices[index]);
            },
          );
        },
      ),
    );
  }
}
