import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heart_rate_prediction/constant.dart';
import 'package:heart_rate_prediction/screens/bluetooth.dart';
import 'package:heart_rate_prediction/screens/main_page.dart';
import 'package:intl/intl.dart';
import 'package:heart_rate_prediction/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _age;
  late DateTime _dob = DateTime.parse("1900-02-27");
  late String _bloodGroup = "A+";
  late bool _hasPreviousAttack = false;
  late List<String> _emergencyContactsName = [];
  late List<String> _emergencyContactsNumber = [];

  Future<void> _register() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _username);
    prefs.setString('age', _age);
    prefs.setString('dob', _dob.toString());
    prefs.setString('bloodGroup', _bloodGroup);
    prefs.setBool('hasPreviousAttack', _hasPreviousAttack);
    prefs.setStringList('emergencyContactsName', _emergencyContactsName);
    prefs.setStringList('emergencyContactsNumber', _emergencyContactsNumber);
    // prefs.setStringList('emergencyContacts',
    //     _emergencyContacts.map((e) => json.encode(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        title: Text('Registration Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Age'),
                  obscureText: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Age';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  readOnly: true,
                  onTap: () async {
                    print(_dob.toString().substring(0, 10));
                    final dob = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2023),
                    );
                    setState(() {
                      _dob = dob!;
                    });
                  },
                  validator: (value) {
                    if (_dob.toString().substring(0, 10) == "1900-02-27") {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                      text: _dob.toString().substring(0, 10) == "1900-02-27"
                          ? ''
                          : DateFormat.yMd().format(_dob)),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Blood Group'),
                  value: _bloodGroup,
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((bloodGroup) => DropdownMenuItem<String>(
                            value: bloodGroup,
                            child: Text(bloodGroup),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _bloodGroup = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your blood group';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  "Do you have any previous attacks?",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: <Widget>[
                    Radio(
                      value: true,
                      groupValue: _hasPreviousAttack,
                      onChanged: (value) {
                        setState(() {
                          _hasPreviousAttack = value!;
                        });
                      },
                    ),
                    Text('Yes'),
                    Radio(
                      value: false,
                      groupValue: _hasPreviousAttack,
                      onChanged: (value) {
                        setState(() {
                          _hasPreviousAttack = value!;
                        });
                      },
                    ),
                    Text('No'),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _emergencyContactsName.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_emergencyContactsName[index]),
                      subtitle: Text(_emergencyContactsNumber[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _emergencyContactsName.removeAt(index);
                            _emergencyContactsNumber.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Add Emergency Contact'),
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
                                decoration: InputDecoration(labelText: 'Name'),
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
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  setState(() {
                                    _emergencyContactsName.add(name);
                                    _emergencyContactsNumber.add(number);
                                  });
                                  Navigator.pop(context, true);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (result != null && result) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Emergency contact added.'),
                      ));
                    }
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      isRegistered = true;
                      _register();
                      Data1 data = Data1(
                          username: _username,
                          age: _age,
                          dob: _dob.toString(),
                          bloodGroup: _bloodGroup,
                          hasPreviousAttack: _hasPreviousAttack,
                          emergencyContactsName: _emergencyContactsName,
                          emergencyContactsNumber: _emergencyContactsNumber);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BluetoothScreen(),
                        ),
                      );
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
