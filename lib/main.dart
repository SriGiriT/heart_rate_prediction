import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heart_rate_prediction/screens/bluetooth.dart';
import 'package:heart_rate_prediction/screens/message_page.dart';
import 'package:heart_rate_prediction/screens/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:heart_rate_prediction/constant.dart';
import 'package:heart_rate_prediction/screens/main_page.dart';
Future main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final prefs = snapshot.data;

            final name = prefs?.getString('username');
            final age = prefs?.getString('age');
            final dob = prefs?.getString('dob');
            final bloodGroup = prefs?.getString('bloodGroup');
            final hasPreviousAttack = prefs?.getBool('hasPreviousAttack');
            final emergencyContactsJson =
                prefs?.getStringList('emergencyContacts');
            final emergencyContacts =
                emergencyContactsJson?.map((e) => json.decode(e)).toList() ??
                    [];

            if (name == null ||
                age == null ||
                dob == null ||
                bloodGroup == null ||
                hasPreviousAttack == null) {
              return RegistrationPage();
            }

            return BluetoothScreen();
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

Future<SharedPreferences> _initialize() async {
  return SharedPreferences.getInstance();
}
