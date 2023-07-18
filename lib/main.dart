//======= Import Statements =======

import 'dart:async';

import 'package:flutter/material.dart';
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

  // Function to handle getting the token
  Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token');
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

  void _onSearchChanged(String searchText) {
    //  Add search functionality
  }

  @override
  Widget build(BuildContext context) {
    // Size based on screen
    final double containerWidth = MediaQuery.of(context).size.width > 600
        ? 600
        : MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const topBar(title: 'Main Page'),
      body: Center(
        child: Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Search Ingredients', //  Change this???
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.green),
                        onPressed: () async {
                          await _showBarcodeScanner();
                          if (_scanResult.isNotEmpty) {
                            await parse(_scanResult);
                            _scanResult = "";
                          }
                        }),
                    title: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    trailing: const Icon(Icons.search, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
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
