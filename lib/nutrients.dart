import 'package:flutter/material.dart';

class NutrientsPage extends StatelessWidget {
  final Map<dynamic, dynamic> responseObj;

  NutrientsPage({Key? key, required this.responseObj}) : super(key: key);

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
    "Vitamin D (phylloquinone)": "Vitamin K",
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
    );
  }
}
