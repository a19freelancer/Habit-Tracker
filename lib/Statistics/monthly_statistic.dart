import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonthlyStatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current month and year
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    // Get the currently logged-in user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Monthly Statistics'),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: Text('No user logged in.')),
      );
    }

    final userEmail = currentUser.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Statistics'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('habits')
            .where('userEmail', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No habits found.'));
          }

          final habits = snapshot.data!.docs;

          // Filter habits for the current month
          final filteredHabits = habits.where((habit) {
            List<Timestamp> plannedDays = List<Timestamp>.from(habit['plannedDays']);
            return plannedDays.any((timestamp) {
              DateTime date = timestamp.toDate();
              return date.month == currentMonth && date.year == currentYear;
            });
          }).toList();

          return ListView.builder(
            itemCount: filteredHabits.length,
            itemBuilder: (context, index) {
              final habit = filteredHabits[index];
              final habitName = habit['habitName'] ?? 'Unknown Habit';
              final isDone = habit['isDone'] == 'true'; // Convert string 'true' to boolean true
              final plannedDays = habit['totalPlannedDays'] ?? 0;
              final unplannedDays = habit['unplannedDays'] ?? 0;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration:  BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade200, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habitName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Status: ${isDone ? 'Completed' : 'Incomplete'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Planned Days: $plannedDays',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Unplanned Days: $unplannedDays',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Divider(),

                        // Add other habit details here
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
