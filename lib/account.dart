import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/components/path.dart' show buildPath;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String id;
  int userId;
  String firstName;
  String lastName;
  String login;
  String password;
  String email;
  String phone;
  bool isVerified;
  int? daysLeft;
  bool? isLightMode;

  bool isEditing;
  TextEditingController nameController;
  TextEditingController emailController;
  TextEditingController phoneController;

  User({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.login,
    required this.password,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.daysLeft,
    required this.isLightMode,
  })  : this.isEditing = false,
        this.nameController =
            TextEditingController(text: "$firstName $lastName"),
        this.emailController = TextEditingController(text: email),
        this.phoneController = TextEditingController(text: phone);
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State_Account createState() => State_Account();
}

class State_Account extends State<AccountPage> {
  User? _user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      var userId = userData['userId'].toString();

      var path = await buildPath('api/get_user/$userId');
      var url = Uri.parse(path);
      print('URL: $url'); // print the URL for debugging

      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      var response = await http.get(url, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var userRes = res['user'];
        setState(() {
          _user = User(
              id: userRes['_id'],
              userId: userRes['userId'],
              firstName: userRes['firstName'],
              lastName: userRes['lastName'],
              login: userRes['login'],
              password: userRes['password'],
              email: userRes['email'],
              phone: userRes['phone'],
              isVerified: userRes['isVerified'],
              daysLeft: userRes['daysLeft'] ?? 0, // Use 0 if daysLeft is null
              isLightMode: userRes['isLightMode'] ??
                  false); // Use false if isLightMode is null
        });
      } else {
        _showErrorDialog(res['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateUser(User user) async {
    var path = await buildPath('api/update_user');
    var url = Uri.parse(path);
    print('URL: $url'); // print the URL for debugging

    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var body = jsonEncode({
      'userId': user.userId,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'phone': user.phone,
      'daysLeft': user.daysLeft,
      'isLightMode': user.isLightMode
    });

    var response = await http.put(url, headers: headers, body: body);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var res = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('User updated successfully');
    } else {
      _showErrorDialog(res['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Account Settings'), // Page Title
      body:
          _user != null ? _buildUserForm(_user!) : CircularProgressIndicator(),
      bottomNavigationBar: const bottomBar(
        selectedIndex:
            2, // Sets the selected index of the bottom navigation bar to 2
      ),
    );
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

  Widget _buildUserForm(User user) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: user.nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: user.emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: user.phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  user.firstName = user.nameController.text.split(' ')[0];
                  user.lastName = user.nameController.text.split(' ')[1];
                  user.email = user.emailController.text;
                  user.phone = user.phoneController.text;
                });
                _updateUser(user);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const AccountPage());
}
