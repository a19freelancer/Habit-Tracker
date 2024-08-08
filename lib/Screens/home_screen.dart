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
        title: Text('Habits For Current Month', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: (value) {
        //       if (value == 'todayHabits') {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => TodayHabitsScreen()),
        //         );
        //       }
        //     },
        //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        //       const PopupMenuItem<String>(
        //         value: 'todayHabits',
        //         child: ListTile(
        //           leading: Icon(Icons.today),
        //           title: Text('Habits'),
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
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
          Expanded(child: TodayHabitsList()), // Update to use TodayHabitsList
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
            label: 'Settings',
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



class TodayHabitsList extends StatefulWidget {
  @override
  _TodayHabitsListState createState() => _TodayHabitsListState();
}

class _TodayHabitsListState extends State<TodayHabitsList> {
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;
  final DateTime now = DateTime.now();
  String selectedFilter = 'Today';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Dropdown
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text('Filter: ', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: selectedFilter,
                items: <String>['Today', 'This Week', 'This Month'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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

              final habits = snapshot.data!.docs.where((habit) {
                final List<dynamic> habitDates = habit['plannedDays'];
                return habitDates.any((timestamp) {
                  final date = (timestamp as Timestamp).toDate();
                  if (selectedFilter == 'Today') {
                    return date.day == now.day && date.month == now.month && date.year == now.year;
                  } else if (selectedFilter == 'This Week') {
                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    final endOfWeek = startOfWeek.add(Duration(days: 6));
                    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek.add(Duration(days: 1)));
                  } else if (selectedFilter == 'This Month') {
                    return date.month == now.month && date.year == now.year;
                  }
                  return false;
                });
              }).toList();

              if (habits.isEmpty) {
                return Center(
                  child: Text(
                    'Congrats buddy, you do not have any habit for $selectedFilter!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final habitName = habit['habitName'];
                  final bool isDone = habit['isDone'] == 'completed'; // Adjust the isDone value

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            habitId: habit.id,
                            habitName: habitName,
                            habitDates: habit['plannedDays'],
                            isDone: isDone,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      padding: EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 30),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habitName,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


