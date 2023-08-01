import 'package:flutter/material.dart';

// CustomBottomNavBar Widget
class bottomBar extends StatelessWidget {
  // Selected Index for the navigation bar
  final int? selectedIndex;

  // Constructor
  const bottomBar({
    super.key,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.green, // Background color for the navigation bar

      selectedItemColor: Colors.white, // Color for the selected item
      unselectedItemColor:
          Colors.white.withOpacity(0.6), // Color for the unselected item

      selectedFontSize: 18, // Font size for the selected item
      unselectedFontSize: 14, // Font size for the unselected item

      type: BottomNavigationBarType.fixed, // Type of bottom navigation bar
      currentIndex: selectedIndex ?? 0, // Current index for the navigation bar

      onTap: (index) {
        // Handling navigation on tap
        Navigator.of(context).pop();
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/main');
            break;
          case 1:
            Navigator.pushNamed(context, '/calendar');
            break;
          case 2:
            Navigator.pushNamed(context, '/list');
            break;
        }
      },

      items: const <BottomNavigationBarItem>[
        // Navigation bar items

        //Fridge section
        BottomNavigationBarItem(
          icon: Icon(Icons.kitchen), // Icon for the item
          label: 'Fridge', // Label for the item
        ),

        //Calendar section
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today), // Icon for the item
          label: 'Calendar', // Label for the item
        ),

        //List section
        BottomNavigationBarItem(
          icon: Icon(Icons.list), // Icon for the item
          label: 'List', // Label for the item
        ),
      ],
    );
  }
}
