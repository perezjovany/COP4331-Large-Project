import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'bottom_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State_Account createState() => State_Account();
}

class State_Account extends State<AccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // PLACEHOLDER user details
  String name = "Full Name";
  String email = "user@example.com";
  String password = "password";

  bool seePass = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize text fields with user details
    nameController.text = name;
    emailController.text = email;
    passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Account Settings'), // Custom app bar
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // Container size according to device
            width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20), // Padding for the child elements
            decoration: BoxDecoration( // Container shadow

              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // User account icon
                  const Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 20), // Spacing
                  Card(
                    elevation: 8.0, // Elevation for the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          // Full name field
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Full Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10), // Spacing
                          // Email field
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10), // Spacing
                          // Password field
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              // Toggle visibility of password
                              suffixIcon: IconButton(
                                icon: Icon(
                                  seePass ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    seePass = !seePass;
                                  });
                                },
                              ),
                            ),

                            obscureText: seePass,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Spacing
                  // Save changes button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 20,
                      ),
                    ),

                    child: const Text('Save Changes'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {

                          name = nameController.text;
                          email = emailController.text;
                          password = passwordController.text;

                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Changes saved')));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const bottomBar(
        selectedIndex: null, // No selected index on this page
      ),
    );
  }
}
