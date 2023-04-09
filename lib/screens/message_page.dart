import 'package:flutter/material.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.title});

  final String title;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late TwilioFlutter twilioFlutter;
  List<String> number = ["9344953235", "8610733899"];


  @override
  void initState() {
    twilioFlutter =
        TwilioFlutter(accountSid: "ACe52b8ec3949369210debd07d18593e02", authToken: "", twilioNumber: "+15074485128");
    super.initState();
  }

  void sendSms(String message) async {
    twilioFlutter.sendSMS(toNumber: "+91${number}", messageBody: "$message");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              "",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      
    );
  }
}