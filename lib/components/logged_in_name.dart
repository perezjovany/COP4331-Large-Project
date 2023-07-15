import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoggedInName extends StatefulWidget {
  const LoggedInName({super.key});

  @override
  _LoggedInNameState createState() => _LoggedInNameState();
}

class _LoggedInNameState extends State<LoggedInName> {
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _ud = prefs.getString('user_data');
    var ud = json.decode(_ud!);
    setState(() {
      firstName = ud['firstName'];
      lastName = ud['lastName'];
    });
  }

  Future<void> doLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Logged In As $firstName $lastName'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: doLogout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
