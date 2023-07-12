import 'package:flutter/material.dart';
import 'package:flutter_app/components/PageTitle.dart';
import 'package:flutter_app/components/Login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          PageTitle(),
          Login(),
        ],
      ),
    );
  }
}
