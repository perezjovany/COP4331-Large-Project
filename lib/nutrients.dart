import 'package:flutter/material.dart';

class NutrientsPage extends StatelessWidget {
  final Map<dynamic, dynamic> responseObj;

  const NutrientsPage({Key? key, required this.responseObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the "food" data from the responseObj
    var foodData = responseObj['ingredients'][0]['parsed'][0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrients'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Food Name: ${foodData['food']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Display other nutrient information here if needed
          ],
        ),
      ),
    );
  }
}
