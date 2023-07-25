//======= Import Statements =======
import 'package:flutter/material.dart';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _seePassword = true;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String message = '';
  bool seePass = true;

  Future<void> doSignup() async {
    var path = await buildPath('api/signup');
    var url = Uri.parse(path);
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'login': loginController.text,
      'password': passwordController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(body));

        setState(() {
          message = '';
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/');
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
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
                  child: _buildSignUpForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/logo.png',
          width: 150,
          height: 150,
        ),
        const SizedBox(height: 50),
        const Text(
          "Create your account",
          style: TextStyle(
              color: Colors.green, fontSize: 34, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: firstNameController,
          style: const TextStyle(color: Colors.green),
          decoration: const InputDecoration(
            hintText: "First Name",
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: lastNameController,
          style: const TextStyle(color: Colors.green),
          decoration: const InputDecoration(
            hintText: "Last Name",
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: loginController,
          style: const TextStyle(color: Colors.green),
          decoration: const InputDecoration(
            hintText: "Login",
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: _seePassword,
          style: const TextStyle(color: Colors.green),
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.white),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            suffixIcon: IconButton(
              icon:
                  Icon(_seePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _seePassword = !_seePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.green),
          decoration: const InputDecoration(
            hintText: "Email",
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: phoneController,
          style: const TextStyle(color: Colors.green),
          decoration: const InputDecoration(
            hintText: "Phone",
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
          ),
          onPressed: () {
            doSignup();
          },
          child: const Text(
            "Signup",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: const Text(
            "Already have an account? Login",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
