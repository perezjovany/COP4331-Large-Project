import 'package:flutter/material.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/cards_screen.dart';

class Routes {
  static const String logInScreen = '/login';
  static const String cardsScreen = '/cards';

  // routes of pages in the app
  static Map<String, Widget Function(BuildContext)> get getroutes => {
        '/': (context) => const LoginScreen(),
        logInScreen: (context) => const LoginScreen(),
        cardsScreen: (context) => const CardsScreen(),
      };
}
