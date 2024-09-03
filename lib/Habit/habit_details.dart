import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  final String habitName;
  final List<dynamic> habitDates;
  final bool isDone;

  HabitDetailScreen({
    required this.habitId,
    required this.habitName,
    required this.habitDates,
    required this.isDone,
  });

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late List<DateTime> habitDates;
  late List<bool> isDoneList;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    habitDates = widget.habitDates.map((timestamp) => (timestamp as Timestamp).toDate()).toList();
    habitDates = habitDates.where((date) => date.month == DateTime.now().month && date.year == DateTime.now().year).toList();
    isDoneList = List.generate(habitDates.length, (_) => false);
  }

  void _getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email; // Ensure user is not null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.habitName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            habitDates.isEmpty
                ? Center(
              child: Text(
                'You did not plan any dates for this habit.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: habitDates.length,
                itemBuilder: (context, index) {
                  final date = habitDates[index];
                  final dateString = DateFormat('yyyy-MM-dd').format(date);
                  DateTime today = DateTime.now();
                  bool isPastDate = date.isBefore(DateTime(today.year, today.month, today.day));

                  return Dismissible(
                    key: Key(date.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _moveDateToUnplanned(date);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        tileColor: isPastDate ? Colors.grey[200] : null,
                        title: Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isPastDate ? Colors.grey : Colors.black,
                          ),
                        ),

                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ElevatedButton(
                //   onPressed: _markHabitDone,
                //   child: Text('Mark Habit Done' , style: TextStyle(color: Colors.white),),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //     textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _moveDateToUnplanned(DateTime date) async {
    final doc = await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).get();
    final habitData = doc.data();
    final List<Timestamp> habitDatesFirestore = List.from(habitData?['plannedDays']);
    // final List<Timestamp> unplannedDaysFirestore = List.from(habitData?['unplannedDays'] ?? []);
    final int totalPlannedDays = habitData?['totalPlannedDays'] ?? 0;
    final int unplannedDaysCount = habitData?['unplannedDays'] ?? 0;

    if (habitDatesFirestore.contains(Timestamp.fromDate(date))) {
      setState(() {
        habitDates.remove(date);
        isDoneList = List.generate(habitDates.length, (_) => false);
      });

      habitDatesFirestore.remove(Timestamp.fromDate(date));
      // unplannedDaysFirestore.add(Timestamp.fromDate(date));

      await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).update({
        'plannedDays': habitDatesFirestore,
        // 'unplannedDays': unplannedDaysFirestore,
        'totalPlannedDays': totalPlannedDays - 1,
        'unplannedDays': unplannedDaysCount + 1,
      });
    }
  }

  void _markHabitDone() async {
    DateTime today = DateTime.now();
    List<DateTime> completedDates = [];

    for (int i = 0; i < isDoneList.length; i++) {
      if (isDoneList[i]) {
        if (habitDates[i].day != today.day || habitDates[i].month != today.month || habitDates[i].year != today.year) {
          _showErrorDialog('You can only mark the current date as done.');
          return;
        }
        completedDates.add(habitDates[i]);
      }
    }

    if (completedDates.isNotEmpty) {
      setState(() {
        for (var date in completedDates) {
          habitDates.removeWhere((habitDate) => habitDate.isAtSameMomentAs(date));
        }
        isDoneList = List.generate(habitDates.length, (_) => false);
      });

      final doc = await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).get();
      final habitData = doc.data();
      final List<Timestamp> habitDatesFirestore = List.from(habitData?['plannedDays']);
      final List<Timestamp> completedDaysFirestore = List.from(habitData?['completedDays'] ?? []);

      for (var date in completedDates) {
        habitDatesFirestore.remove(Timestamp.fromDate(date));
        completedDaysFirestore.add(Timestamp.fromDate(date));
      }

      await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).update({
        'plannedDays': habitDatesFirestore,
        'completedDays': completedDaysFirestore,
        'isDone': habitDatesFirestore.isEmpty ? 'completed' : 'incomplete',
      });

      // Check if all planned days are completed (habitDatesFirestore is empty)
      if (habitDatesFirestore.isEmpty) {
        final totalPlannedDays = habitData?['totalPlannedDays'] ?? 0;
        final totalCompletedDays = completedDaysFirestore.length;

        // Move habit to DoneHabits collection only if all planned days are completed
        if (totalPlannedDays == totalCompletedDays) {
          await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).delete();

          await FirebaseFirestore.instance.collection('DoneHabits').add({
            'habitName': widget.habitName,
            'plannedDays': totalPlannedDays,
            'completedDates': completedDates.map((date) => Timestamp.fromDate(date)).toList(),
            'email': userEmail,
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
