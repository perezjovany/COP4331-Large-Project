import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/nutrients.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:http/http.dart' as http;

class ParserResultsPage extends StatelessWidget {
  final dynamic foodResults;
  final dynamic nextPage;
  final String text;

  ParserResultsPage({
    super.key,
    required this.foodResults,
    required this.nextPage,
    required this.text,
  });

  // Add the NutritionHelper instance
  final NutritionHelper nutritionHelper = NutritionHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parser Results'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0), // Add padding around the Container
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            int maxColumns = 20; // Set the maximum number of columns

            // Calculate the appropriate number of columns based on screen width
            int crossAxisCount = (screenWidth ~/ 210).clamp(2, maxColumns);

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.0, // Increased distance between columns
                mainAxisSpacing: 12.0, // Increased distance between rows
              ),
              itemCount: foodResults.length,
              itemBuilder: (context, index) {
                // Extract the food item at the current index
                var food = foodResults[index]['food'];

                // Extract the "label" and "ENERC_KCAL" from the food item
                var label = food['label'];
                var brand = food['brand'] ??
                    'Generic Food'; // If 'brand' is null, use 'Generic Food'
                var enercKcal = food['nutrients']['ENERC_KCAL'];

                // Round calories to the nearest hundredths place
                var formattedCalories = enercKcal.toStringAsFixed(2);

                return GestureDetector(
                  onTap: () async {
                    // Call the nutrients method when the tile is pressed
                    var responseObj = await nutritionHelper.nutrients(
                        context, foodResults[index]);

                    // Navigate to NutrientsPage and pass the responseObj as arguments
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NutrientsPage(
                            responseObj: responseObj, viewOnly: false),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(
                        8.0), // Add a margin around the tiles
                    decoration: BoxDecoration(
                      color:
                          Colors.green, // Change the background color to green
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          textAlign:
                              TextAlign.center, // Align the text to the center
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color:
                                Colors.white, // Change the text color to white
                          ),
                        ),
                        Text(
                          brand, // Display 'brand' under 'label'
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '$formattedCalories calories',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color:
                                Colors.white, // Change the text color to white
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NutritionHelper {
  Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token ?? '';
  }

  Future<Map<dynamic, dynamic>> nutrients(
    BuildContext context, dynamic foodItem) async {
    var path = await buildPath('api/nutrients');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // Use the indexed foodItem directly
      var food = foodItem['food'];
      List<Map<String, dynamic>> ingredients = [
        {
          "quantity": 100,
          "measureURI":
              "http://www.edamam.com/ontologies/edamam.owl#Measure_gram",
          "qualifiers": [],
          "foodId": food['foodId'],
        },
      ];

      var body = {
        "ingredients": ingredients,
      };

      var response =
          await http.post(url, headers: headers, body: jsonEncode(body));
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        res['ingredients'][0]['parsed'][0]['food'] =
            formatFoodName(res['ingredients'][0]['parsed'][0]['food']);
        // Handle the response
        var nutrientData = res;

        return nutrientData; // Return the responseObj
      } else {
        // Handle other status codes
        var errorMessage = res['error'];
        print(errorMessage);
        throw errorMessage; // Throw an error to be handled by the caller
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
      throw e; // Throw an error to be handled by the caller
    }
  }

  String formatFoodName(String foodName) {
    List<String> words = foodName.split(' ');
    words = words
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .toList();
    return words.join(' ');
  }

  Future<void> _showErrorDialog(
      BuildContext context, String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showErrorDialog(BuildContext context, String errorMessage) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
