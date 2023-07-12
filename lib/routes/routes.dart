import 'package:flutter/material.dart';
import 'package:flutter_app/screens/LoginScreen.dart';
import 'package:flutter_app/screens/CardsScreen.dart';

class Routes {
  static const String LOGINSCREEN = '/login';
  static const String CARDSSCREEN = '/cards';

  // routes of pages in the app
  static Map<String, Widget Function(BuildContext)> get getroutes => {
    '/': (context) => const LoginScreen(),
    LOGINSCREEN: (context) => const LoginScreen(),
    CARDSSCREEN: (context) => const CardsScreen(),
  };
}
