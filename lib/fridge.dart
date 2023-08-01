import 'package:flutter/material.dart';
import 'package:flutter_app/search_food.dart';
import 'package:flutter_app/top_bar.dart';

// TODO
// - connect to DB
// - allow to add food to list
// - allow to show nutrition facts
// - connect to main
// - make food result page
// - test with emulator (couldnt get emulator to work, was stuck on login page) 

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  String selectedFood = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Fridge'),
      body: Column(children: [
        ElevatedButton(
          onPressed: () async {
            final finalResult = await showSearch(
              context: context,
              delegate: SearchFood(
                foodItems: allfood,
              ),
            );
            setState(() {
              selectedFood = finalResult!;
            });
          },
          child: const Text('Search'),
        ),
      ]),
    );
  }
}

//example list, need to connect to db
List<String> allfood = [
  'chicken',
  'yams',
  'mango',
  'cake',
  'pineapple',
  'apple',
  'apple sauce',
  'grapes',
  'apple juice'
];

class FridgeApp extends StatelessWidget {
  const FridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FridgePage(),
    );
  }
}

void main() => runApp(const FridgeApp());