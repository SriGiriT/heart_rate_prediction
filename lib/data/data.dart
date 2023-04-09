import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Data1 {
  Data1(
      {required this.username,
      required this.age,
      required this.dob,
      required this.bloodGroup,
      required this.hasPreviousAttack,
      required this.emergencyContacts});
  String username;
  String age;
  String dob;
  String bloodGroup;
  bool hasPreviousAttack;
  EmergencyContact emergencyContacts;
}

class EmergencyContact {
  final String name;
  final String number;

  EmergencyContact({required this.name, required this.number});
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      number: json['number'],
    );
  }

  EmergencyContact.fromMap(Map<String, String> map)
      : name = map['name']!,
        number = map['number']!;
}
