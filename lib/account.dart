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
  TextEditingController firstNameController;
  TextEditingController lastNameController;
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
        this.firstNameController = TextEditingController(text: firstName),
        this.lastNameController = TextEditingController(text: lastName),
        this.phoneController = TextEditingController(text: phone);
}

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

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
      appBar: AppBar(
        title: Text('Account Settings'), // Updated to use AppBar
      ),
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
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserForm(User user) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adding padding around the form
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: user
                  .firstNameController, // Updated to use firstNameController
              decoration: const InputDecoration(
                  labelText: 'First Name'), // Updated label
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name'; // Updated validation message
                }
                return null;
              },
            ),
            TextFormField(
              controller:
                  user.lastNameController, // Updated to use lastNameController
              decoration: const InputDecoration(
                  labelText: 'Last Name'), // Updated label
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name'; // Updated validation message
                }
                return null;
              },
            ),
            TextFormField(
              controller: user.phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone Number'), // Updated label
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(
                height: 16), // Adding spacing between form fields and button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    user.firstName = user.firstNameController
                        .text; // Updated to use firstNameController text directly
                    user.lastName = user.lastNameController
                        .text; // Updated to use lastNameController text directly
                    user.phone = user.phoneController.text;
                  });
                  _updateUser(user);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12), // Adding padding to the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8), // Adding rounded corners to the button
                ),
                primary: Colors.green,
                onPrimary: Colors.white,
                elevation: 4,
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AccountPage(),
  ));
}
