import 'package:flutter/material.dart';

class topBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const topBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          // Navigate to the '/main' route when the user taps on the leading widget
          Navigator.pushNamed(context, '/main');
        },

        child: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Add padding to the left of the logo
          child: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset('assets/white-logo.png'),
          ),
        ),
      ),

      title: Text(title),
      actions: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.notifications, size: 30.0),
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
        ),

        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, size: 30.0),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Profile',
                  child: Text('Profile'),
                ),

                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],

              onSelected: (value) {
                if (value == 'Logout') {
                  // [PLACEHOLDER] Navigate to the root route when the user selects 'Logout', will require proper functionality
                  Navigator.pushNamed(context, '/');
                } else if (value == 'Profile') {
                  // Navigate to the '/account' route when the user selects 'Profile'
                  Navigator.pushNamed(context, '/account');
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  // Custom height
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
