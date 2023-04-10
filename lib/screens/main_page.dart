import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heart_rate_prediction/components/icon_content.dart';
import 'package:heart_rate_prediction/components/reusable_card.dart';
import 'package:heart_rate_prediction/constant.dart';
import 'package:heart_rate_prediction/components/bottom_button.dart';
import 'package:heart_rate_prediction/components/round_icon_button.dart';
import 'package:heart_rate_prediction/data/data.dart';
import 'package:heart_rate_prediction/screens/details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:math';
import 'dart:async';

enum Gender {
  male,
  female,
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  late TwilioFlutter twilioFlutter;
  // List<String> number = ["9344953235", "8610733899"];
  late Gender selectedGender = Gender.male;
  int heartRate = 89;
  int bp = 108;
  int air = 85;
  double temp = 98.6;
  int sp02 = 86;
  late Data1 data;
  @override
  void initState() {
    getUserData();
    Timer.periodic(Duration(seconds: 6), (timer) {
      heartRate = generateHeartRate(85, 100);
      bp = generateBp(95, 120);
      air = generateair(85, 90);
      temp = generatetemp(96.8, 98.4);
      sp02 = generatespo2(85, 90);
      print("Heart Rate: $heartRate bpm");
    });
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

  Random random = new Random();
  int generateBp(int min, int max) {
    bp = min + random.nextInt(5);
    setState(() {
      bp = bp;
    });
    return bp;
  }

  int generateHeartRate(int min, int max) {
    heartRate = min + random.nextInt(5);
    setState(() {
      heartRate = heartRate;
    });
    return heartRate;
  }

  int generateair(int min, int max) {
    air = min + random.nextInt(2);
    setState(() {
      air = air;
    });
    return air;
  }

  double generatetemp(double min, double max) {
    temp = min + random.nextDouble() * 2;
    setState(() {
      temp = temp;
    });
    return temp;
  }

  int generatespo2(int min, int max) {
    sp02 = min + random.nextInt(5);
    setState(() {
      sp02 = sp02;
    });
    return sp02;
  }

  void sendSms(String message) async {
    for (int i = 0; i < data.emergencyContactsNumber.length; i++) {
      print(data.emergencyContactsNumber);
      twilioFlutter.sendSMS(
          toNumber: "+91${data.emergencyContactsNumber[i]}",
          messageBody: '${data.username} currently have some health issues with readings of\n$message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
