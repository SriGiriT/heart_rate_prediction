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
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late TwilioFlutter twilioFlutter;
  String tempp = "";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Gender selectedGender = Gender.male;
  double heartRate = 89;
  double bp = 108;
  double air = 85;
  double temp = 98.6;
  double sp02 = 86;
  late Data1 data;
  bool isAlreadyAttacked = false;
  @override
  void initState() {
    getPermission();
    getUserData();
    twilioFlutter = TwilioFlutter(
        accountSid: "ACe52b8ec3949369210debd07d18593e02",
        authToken: "${dotenv.env['TOKEN']}",
        twilioNumber: "+15074485128");
    super.initState();
  }

  Future<void> getPermission() async {
    if (await Permission.location.isGranted) {
    } else {
      final status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
      } else {
        bool result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Permission required'),
                content:
                    Text('The app needs permission to access nearby devices.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
    }
    if (await Permission.bluetooth.isGranted) {
    } else {
      final status = await Permission.bluetooth.request();
      if (status == PermissionStatus.granted) {
      } else {
        bool result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Permission required'),
                content:
                    Text('The app needs permission to access nearby devices.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
    }
  }

  List<String> extractValues(String input) {
    List<String> values = [];
    List<String> val = ["BPM", "mmHg", "%", "F", "%", "", ""];
    int ind = 0;
    String varr = val[ind];
    for (int i = 0; i < input.length; i++) {
      if (input[i] == ':') {
        int endIndex = input.indexOf("$varr", i + 1);
        if (endIndex == -1) {
          values.add(input.substring(i + 1).trim());
          break;
        } else {
          String value = input.substring(i + 1, endIndex).trim();
          values.add(value);
          i = endIndex;
        }
        if (ind >= val.length) break;
        varr = val[++ind];
      }
    }
    return values;
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

  void sendSms(String message, String particular) async {
    for (int i = 0; i < data.emergencyContactsNumber.length; i++) {
      print(data.emergencyContactsNumber);
      twilioFlutter
          .sendSMS(
              toNumber: "+91${data.emergencyContactsNumber[i]}",
              messageBody: particular == "" ?
                  '${data.username} currently have some health issues with readings of\n$message' : "'${data.username} currently have abnormal $particular reading of\n$message'")
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: kActiveCardColour,
          content: Text(
            'Message sent! to ${data.emergencyContactsName[i]}',
            style: kLabelTextStyle.copyWith(color: Colors.white),
          ),
          duration: Duration(seconds: 4),
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Message wasn't sent!"),
          duration: Duration(seconds: 4),
        ));
      });
    }
  }

  late BluetoothConnection connection;
  bool isConnected = false;
  List<String> messages = [];

  Future<void> connectToDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String seleceddevice = prefs.getString('device') ?? "";
    BluetoothDevice selectedDevice = seleceddevice == ""
        ? await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DiscoveryPage(),
            ),
          )
        : BluetoothDevice(address: seleceddevice);

    if (selectedDevice != null) {
      BluetoothConnection newConnection =
          await BluetoothConnection.toAddress(selectedDevice.address);
      prefs.setString('device', selectedDevice.address);
      setState(() {
        connection = newConnection;
        isConnected = true;
      });

      newConnection.input!.listen((Uint8List data) {
        setState(() {
          tempp += String.fromCharCodes(data)
              .replaceAll(RegExp(r"\r\n|\r|\n"), '')
              .replaceAll('\n', '');
          if (tempp.length > 90) {
            List<String> lines = [
              "Heart Rate:",
              "BP:",
              "Air Humidity:",
              "Temperature:",
              "SPO2:",
              ""
            ];
            List<String> values = extractValues(tempp);
            for (int i = 0; i < values.length; i++) {
              lines[i] += values[i];
            }
            print(lines);
            print(lines.length);
            for (String line in lines) {
              List<String> parts = line.split(':');
              if (parts.length > 1) {
                String key = parts[0]
                    .trim(); 
                String value = parts[1]
                    .trim();
                print("${parts[0]}\n ${parts[1]}");
                switch (key) {
                  case "Heart Rate":
                    heartRate = double.parse(value.replaceAll('%', ''));
                    if ((heartRate < 60 || heartRate > 100) &&
                        !isAlreadyAttacked) {
                      sendSms("Emergency Alert\nHeart Rate-$heartRate\nBp-$bp\nAir Humidity-$air\nTemperature-$temp\nSPO2-$sp02", "heart rate");
                      isAlreadyAttacked = true;
                    }
                    break;
                  case "BP":
                    bp = double.parse(value.replaceAll('BPM', ''));
                    if ((bp > 140 || bp < 60) && !isAlreadyAttacked) {
                      sendSms("Emergency Alert\nHeart Rate-$heartRate\nBp-$bp\nAir Humidity-$air\nTemperature-$temp\nSPO2-$sp02", "blood pressure");
                      isAlreadyAttacked = true;
                    }
                    break;
                  case "Air Humidity":
                    air = double.parse(value.replaceAll('%', ''));
                    break;
                  case "Temperature":
                    temp = double.parse(value.replaceAll('F', ''));
                    if (temp > 105 && !isAlreadyAttacked) {
                      sendSms("Emergency Alert\nHeart Rate-$heartRate\nBp-$bp\nAir Humidity-$air\nTemperature-$temp\nSPO2-$sp02", "Temperature");
                      isAlreadyAttacked = true;
                    }
                    break;
                  case "SPO2":
                    sp02 = double.parse(value.replaceAll('C', ''));
                    if (sp02 < 10) {
                      sp02 += 90;
                    }
                    if (sp02 < 90 && !isAlreadyAttacked) {
                      sendSms("Emergency Alert\nHeart Rate-$heartRate\nBp-$bp\nAir Humidity-$air\nTemperature-$temp\nSPO2-$sp02", "SPO2");
                      isAlreadyAttacked = true;
                    }
                    break;
                  default:
                    // Handle unknown keys
                    break;
                }
              }
            }
            tempp = "";
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
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Color(0xFF0A0E21),
              title: Text('Health Monitor'),
              actions: [
                IconButton(
                    onPressed: () {
                      sendSms(
                          "Emergency Alert\nHeart Rate-$heartRate\nBp-$bp\nAir Humidity-$air\nTemperature-$temp\nSPO2-$sp02", "");
                    },
                    icon: Icon(
                      Icons.sos,
                      color: Colors.red,
                    )),
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
              child: ListView.builder(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
