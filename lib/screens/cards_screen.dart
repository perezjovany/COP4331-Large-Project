import 'package:flutter/material.dart';
import 'package:flutter_app/components/page_title.dart';
import 'package:flutter_app/components/logged_in_name.dart';
import 'package:flutter_app/components/card_ui.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
