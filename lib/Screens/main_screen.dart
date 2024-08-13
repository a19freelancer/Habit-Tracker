// import'package:flutter/material.dart';
// import 'package:habit_tracker/Screens/profile_screen.dart';
// import 'package:habit_tracker/Screens/progress_screen.dart';
//
// import 'home_screen.dart';
// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   static List<Widget> _widgetOptions = <Widget>[
//     HomeScreen(),
//     // HabitProgressScreen(),
//     // ProfileScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgetOptions.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.show_chart),
//           //   label: 'Progress',
//           // ),
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.person),
//           //   label: 'Profile',
//           // ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }