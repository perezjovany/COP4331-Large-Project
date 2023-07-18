import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'login.dart';
import 'signup.dart';
import 'calendar.dart';
import 'account.dart';
import 'list.dart';
import 'top_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData appTheme = ThemeData(
      primarySwatch: Colors.green,
      hintColor: Colors.greenAccent,
      textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.green[700])),
    );

    // Handles all navigation, will need tweaking once connected to backend
    return MaterialApp(
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/main': (context) => const MainPage(),
        '/calendar': (context) => const CalendarPage(),
        '/account': (context) => const AccountPage(),
        '/list': (context) => const ListPage(),
      },
      theme: appTheme,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _onQRCodeScanPressed() {
    //  Add QR functionality
  }

  void _onSearchChanged(String searchText) {
    //  Add search functionality
  }

  @override
  Widget build(BuildContext context) {
    // Size based on screen
    final double containerWidth =
    MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width;

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
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.green),
                      onPressed: _onQRCodeScanPressed,
                    ),

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
}
