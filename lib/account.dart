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

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
      var headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

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
              daysLeft: userRes['daysLeft'] ?? 0,
              // Use 0 if daysLeft is null
              isLightMode: userRes['isLightMode'] ?? false); // Use false if isLightMode is null
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
    var headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

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
        title: const Text('Account Settings'), // Updated to use AppBar
      ),
      body: _user != null ? _buildUserForm(_user!) : const CircularProgressIndicator(),
      bottomNavigationBar: const bottomBar(
        selectedIndex: 2, // Sets the selected index of the bottom navigation bar to 2
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

  Future<void> _changePassword(String newPassword, String confirmPassword) async {
    // Check if the new password and confirmation match
    if (newPassword != confirmPassword) {
      return;
    }

    var token = await getToken();

    try {
      var path = await buildPath('api/change_password');
      var url = Uri.parse(path);
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body = jsonEncode({
        'password': newPassword,
      });

      var response = await http.post(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Password change successful
        showDialog<void>(
          context: context,
          builder: (BuildContext successDialogContext) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Password successfully changed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(successDialogContext).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Password change failed, show error message
        showDialog<void>(
          context: context,
          builder: (BuildContext errorDialogContext) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while changing the password.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(errorDialogContext).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Exception occurred, show error message
      showDialog<void>(
        context: context,
        builder: (BuildContext errorDialogContext) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while changing the password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(errorDialogContext).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleChangePasswordButtonPressed() {
    // Show the password change dialog
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey), // Grey text color for the label
                  hintStyle: TextStyle(color: Colors.grey), // Grey hint text color
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: Colors.grey), // Grey text color for the label
                  hintStyle: TextStyle(color: Colors.grey), // Grey hint text color
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm the new password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Validate passwords match
                  if (newPasswordController.text != confirmPasswordController.text) {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext errorDialogContext) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Passwords do not match.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(errorDialogContext).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _changePassword(newPasswordController.text, confirmPasswordController.text);
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserForm(User user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: user.firstNameController,
                  decoration:
                      const InputDecoration(labelText: 'First Name', labelStyle: TextStyle(color: Colors.black)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: user.lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name', labelStyle: TextStyle(color: Colors.black)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: user.phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.black)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        user.firstName = user.firstNameController.text;
                        user.lastName = user.lastNameController.text;
                        user.phone = user.phoneController.text;
                      });
                      _updateUser(user);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    elevation: 4,
                  ),
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 8), // Add spacing between the buttons
                ElevatedButton(
                  onPressed: _handleChangePasswordButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    elevation: 4,
                  ),
                  child: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AccountPage(),
  ));
}
