// // habit_progress_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class HabitProgressScreen extends StatelessWidget {
//   final String habitId;
//   final String habitName;
//
//   HabitProgressScreen({required this.habitId, required this.habitName});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(habitName),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance.collection('habits').doc(habitId).get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Center(child: Text('No data found.'));
//           }
//
//           final habitData = snapshot.data!.data() as Map<String, dynamic>;
//           final completedDays = habitData['completedDays']?.length ?? 0;
//           final totalDays = habitData['totalDays'] ?? 1;
//
//           final progress = completedDays / totalDays;
//
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Progress',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 20,
//                   backgroundColor: Colors.grey.shade300,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   '${(progress * 100).toStringAsFixed(2)}%',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
