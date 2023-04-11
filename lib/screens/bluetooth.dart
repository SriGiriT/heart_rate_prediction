import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heart_rate_prediction/constant.dart';
import 'package:heart_rate_prediction/screens/details.dart';
import 'package:heart_rate_prediction/screens/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../components/reusable_card.dart';
import '../data/data.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late TwilioFlutter twilioFlutter;
  late Gender selectedGender = Gender.male;
  double heartRate = 89;
  double bp = 108;
  double air = 85;
  double temp = 98.6;
  double sp02 = 86;
  late Data1 data;
  @override
  void initState() {
    getUserData();
    twilioFlutter = TwilioFlutter(
        accountSid: "ACe52b8ec3949369210debd07d18593e02",
        authToken: "${dotenv.env['TOKEN']}",
        twilioNumber: "+15074485128");

    super.initState();
  }

  void getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('username') ?? '';
    String email = prefs.getString('age') ?? '';
    String dateOfBirth = prefs.getString('dob') ?? '';
    String bloodGroup = prefs.getString('bloodGroup') ?? '';
    bool hasAttacked = prefs.getBool('hasAttacked') ?? false;
    List<String> emergencyContactsName =
        prefs.getStringList('emergencyContactsName') ?? [];
    List<String> emergencyContactsNumber =
        prefs.getStringList('emergencyContactsNumber') ?? [];
    // EmergencyContact emergencyContacts =
    //     encodedContacts.map((e) => EmergencyContact.fromJson(json.decode(e))).toList()[0];

    setState(() {
      this.data = Data1(
          username: name,
          age: email,
          dob: dateOfBirth.toString().substring(0, 10),
          bloodGroup: bloodGroup,
          hasPreviousAttack: hasAttacked,
          emergencyContactsName: emergencyContactsName,
          emergencyContactsNumber: emergencyContactsNumber);
    });
  }

  void sendSms(String message) async {
    for (int i = 0; i < data.emergencyContactsNumber.length; i++) {
      print(data.emergencyContactsNumber);
      twilioFlutter.sendSMS(
          toNumber: "+91${data.emergencyContactsNumber[i]}",
          messageBody:
              '${data.username} currently have some health issues with readings of\n$message');
    }
  }

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
          // print(String.fromCharCodes(data));
          messages.add(String.fromCharCodes(data));
          String curr = String.fromCharCodes(data);
          List<String> lines = curr.split(RegExp(r"\r\n|\r|\n"));
          print(lines);
          for (String line in lines) {
            List<String> parts = line.split(':');
            // Split each line into key-value pairs
            if (parts.length > 1) {
              String key = parts[0]
                  .trim(); // Extract the key and remove any leading/trailing spaces
              String value = parts[1]
                  .trim(); // Extract the value and remove any leading/trailing spaces
              print("${parts[0]}\n ${parts[1]}");
              switch (key) {
                case "Blood Oxygen":
                  heartRate = double.parse(value.replaceAll('%',
                      '')); // Remove the % symbol and parse the value as a double
                  // Do something with the oxygen value
                  break;
                case "Blood Pressure":
                  bp = double.parse(value.replaceAll('BPM',
                      '')); // Remove the BPM suffix and parse the value as an integer
                  // Do something with the pressure value
                  break;
                case "Air Humidity":
                  air = double.parse(value.replaceAll('%',
                      '')); // Remove the % symbol and parse the value as a double
                  // Do something with the humidity value
                  break;
                case "Body Temperature":
                  temp = double.parse(value.replaceAll('F',
                      '')); // Remove the F suffix and parse the value as a double
                  // Do something with the body temperature value
                  break;
                case "Air Temperature":
                  sp02 = double.parse(value.replaceAll('C',
                      '')); // Remove the C suffix and parse the value as a double
                  // Do something with the air temperature value
                  break;
                default:
                  // Handle unknown keys
                  break;
              }
            }
          }
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
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF0A0E21),
              title: Text('Health Monitor'),
              actions: [
                IconButton(
                    onPressed: () {
                      sendSms(
                          "Emergency Alert\nHeart Rate-$heartRate\nBp-$bp\nAir Humidity-$air\nTemperature-$temp\nSPO2-$sp02");
                    },
                    icon: Icon(Icons.textsms)),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(),
                      ),
                    );
                  },
                )
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Heart Rate',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    heartRate.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  BPM",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Blood Pressure',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    bp.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  mmHg",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Air Humidity',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    air.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  %",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Temperature',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    temp.toString().substring(0, 4),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  F",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ReusableCard(
                          onPress: () {},
                          colour: kActiveCardColour,
                          cardChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'SPO2',
                                style: kLabelTextStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    sp02.toString(),
                                    style: kNumberTextStyle,
                                  ),
                                  Text(
                                    "  %",
                                    style: kLabelTextStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // BottomButton(
                //   buttonTitle: 'CALCULATE',
                //   onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ResultsPage(
                //       bmiResult: calc.calculateBMI(),
                //       resultText: calc.getResult(),
                //       interpretation: calc.getInterpretation(),
                //     ),
                //   ),
                // );
                // },
                // ),
              ],
            ),
          )
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