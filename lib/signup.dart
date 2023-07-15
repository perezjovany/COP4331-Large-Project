import 'package:flutter/material.dart';
import 'dart:ui';
import 'login.dart';

// ===== SignUpPage Widget =====

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool seePass = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //===== BACKGROUND IMAGE: We need to change current background image due to CC
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),

              // Container for frosted glass effect
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 400,
                  padding: EdgeInsets.all(16),

                  // ===== SIGN UP BOX STYLING =====
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

                  // ===== SIGN UP FORM =====
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Logo
                      Image.asset(
                        'assets/logo.png',
                        width: 150,
                        height: 150,
                      ),

                      SizedBox(height: 50),
                      Text(
                        "Create your account",
                        style: TextStyle(color: Colors.green, fontSize: 34, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 50),

                      // Email input field
                      TextField(
                        style: TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Password input field
                      TextField(
                        obscureText: seePass,
                        style: TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(seePass ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                seePass = !seePass;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Confirm Password input field
                      TextField(
                        obscureText: seePass,
                        style: TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(seePass ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                seePass = !seePass;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Sign Up Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        ),
                        onPressed: () { // CHANGE THIS ONCE SIGNUP IS FUNCTIONAL
                          Navigator.pushNamed(context, '/main');
                        },
                        child: Text(
                          "Signup",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Login navigation button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.white),
                        ),
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
