import 'package:flutter/material.dart';
import 'package:flutter_app/components/PageTitle.dart';
import 'package:flutter_app/components/LoggedInName.dart';
import 'package:flutter_app/components/CardUI.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitle(),
          LoggedInName(),
          CardUI(),
        ],
      ),
    );
  }
}
