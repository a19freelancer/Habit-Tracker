import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'habit_details.dart';
import 'add_habit.dart'; // Import the AddHabitScreen

class MyHabitsScreen extends StatelessWidget {
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Habits', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen if needed
            },
          ),
        ],
      ),
      body: HabitsList(userEmail: userEmail),
    );
  }
}

class HabitsList extends StatelessWidget {
  final String userEmail;

  HabitsList({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('habits')
          .where('userEmail', isEqualTo: userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('😊 You have no habits.',
                  style: TextStyle(fontSize: 18, color: Colors.grey)));
        }

        final habits = snapshot.data!.docs;

        return ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final habitName = habit['habitName'];
            final totalDays = habit['totalDaysthisMonth'];
            final plannedDaysList = habit['plannedDays'] as List;
            final plannedDays = plannedDaysList.isEmpty ? 0 : plannedDaysList.length;
            final unplannedDays = habit['unplannedDays'];

            // Get the month name for the habit if plannedDays is not empty
            final String monthName = plannedDaysList.isNotEmpty
                ? DateFormat('MMMM').format((plannedDaysList[0] as Timestamp).toDate())
                : 'Unplanned';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitDetailScreen(
                      habitId: habit.id,
                      habitName: habitName,
                      habitDates: habit['plannedDays'],
                      isDone: habit['isDone'],
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$habitName',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            _showReplanConfirmationDialog(context, habit);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Total Days: $totalDays',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          plannedDays == 0
                              ? 'No Planned Days Set'
                              : 'Planned Days: $plannedDays',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Unplanned Days: $unplannedDays',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, habit.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReplanConfirmationDialog(BuildContext context, DocumentSnapshot habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Replan'),
          content: Text('Are you sure you want to replan this habit?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Replan',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddHabitScreen(
                      initialHabit: HabitDetails(
                        id: habit.id,
                        habitName: habit['habitName'],
                        totalDays: habit['totalDays'],
                        plannedDays: List<DateTime>.from(
                            (habit['plannedDays'] as List)
                                .map((timestamp) => (timestamp as Timestamp).toDate())),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String habitId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this habit?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('habits')
                    .doc(habitId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
