import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class NutrientsPage extends StatelessWidget {
  final Map<dynamic, dynamic> responseObj;
  final bool viewOnly;

  NutrientsPage({Key? key, required this.responseObj, this.viewOnly = false})
      : super(key: key);

  // Mapping of nutrient labels to their corresponding user-friendly names
  final Map<String, String> nutrientNameMap = {
    "Total lipid (fat)": "Total Fat",
    "Fatty acids, total saturated": "Saturated Fat",
    "Energy": "Calories",
    "Fatty acids, total monounsaturated": "Monounsaturated Fat",
    "Fatty acids, total polyunsaturated": "Polyunsaturated Fat",
    "Fatty acids, total trans": "Trans Fat",
    "Carbohydrate, by difference": "Total Carbohydrate",
    "Carbohydrates (net)": "Net Carbohydrates",
    "Fiber, total dietary": "Dietary Fiber",
    "Sodium, Na": "Sodium",
    "Calcium, Ca": "Calcium",
    "Magnesium, Mg": "Magnesium",
    "Potassium, K": "Potassium",
    "Iron, Fe": "Iron",
    "Zinc, Zn": "Zinc",
    "Phosphorus, P": "Phosphorus",
    "Vitamin C, total ascorbic acid": "Vitamin C",
    "Vitamin D (D2 + D3)": "Vitamin D",
    "Vitamin E (alpha-tocopherol)": "Vitamin E",
    "Vitamin K (phylloquinone)": "Vitamin K",
  };

  // Set of nutrient labels to be bolded
  final Set<String> boldedNutrients = {
    "Total Fat",
    "Total Carbohydrate",
    "Sodium",
    "Protein",
    "Cholesterol"
  };

  // Set of nutrient labels to be indented
  final Set<String> indentedNutrients = {
    "Saturated Fat",
    "Trans Fat",
    "Monounsaturated Fat",
    "Polyunsaturated Fat",
    "Net Carbohydrates",
    "Folate, food",
    "Folic acid",
    "Dietary Fiber",
    "Sugars, total including NLEA",
    "Sugars, added"
  };

  String getModifiedLabel(String label) {
    return nutrientNameMap[label] ?? label;
  }

  Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token ?? '';
  }

  Future<void> createFridgeItem(FridgeItem fridgeItem) async {
    var path = await buildPath('api/create_fridge_item');
    var url = Uri.parse(path);
    var token = await getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(fridgeItem.toJson()),
      );

      if (response.statusCode == 200) {
        // Handle the successful response, if needed
        var responseBody = jsonDecode(response.body);
        print(responseBody); // Use the responseBody as needed
      } else {
        // Handle other status codes
        var errorMessage = response.body;
        print(errorMessage);
        throw errorMessage; // Throw an error to be handled by the caller
      }
    } catch (e) {
      // Handle errors
      print(e.toString());
      rethrow; // Throw an error to be handled by the caller
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the "food" data from the responseObj
    var foodData = responseObj['ingredients'][0]['parsed'][0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrients'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nutritional Facts',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Serving Size: ${foodData['quantity']} ${foodData['measure']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calories: ${responseObj['calories'].round()} calories',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Weight: ${responseObj['totalWeight'].round()} g',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Diet Labels: ${responseObj['dietLabels'].join(", ")}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Health Labels: ${responseObj['healthLabels'].join(", ")}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Cautions: ${responseObj['cautions'].join(", ")}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nutrients:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.grey),
                    itemCount: responseObj['totalNutrients'].length,
                    itemBuilder: (context, index) {
                      var nutrient =
                          responseObj['totalNutrients'].keys.elementAt(index);
                      var nutrientData =
                          responseObj['totalNutrients'][nutrient];
                      var dailyData = responseObj['totalDaily'][nutrient];

                      var nutrientLabel =
                          getModifiedLabel(nutrientData['label']);

                      var dailyValueText = dailyData != null
                          ? '${dailyData['quantity'].round()} ${dailyData['unit']}'
                          : '';

                      // Check if the nutrient label should be bolded or indented
                      final bool isBolded =
                          boldedNutrients.contains(nutrientLabel);
                      final bool isIndented =
                          indentedNutrients.contains(nutrientLabel);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: isIndented
                                  ? 16
                                  : 0, // Apply left padding if indented
                              right:
                                  8, // Add right spacing between nutrient label and value
                            ),
                            child: Text(
                              '$nutrientLabel: ${nutrientData['quantity'].round()} ${nutrientData['unit']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isBolded
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Text(
                            dailyValueText,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: !viewOnly
          ? FloatingActionButton(
              onPressed: () {
                // Show the custom dialog when the FAB is pressed
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddToFridgeDialog(responseObj: responseObj);
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddToFridgeDialog extends StatefulWidget {
  final Map<dynamic, dynamic> responseObj;
  final bool viewOnly;

  const AddToFridgeDialog(
      {Key? key, required this.responseObj, this.viewOnly = false})
      : super(key: key);

  @override
  _AddToFridgeDialogState createState() => _AddToFridgeDialogState();
}

class _AddToFridgeDialogState extends State<AddToFridgeDialog> {
  DateTime selectedDate = DateTime.now();
  double quantity = 1.0;
  TextEditingController quantityController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> addToFridge() async {
    try {
      // Fetch the userId from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      var userId = userData['userId'];

      // Prepare the FridgeItem object
      var fridgeItem = FridgeItem(
        userId: userId,
        expirationDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        foodLabel: widget.responseObj['ingredients'][0]['parsed'][0]['food'],
        totalCalories: widget.responseObj['calories'].round(),
        measure: widget.responseObj['ingredients'][0]['parsed'][0]['measure'],
        ingredients: [
          {
            "quantity": quantity,
            "measureURI": widget.responseObj['ingredients'][0]['parsed'][0]
                ['measureURI'],
            "qualifiers": [],
            "foodId": widget.responseObj['ingredients'][0]['parsed'][0]
                ['foodId']
          },
        ],
      );

      // Call the createFridgeItem method to add the item to the fridge
      await NutrientsPage(responseObj: widget.responseObj)
          .createFridgeItem(fridgeItem);

      Navigator.of(context).pop(); // Close the dialog after adding the item
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.pushNamed(context, '/main');
    } catch (e) {
      // Handle errors, if needed
      print(e.toString());
      // Show an error message to the user, if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    String foodName = widget.responseObj['ingredients'][0]['parsed'][0]['food'];
    return AlertDialog(
      title: Text('Add $foodName to Fridge'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Expiration Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Quantity:'),
          TextFormField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                quantity = double.tryParse(value) ?? 1.0;
              });
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: addToFridge,
          child: const Text('Add to Fridge'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class FridgeItem {
  final int userId;
  final String expirationDate;
  final String foodLabel;
  final int totalCalories;
  final String measure;
  final List<Map<String, dynamic>> ingredients;

  FridgeItem({
    required this.userId,
    required this.expirationDate,
    required this.foodLabel,
    required this.totalCalories,
    required this.measure,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'expirationDate': expirationDate,
      'foodLabel': foodLabel,
      'totalCalories': totalCalories,
      'measure': measure,
      'ingredients': ingredients,
    };
  }
}
