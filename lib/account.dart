import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  String firstName = "First Name";
  String lastName = "Last Name";
  String phone = "Phone Number";
  String userId = "User ID";
  int daysLeft = 30; // placeholder value
  bool isLightMode = true; // placeholder value

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize text fields with user details
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    phoneController.text = phone;
  }

  Future<void> updateUser(String userId, String firstName, String lastName,
      String phone, int daysLeft, bool isLightMode) async {
    final response = await http.put(
      Uri.parse('/api/update_user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'daysLeft': daysLeft,
        'isLightMode': isLightMode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Account Settings'), // Custom app bar
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // Container size according to device
            width: MediaQuery.of(context).size.width > 600
                ? 600
                : MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20), // Padding for the child elements
            decoration: BoxDecoration(
              // Container shadow
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
                          // First name field
                          TextFormField(
                            controller: firstNameController,
                            decoration:
                                const InputDecoration(labelText: 'First Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10), // Spacing
                          // Last name field
                          TextFormField(
                            controller: lastNameController,
                            decoration:
                                const InputDecoration(labelText: 'Last Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10), // Spacing
                          // Phone number field
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                                labelText: 'Phone Number'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    child: const Text('Save Changes'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          firstName = firstNameController.text;
                          lastName = lastNameController.text;
                          phone = phoneController.text;
                        });

                        updateUser(userId, firstName, lastName, phone, daysLeft,
                            isLightMode);

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Changes saved')));
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
