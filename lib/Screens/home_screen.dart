import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Habit/habit_details.dart';
import '../Habit/habit_list.dart';
import '../Habit/add_habit.dart';
import '../Habit/today_habit.dart';
import '../Habit/habit_details.dart';
import 'drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Habits For Current Month', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blueAccent,
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 30),
                SizedBox(width: 10),
                Text(
                  currentDate,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(child: HabitsGroupedByDay()), // Updated to use grouped habits
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.blue,
        overlayColor: Colors.black.withOpacity(0.5),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            label: 'Add a new habit',
            labelBackgroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddHabitScreen()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.settings),
            backgroundColor: Colors.blue,
            label: 'Manage Habits',
            labelBackgroundColor: Colors.blue,
            onTap: () {
              Get.to(MyHabitsScreen());
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: SideDrawer(),
    );
  }
}

class HabitsGroupedByDay extends StatefulWidget {
  @override
  _HabitsGroupedByDayState createState() => _HabitsGroupedByDayState();
}

class _HabitsGroupedByDayState extends State<HabitsGroupedByDay> {
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;
  final DateTime now = DateTime.now();

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
          return Center(child: Text('😊 You have no habits.', style: TextStyle(fontSize: 18, color: Colors.grey)));
        }

        // Convert habit dates into distinct dates (removing duplicates)
        List<Map<String, dynamic>> habits = snapshot.data!.docs.map((habit) {
          final List<dynamic> habitDates = habit['plannedDays'];
          return {
            'habitName': habit['habitName'],
            'habitId': habit.id,
            'habitDates': habitDates
                .map((timestamp) => (timestamp as Timestamp).toDate())
                .toSet()
                .toList(),
            'isDone': habit['isDone'] == 'completed',
          };
        }).toList();

        // Filter habits for today and future
        final currentAndFutureHabits = habits.where((habit) {
          return (habit['habitDates'] as List<DateTime>).any((date) {
            return date.isAfter(now) || (date.day == now.day && date.month == now.month && date.year == now.year);
          });
        }).toList();

        // Group habits by date
        Map<DateTime, List<Map<String, dynamic>>> groupedHabits = {};

        for (var habit in currentAndFutureHabits) {
          final List<DateTime> habitDates = habit['habitDates'] as List<DateTime>;
          for (var date in habitDates) {
            if (date.isAfter(now) || (date.day == now.day && date.month == now.month && date.year == now.year)) {
              final key = DateTime(date.year, date.month, date.day); // Only keep date, no time
              if (groupedHabits.containsKey(key)) {
                groupedHabits[key]!.add(habit);
              } else {
                groupedHabits[key] = [habit];
              }
            }
          }
        }

        // Sort the grouped dates: today first, then future dates in ascending order
        final today = DateTime(now.year, now.month, now.day);
        final sortedDates = groupedHabits.keys.toList()
          ..sort((a, b) {
            if (a == today) return -1; // today comes first
            if (b == today) return 1;
            return a.compareTo(b); // sort future dates in ascending order
          });

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final habitsForDate = groupedHabits[date]!;

            final formattedDate = DateFormat('EEEE, MMM d').format(date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header - Smaller, same width as habits, and aligned
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: EdgeInsets.symmetric(vertical: 5),
                  width: double.infinity,  // Full width for both date and habits
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                // List of Habits for this Date
                Column(
                  children: habitsForDate.map((habit) {
                    final habitName = habit['habitName'];
                    final bool isDone = habit['isDone'];

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade200, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: Colors.white, size: 30),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habitName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
