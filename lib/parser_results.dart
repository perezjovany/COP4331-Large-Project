import 'package:flutter/material.dart';

class ParserResultsPage extends StatelessWidget {
  final dynamic foodResults;
  final dynamic nextPage;
  final String text;

  const ParserResultsPage({
    super.key,
    required this.foodResults,
    required this.nextPage,
    required this.text,
  });

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
                var enercKcal = food['nutrients']['ENERC_KCAL'];

                // Round calories to the nearest hundredths place
                var formattedCalories = enercKcal.toStringAsFixed(2);

                return GestureDetector(
                  onTap: () {
                    print(label); // Print the "label" when the tile is pressed
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
