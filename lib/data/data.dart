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
      required this.emergencyContacts});
  String username;
  String age;
  String dob;
  String bloodGroup;
  bool hasPreviousAttack;
  List<Map<String, String>> emergencyContacts;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['number'] = this.number;
    return data;
  }

  EmergencyContact.fromMap(Map<String, String> map)
      : name = map['name']!,
        number = map['number']!;
}

class EmergencyContactStorage {
  static const _key = 'emergency_contacts';

  static Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(contacts);
    await prefs.setString(_key, encoded);
  }

  static Future<List<Map<String, dynamic>>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded != null) {
      final decoded = json.decode(encoded);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}
