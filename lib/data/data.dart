import 'dart:convert';

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data1 {
  Data1(
      {required this.username,
      required this.age,
      required this.dob,
      required this.bloodGroup,
      required this.hasPreviousAttack,
      required this.emergencyContactsName,
      required this.emergencyContactsNumber,
      });
  String username;
  String age;
  String dob;
  String bloodGroup;
  bool hasPreviousAttack;
  List<String> emergencyContactsName;
  List<String> emergencyContactsNumber;
}
