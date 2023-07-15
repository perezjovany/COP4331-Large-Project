import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController loginNameController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  String message = '';

  Future<void> doLogin() async {
    var path = await buildPath('api/login');
    var url = Uri.parse(path);
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'login': loginNameController.text,
      'password': loginPasswordController.text,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);
      var res = jsonDecode(response.body);

      if (res['id'] <= 0) {
        setState(() {
          message = 'User/Password combination incorrect';
        });
      } else {
        var user = {
          'firstName': res['firstName'],
          'lastName': res['lastName'],
          'id': res['id'],
        };
        // Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user));

        setState(() {
          message = '';
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/cards');
        });
      }
    } catch (e) {
      _showErrorDialog(
          e.toString()); // Call a separate method to show the error dialog
    }
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'PLEASE LOG IN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
            controller: loginNameController,
          ),
          const SizedBox(height: 10),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            controller: loginPasswordController,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: doLogin,
            child: const Text('Do It'),
          ),
          const SizedBox(height: 10),
          Text(message),
        ],
      ),
    );
  }
}
