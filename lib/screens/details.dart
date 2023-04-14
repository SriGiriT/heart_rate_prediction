import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heart_rate_prediction/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage();

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Data1 data;
  List<Map<String, String>> emergencyContacts = [];

  @override
  void initState() {
    getUserData();
    super.initState();
  }


  Future<void> update() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('emergencyContactsName', data.emergencyContactsName);
    prefs.setStringList('emergencyContactsNumber', data.emergencyContactsNumber);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Color(0xFF0A0E21),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${data.username}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Age: ${data.age}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Date of Birth: ${data.dob}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Blood Group: ${data.bloodGroup}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Previous Attack: ${data.hasPreviousAttack ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Emergency Contacts:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            late String name;
                            late String number;
                            return AlertDialog(
                              title: Text('Add Emergency Contact'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextFormField(
                                    onChanged: (value) {
                                      name = value;
                                    },
                                    decoration:
                                        InputDecoration(labelText: 'Name'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      name = value!;
                                    },
                                  ),
                                  TextFormField(
                                    onChanged: (value) {
                                      number = value;
                                    },
                                    decoration:
                                        InputDecoration(labelText: 'Number'),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the number';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      number = value!;
                                    },
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text('CANCEL'),
                                  onPressed: () {
                                    Navigator.pop(context, null);
                                  },
                                ),
                                ElevatedButton(
                                    child: Text('ADD'),
                                    onPressed: () {
                                      setState(() {
                                        data.emergencyContactsName.add(name);
                                        data.emergencyContactsNumber
                                            .add(number);
                                      });
                                      update();
                                      Navigator.pop(context, true);
                                    }),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.add))
                ],
              ),
              SizedBox(height: 8),
              if (data.emergencyContactsName.isEmpty)
                Text(
                  'No contacts added',
                  style: TextStyle(fontSize: 20),
                ),
              for (var i = 0; i < data.emergencyContactsName.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${data.emergencyContactsName[i]}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Number: ${data.emergencyContactsNumber[i]}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
