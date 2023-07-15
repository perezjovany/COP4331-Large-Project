//======= Import Statements =======
import 'package:flutter/material.dart';
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

              //===== Container for frosted glass effect
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(

                  //===== Login box size
                  width: 400,
                  padding: EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    //===== Box styling, we might need better contrast here
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
                      SizedBox(height: 50),
                      Text("Welcome to KitchenPal", style: TextStyle(color: Colors.green, fontSize: 34, fontWeight: FontWeight.bold)),

                      SizedBox(height: 20),
                      Text("Your kitchen management made easy", style: TextStyle(color: Colors.white, fontSize: 16)),

                      SizedBox(height: 50),

                      //===== TextField for email or phone number or whatever method we're gonna use
                      TextField(
                        style: TextStyle(color: Colors.green),
                        decoration: InputDecoration(
                          hintText: "Email or Phone number",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      //===== TextField for password with "see password" toggle
                      SizedBox(height: 20),
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

                      //===== Forgot Password button. No function yet.
                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      //===== Login Button. Right now it just navigates to '/main'
                      SizedBox(height: 20),

                      ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        ),

                        onPressed: () {
                          Navigator.pushNamed(context, '/main');
                        },

                        child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      //===== SignUp Button. It navigates to SignUpPage.
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text("New to KitchenPal? Create Account", style: TextStyle(color: Colors.white)),
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
