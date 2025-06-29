// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> signOut(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('email');
//       await prefs.remove('password');
//       await prefs.remove('userName');
//       await prefs.remove('userProfilePic');

//       Navigator.pushReplacementNamed(context, '/');
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to sign out: $error')),
//       );
//     }
//   }
// }
