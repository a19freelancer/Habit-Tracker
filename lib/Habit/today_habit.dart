// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../Screens/habit_progress.dart'; // Import the new screen

// class TodayHabitsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final String currentDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
//     final String userEmail = FirebaseAuth.instance.currentUser!.email!;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Text('All Habits', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16),
//             color: Colors.blueAccent,
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_today, color: Colors.white, size: 30),
//                 SizedBox(width: 10),
//                 Text(
//                   currentDate,
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('habits')
//                   .where('userEmail', isEqualTo: userEmail)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No habits found.', style: TextStyle(fontSize: 18, color: Colors.grey)));
//                 }

//                 final habits = snapshot.data!.docs;

//                 return ListView.builder(
//                   itemCount: habits.length,
//                   itemBuilder: (context, index) {
//                     final habit = habits[index];
//                     final habitName = habit['habitName'];
//                     final habitDates = List<Timestamp>.from(habit['plannedDays']);
//                     final monthName = habitDates.isNotEmpty
//                         ? DateFormat('MMMM').format(habitDates.first.toDate())
//                         : 'No Date';

//                     bool isDone = habit['isDone'] is bool ? habit['isDone'] : false;

//                     return GestureDetector(
//                       onTap: () {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => HabitProgressScreen(
//                         //       habitId: habit.id,
//                         //       habitName: habitName,
//                         //     ),
//                         //   ),
//                         //   ),
//                         // );
//                       },
//                       child: Container(
//                         margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                         padding: EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.blue.shade200, Colors.blue.shade600],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 5,
//                               blurRadius: 7,
//                               offset: Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               habitName,
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                             ),
//                             SizedBox(height: 5),
//                             Text(
//                               monthName,
//                               style: TextStyle(fontSize: 16, color: Colors.white70),
//                             ),
//                             Divider(color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
