//======= Import Statements =======
import 'package:flutter/material.dart';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'signup.dart';
import 'main.dart';

void main() => runApp(MyApp());

//===== LoginPage Widget

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginNameController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  String message = '';
  bool seePass = true;

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

      if (response.statusCode == 200) {
        var user = {
          'firstName': res['firstName'],
          'lastName': res['lastName'],
          'userId': res['userId'],
          'email': res['email'],
          'phone': res['phone']
        };
        // Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user));

        setState(() {
          message = '';
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/main');
        });
      } else if (response.statusCode == 401) {
        setState(() {
          message = 'User/Password combination incorrect';
        });
      } else {
        _showErrorDialog('Something went wrong. Please try again later.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //===== BACKGROUND IMAGE: We need to change current background image due to CC
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),

              //===== Container for frosted glass effect
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  //===== Login box size
                  width: 400,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    //===== Box styling, we might need better contrast here
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

                  //===== Login form
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //===== Set the logo and its size here
                      Image.asset(
                        'assets/logo.png', // Make sure you modify pubspec.yaml if you change the filename
                        width: 150,
                        height: 150,
                      ),

                      //===== Login box text content, might need better contrast here
                      const SizedBox(height: 50),
                      const Text("Welcome to KitchenPal",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 34,
                              fontWeight: FontWeight.bold)),

                      const SizedBox(height: 20),
                      const Text("Your kitchen management made easy",
                          style: TextStyle(color: Colors.white, fontSize: 16)),

                      const SizedBox(height: 50),

                      //===== TextField for email or phone number or whatever method we're gonna use
                      TextField(
                        style: const TextStyle(color: Colors.green),
                        decoration: const InputDecoration(
                          hintText: "Username",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        controller: loginNameController,
                      ),

                      //===== TextField for password with "see password" toggle
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: seePass,
                        style: const TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(seePass
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                seePass = !seePass;
                              });
                            },
                          ),
                        ),
                        controller: loginPasswordController,
                      ),

                      //===== Forgot Password button. No function yet.
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      //===== Login Button. Right now it just navigates to '/main'
                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
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

                      //===== SignUp Button. It navigates to SignUpPage.
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
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
