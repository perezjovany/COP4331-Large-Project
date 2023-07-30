//======= Import Statements =======

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'signup.dart';
import 'package:scan/scan.dart';
import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bottom_bar.dart';
import 'calendar.dart';
import 'account.dart';
import 'list.dart';
import 'top_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

//======= Entry Point of the App =======

void main() => runApp(const MyApp());

//======= Root Widget MyApp =======

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData appTheme = ThemeData(
      primarySwatch: Colors.green,
      hintColor: Colors.greenAccent,
      textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.green[700])),
    );

    return MaterialApp(
      // Handles navigation
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/main': (context) => const MainPage(),
        '/calendar': (context) => const CalendarPage(),
        '/account': (context) => const AccountPage(),
        '/list': (context) => const ListPage(),
      },

      theme: appTheme,
    );
  }
}

//======= MainPage Widget - User will land here after login =======

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ScanController controller = ScanController();
  TextEditingController ingController = TextEditingController();
  // TextEditingController nutritionTypeController = TextEditingController(); //TODO: Implement cooking vs logging
  String message = '';
  var _scanResult = ''; // Assuming this holds the "upc" value.
  List<String> _suggestions = [];
  List<Map<String, dynamic>> _fridgeItems = [];

  // Function to handle getting the token
  Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token ?? '';
  }

  Future<void> parse(String scanResult) async {
    var path = await buildPath('api/parser');
    var url = Uri.parse(path);
    var headers = {'Content-Type': 'application/json'};
    var body = {};

    // Retrieve the token from storage
    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      // TODO: Handle the case when the token is not available (e.g., user not logged in)
      // You may choose to redirect to the login screen or show an error message.
      setState(() {
        message = 'User not logged in. Please log in.';
      });
      return;
    }

    if (_scanResult.isNotEmpty) {
      body['upc'] = _scanResult;
    } else if (ingController.text.isNotEmpty) {
      body['ing'] = ingController.text;
    } else {
      setState(() {
        message = 'Please provide either UPC or Ingredient.';
      });
      return;
    }

    // body['nutrition_type'] = nutritionTypeController.text; //TODO: Implement cooking vs logging
    body['nutrition_type'] = "cooking";

    try {
      var response =
          await http.post(url, headers: headers, body: jsonEncode(body));
      var res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          message = '';
        });

        // Do something with the food results
        var foodResults = res['foodResults'];
        var nextPage = res['nextPage'];
        var text = res['text'];

        _showErrorDialog(text); //TODO: FOR TESTING, REMOVE
      } else {
        // Other status codes
        setState(() {
          message = res['error'];
        });
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _showErrorDialog(String errorMessage) async {
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

  bool isScanSupported() {
    if (kIsWeb) {
      // Barcode scanning is not supported on the web
      return false;
    } else {
      // Barcode scanning is supported on Android
      return true;
    }
  }

  void _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }

    var suggestions = await _fetchSuggestions(value);
    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    return await _fetchSuggestions(query);
  }

  Future<List<String>> _fetchSuggestions(String value) async {
    try {
      var path = await buildPath('api/manual_search');
      var url = Uri.parse(path);
      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var body = jsonEncode({'q': value});

      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _suggestions = List<String>.from(data).take(6).toList();
        _suggestions.remove(value);
        return _suggestions;
      }
    } catch (e) {
      // Handle errors
    }

    return [];
  }

  void _onSuggestionSelected(String suggestion) {
    // Handle suggestion selection here
    print("Selected suggestion: $suggestion");

    // Update the search text with the selected suggestion
    setState(() {
      ingController.text = suggestion;
      // Move the cursor to the end of the line
      ingController.selection = TextSelection.fromPosition(
        TextPosition(offset: ingController.text.length),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFridgeItems();
  }

  Future<void> _fetchFridgeItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    var userId = userData['userId'];

    try {
      var path = await buildPath('api/get_all_fridge_items/$userId');
      var url = Uri.parse(path);
      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var fridgeItemIds = List<int>.from(data);

        // Fetch individual fridge items using fridgeItemIds
        List<Map<String, dynamic>> fridgeItems = [];
        for (var fridgeItemId in fridgeItemIds) {
          path = await buildPath('api/get_fridge_item/$fridgeItemId');
          url = Uri.parse(path);
          var fridgeItemResponse = await http.get(url, headers: headers);
          if (fridgeItemResponse.statusCode == 200) {
            var fridgeItemData =
                jsonDecode(fridgeItemResponse.body)['fridgeItem'];
            fridgeItems.add(fridgeItemData);
          } else {
            _showErrorDialog('Failed to fetch fridge item details.');
          }
        }

        setState(() {
          _fridgeItems = fridgeItems;
        });
      } else {
        _showErrorDialog('Failed to fetch fridge item IDs.');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Main Page'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.green),
                  onPressed: () async {
                    await _showBarcodeScanner();
                    if (_scanResult.isNotEmpty) {
                      await parse(_scanResult);
                      _scanResult = "";
                    }
                  }),
              title: TypeAheadField(
                suggestionsCallback: _getSuggestions,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      // Handle suggestion selection here
                      _onSuggestionSelected(suggestion);
                    },
                  );
                },
                onSuggestionSelected: (suggestion) {
                  // Handle suggestion selection here
                  _onSuggestionSelected(suggestion);
                },
                textFieldConfiguration: TextFieldConfiguration(
                  controller: ingController, // Use the TextEditingController
                  decoration: const InputDecoration(
                    hintText: 'Search Ingredient',
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                ),
                noItemsFoundBuilder: (context) {
                  return const Text("");
                },
                loadingBuilder: (context) {
                  return const Text("");
                },
                debounceDuration: Duration.zero,
              ),
              trailing: IconButton(
                  icon: const Icon(Icons.search, color: Colors.green),
                  onPressed: () async {
                    await parse(ingController.text);
                  }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _fridgeItems.length,
              itemBuilder: (context, index) {
                var fridgeItem = _fridgeItems[index];
                return FridgeItemWidget(
                  foodLabel: fridgeItem['foodLabel'],
                  expirationDate: DateTime.parse(fridgeItem['expirationDate']),
                  totalCalories: fridgeItem['totalCalories'],
                  quantity: fridgeItem['ingredients'][0]['quantity'],
                  measure: fridgeItem['measure'],
                  onTap: () {
                    // TODO: Navigate to the nutrients page when tapped
                    print("Tapped!");
                  },
                  onEdit: () {
                    // TODO: Implement edit functionality
                    print("Edit Button!");
                  },
                  onDelete: () {
                    // TODO: Implement delete functionality
                    print("Delete Button!");
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const bottomBar(
        selectedIndex: 0, //  Main Index
      ),
    );
  }

  Future<void> _showBarcodeScanner() async {
    if (isScanSupported()) {
      // Barcode scanning is supported, show the bottom sheet as usual
      Completer<void> completer = Completer<void>();
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: Scaffold(
                appBar: _buildBarcodeScannerAppBar(),
                body: _buildBarcodeScannerBody(),
              ),
            );
          });
        },
      ).whenComplete(() => completer.complete());
      await completer.future;
    } else {
      // Barcode scanning is not supported, show a popup
      _showUnsupportedFeaturePopup();
    }
  }

  // Function to show a popup for unsupported feature
  void _showUnsupportedFeaturePopup() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Feature Not Supported'),
          content:
              const Text('Barcode scanning is not supported on your device.'),
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

  AppBar _buildBarcodeScannerAppBar() {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(color: Colors.purpleAccent, height: 4.0),
      ),
      title: const Text('Scan Your Barcode'),
      elevation: 0.0,
      backgroundColor: const Color(0xFF333333),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Center(
            child: Icon(
          Icons.cancel,
          color: Colors.white,
        )),
      ),
      actions: [
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
                onTap: () => controller.toggleTorchMode(),
                child: const Icon(Icons.flashlight_on))),
      ],
    );
  }

  Widget _buildBarcodeScannerBody() {
    return SizedBox(
      height: 400,
      child: ScanView(
        controller: controller,
        scanAreaScale: .7,
        scanLineColor: Colors.purpleAccent,
        onCapture: (data) {
          setState(() {
            _scanResult = data;
            Navigator.of(context).pop();
          });
        },
      ),
    );
  }
}

String formatQuantity(double quantity, String measure) {
  String formattedQuantity =
      quantity.toStringAsFixed(1); // Format quantity to 1 decimal place
  String pluralizedMeasure = quantity == 1
      ? measure
      : '${measure}s'; // Append 's' to measure if quantity is not 1
  return '$formattedQuantity $pluralizedMeasure';
}

class FridgeItemWidget extends StatelessWidget {
  final String foodLabel;
  final DateTime expirationDate;
  final double totalCalories;
  final double quantity;
  final String measure;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FridgeItemWidget({
    super.key,
    required this.foodLabel,
    required this.expirationDate,
    required this.totalCalories,
    required this.quantity,
    required this.measure,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(foodLabel),
      subtitle: Text(
        'Expiration Date: ${DateFormat('MM/dd/yy').format(expirationDate)}\n'
        'Quantity: ${formatQuantity(quantity, measure)}\n'
        'Total Calories: $totalCalories',
      ),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
