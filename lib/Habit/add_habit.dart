import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitDetails? initialHabit;

  AddHabitScreen({this.initialHabit});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  List<DateTime> _selectedDates = [];
  int _totalDays = 0;

  String? _habitId;

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialHabit != null) {
      _habitNameController.text = widget.initialHabit!.habitName;
      _daysController.text = widget.initialHabit!.totalDays.toString();
      _selectedDates = widget.initialHabit!.plannedDays;
      _totalDays = widget.initialHabit!.totalDays;
      _habitId = widget.initialHabit!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Habit'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _habitNameController,
                  decoration: InputDecoration(labelText: 'Habit Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a habit name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _daysController,
                  decoration: InputDecoration(labelText: 'Number of Days per Month'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of days';
                    } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number of days';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _totalDays = int.tryParse(value) ?? 0;
                      _selectedDates.clear();
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Select Dates',
                  style: TextStyle(fontSize: 18, color: _totalDays > 0 ? Colors.black : Colors.grey),
                ),
                SizedBox(height: 10),
                _totalDays > 0
                    ? Container(
                  height: 400,
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(Duration(days: 365)), // One year range
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return _selectedDates.contains(day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        _handleDaySelection(selectedDay);
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
                    : Container(),
                SizedBox(height: 10),
                Text(
                  _selectedDates.isEmpty
                      ? 'No dates selected'
                      : 'Selected dates: ${_selectedDates.map((date) => DateFormat('yyyy-MM-dd').format(date)).join(', ')}',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _totalDays > 0 ? _addOrUpdateHabit : null,
                  child: Text(widget.initialHabit != null ? 'Update Habit' : 'Add Habit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDaySelection(DateTime selectedDay) {
    int selectedMonth = selectedDay.month;

    // Count days already selected in the current month
    int daysInMonth = _selectedDates.where((date) => date.month == selectedMonth).length;

    if (_selectedDates.contains(selectedDay)) {
      _selectedDates.remove(selectedDay);
    } else {
      if (daysInMonth < _totalDays) {
        _selectedDates.add(selectedDay);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only select $_totalDays days in this month')),
        );
      }
    }
  }

  Future<void> _addOrUpdateHabit() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String habitName = _habitNameController.text;
        int totalPlannedDays = _selectedDates.length;
        int unplannedDays = _totalDays  - totalPlannedDays; // Total unplanned days in a year

        List<Timestamp> plannedDays = _selectedDates.map((date) => Timestamp.fromDate(date)).toList();

        if (_habitId != null) {
          await FirebaseFirestore.instance.collection('habits').doc(_habitId).set({
            'habitName': habitName,
            'totalDaysthisMonth':_totalDays,
            'totalDays': _totalDays,
            'plannedDays': plannedDays,
            'totalPlannedDays': totalPlannedDays,
            'unplannedDays': unplannedDays,
            'userEmail': user.email,
            'isDone': false,
          }, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance.collection('habits').add({
            'habitName': habitName,
            'totalDaysthisMonth':_totalDays,
            'totalDays': _totalDays,
            'plannedDays': plannedDays,
            'totalPlannedDays': totalPlannedDays,
            'unplannedDays': unplannedDays,
            'userEmail': user.email,
            'isDone': false,
          });
        }

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the necessary details')),
      );
    }
  }
}

class HabitDetails {
  final String id;
  final String habitName;
  final int totalDays;
  final List<DateTime> plannedDays;

  HabitDetails({
    required this.id,
    required this.habitName,
    required this.totalDays,
    required this.plannedDays,
  });
}
