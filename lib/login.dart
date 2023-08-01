//======= Import Statements =======
import 'package:flutter/material.dart';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'signup.dart';
import 'main.dart';

void main() => runApp(const MyApp());

//===== LoginPage Widget

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginNameController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  bool _obscureText = true;
  String message = '';
  bool seePass = true;

  // Function to handle storing the token securely
  Future<void> storeToken(String token) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'auth_token', value: token);
  }

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
      final token = res['token'];

      if (response.statusCode == 200) {
        var user = {
          'firstName': res['firstName'],
          'lastName': res['lastName'],
          'userId': res['userId'],
          'email': res['email'],
          'phone': res['phone']
        };

        // Store the token securely
        await storeToken(token);

        // Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user));

        setState(() {
          message = '';
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/main');
        });
      } else {
        // Other status codes
        setState(() {
          message = res['error'];
        });
      }
    } catch (e) {
      _showErrorDialog(e.toString());
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/background.jpg"), //  PLACEHOLDER background image, needs to be changed
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                // Frosted glass effect
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),

                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.brown.withOpacity(0.05),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.03),
                          spreadRadius: 5),
                      BoxShadow(
                          color: Colors.white.withOpacity(0.03), blurRadius: 7),
                    ],
                    border: Border.all(
                      width: 1.5,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.png', // Logo shown in login page
                        width: 150,
                        height: 150,
                      ),

                      const SizedBox(height: 50),
                      const Text("Welcome to KitchenPal",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 34,
                              fontWeight:
                                  FontWeight.bold)), // PLACEHOLDER app name

                      const SizedBox(height: 20),
                      const Text("Your kitchen management made easy",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16)), // PLACEHOLDER motto/description

                      const SizedBox(height: 50), //  Text-field sections
                      TextField(
                        controller: loginNameController,
                        style: const TextStyle(color: Colors.green),
                        decoration: const InputDecoration(
                          hintText: "Email or Phone number",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextField(
                        controller: loginPasswordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {}, // Need to add functionality here
                          child: const Text("Forgot Password?",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                        ),
                        onPressed: () {
                          doLogin();
                        },
                        child: const Text("Login",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      // Display error message
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SignUpPage()), // PLACEHOLDER function
                          );
                        },
                        child: const Text("New to KitchenPal? Create Account",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
