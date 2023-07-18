import 'package:flutter/material.dart';
import 'dart:ui';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _seePassword = true;

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
              child: BackdropFilter(
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
          style: TextStyle(color: Colors.green, fontSize: 34, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 50),

        _buildTextField("Email", false),
        const SizedBox(height: 20),

        _buildTextField("Password", _seePassword),
        const SizedBox(height: 20),

        _buildTextField("Confirm Password", _seePassword),
        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
          ),

          onPressed: () {
            Navigator.pushNamed(context, '/main');
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

  TextField _buildTextField(String hint, bool obscureText) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.green),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),

        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _seePassword = !_seePassword;
            });
          },
        ),
      ),
    );
  }
}
