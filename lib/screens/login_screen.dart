import 'package:flutter/material.dart';
import 'package:flutter_app/components/page_title.dart';
import 'package:flutter_app/components/login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
