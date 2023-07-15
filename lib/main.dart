//======= Import Statements =======

import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';


//======= Entry Point of the App =======

void main() => runApp(MyApp());

//======= Root Widget MyApp =======

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ThemeData appTheme = ThemeData(
        primarySwatch: Colors.green,     // Primary color
        hintColor: Colors.greenAccent,   // Second color
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.green[700])) // Default color for text in the app.
    );

    return MaterialApp(
      // Handles navigation
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/main': (context) => MainPage(),
      },

      theme: appTheme,
    );
  }
}


//======= MainPage Widget - User will land here after login =======

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // AppBar - Top menu bar
      appBar: AppBar(
        toolbarHeight: 80.0,
        title: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Image.asset(
            'assets/white-logo.png',
            width: 80,
            height: 80,
          ),
        ),

        // Options to the right of the menu bar
        actions: <Widget>[
          // Notification icon
          Padding(
            padding: EdgeInsets.only(top: 20.0, right: 10.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.notifications, size: 30.0),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

                const PopupMenuItem<String>(
                  value: 'Option1',
                  child: Text('Option 1'),
                ),

                const PopupMenuItem<String>(
                  value: 'Option2',
                  child: Text('Option 2'),
                ),

              ],
            ),
          ),

          // Account icon
          Padding(
            padding: EdgeInsets.only(top: 20.0, right: 10.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.account_circle, size: 30.0),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

                const PopupMenuItem<String>(
                  value: 'Profile',
                  child: Text('Profile'),
                ),

                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Text('Settings'),
                ),

                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],

              onSelected: (value) {
                if (value == 'Logout') {
                  Navigator.pushNamed(context, '/');
                }
              },
            ),
          ),
        ],
      ),

      // Body
      body: Center(

        child: Container(
          width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[
              Text(
                'Search Ingredients',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),

              SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: Colors.green),
                    onPressed: () {},
                  ),
                  title: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {},
                  ),
                  trailing: Icon(Icons.search, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),

      //===== Bottom navigation bar

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Fridge',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Recipes',
          ),
        ],
      ),

    );
  }
}
