//======= Import Statements =======
import 'package:flutter/material.dart';
import 'dart:ui';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

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
            image: AssetImage("assets/background.jpg"), //  PLACEHOLDER background image, needs to be changed
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: BackdropFilter( // Frosted glass effect
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),

                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(10),
                    color: Colors.brown.withOpacity(0.05),

                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.03), spreadRadius: 5),
                      BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 7),
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
                      const Text("Welcome to KitchenPal", style: TextStyle(color: Colors.green, fontSize: 34, fontWeight: FontWeight.bold)), // PLACEHOLDER app name

                      const SizedBox(height: 20),
                      const Text("Your kitchen management made easy", style: TextStyle(color: Colors.white, fontSize: 16)), // PLACEHOLDER motto/description

                      const SizedBox(height: 50), //  Text-field sections
                      const TextField(
                        style: TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Email or Phone number",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextField(
                        obscureText: _obscureText,

                        style: const TextStyle(color: Colors.green),

                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {}, // Need to add functionality here
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        ),

                        onPressed: () {
                          Navigator.pushNamed(context, '/main');
                        },

                        child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()), // PLACEHOLDER function
                          );
                        },

                        child: const Text("New to KitchenPal? Create Account", style: TextStyle(color: Colors.white)),
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
