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
  Map<int, List<DateTime>> _selectedDatesPerMonth = {};
  int _totalDaysPerMonth = 0;
  int _totalUnplannedDays = 0;
  int _initialDaysPerMonth = 0; // Initial days per month defined by user

  String? _habitId;
  DateTime _focusedDay = DateTime.now();
  DateTime _habitStartDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialHabit != null) {
      _habitNameController.text = widget.initialHabit!.habitName;
      _daysController.text = widget.initialHabit!.totalDays.toString();
      _totalDaysPerMonth = widget.initialHabit!.totalDays;
      _habitId = widget.initialHabit!.id;
      _habitStartDate = widget.initialHabit!.startDate;

      // Populate _selectedDatesPerMonth and calculate unplanned days
      widget.initialHabit!.plannedDays.forEach((date) {
        int month = date.month;
        if (!_selectedDatesPerMonth.containsKey(month)) {
          _selectedDatesPerMonth[month] = [];
        }
        _selectedDatesPerMonth[month]!.add(date);
      });

      _calculateUnplannedDays();
    }
  }

  void _calculateUnplannedDays() {
    DateTime currentMonthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime habitStartMonth = DateTime(_habitStartDate.year, _habitStartDate.month, 1);

    // Calculate the number of complete months that have passed, excluding the current month
    int monthsElapsed = (currentMonthStart.year - habitStartMonth.year) * 12 +
        (currentMonthStart.month - habitStartMonth.month);

    // Total possible days up to the month before the current month
    int totalPossibleDays = monthsElapsed * _initialDaysPerMonth;

    // Calculate the total number of planned days so far
    int totalPlannedDays = 0;
    _selectedDatesPerMonth.forEach((month, dates) {
      if (month != currentMonthStart.month) {
        totalPlannedDays += dates.length;
      }
    });

    // Calculate unplanned days
    _totalUnplannedDays = totalPossibleDays - totalPlannedDays;

    // Ensure that unplanned days don't drop below zero
    if (_totalUnplannedDays < 0) {
      _totalUnplannedDays = 0;
    }
  }

  void _calculateUnplannedDays2() {
    DateTime currentMonthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime habitStartMonth = DateTime(_habitStartDate.year, _habitStartDate.month, 1);

    // Calculate the number of complete months that have passed, excluding the current month
    int monthsElapsed = (currentMonthStart.year - habitStartMonth.year) * 12 +
        (currentMonthStart.month - habitStartMonth.month)+1;

    // Total possible days up to the month before the current month
    int totalPossibleDays = monthsElapsed * _initialDaysPerMonth;

    // Calculate the total number of planned days so far
    int totalPlannedDays = 0;
    _selectedDatesPerMonth.forEach((month, dates) {

      totalPlannedDays += dates.length;

    });

    // Calculate unplanned days
    _totalUnplannedDays = totalPossibleDays - totalPlannedDays;

    // Ensure that unplanned days don't drop below zero
    if (_totalUnplannedDays < 0) {
      _totalUnplannedDays = 0;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialHabit != null ? 'Edit Habit' : 'Add New Habit'),
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
                      _initialDaysPerMonth = int.tryParse(value) ?? 0;
                      _totalDaysPerMonth = _initialDaysPerMonth;
                      _selectedDatesPerMonth.clear();
                      _calculateUnplannedDays();
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Select Dates',
                  style: TextStyle(fontSize: 18, color: _totalDaysPerMonth > 0 ? Colors.black : Colors.grey),
                ),
                SizedBox(height: 10),
                _totalDaysPerMonth > 0
                    ? Container(
                  height: 400,
                  child: TableCalendar(
                    firstDay: _habitStartDate,
                    lastDay: DateTime.now().add(Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return _isDaySelected(day);
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
                  _selectedDatesPerMonth.isEmpty
                      ? 'No dates selected'
                      : 'Selected dates: ${_getSelectedDatesFormatted()}',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _totalDaysPerMonth > 0 ? _addOrUpdateHabit : null,
                  child: Text(widget.initialHabit != null ? 'Update Habit' : 'Add Habit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isDaySelected(DateTime day) {
    int month = day.month;
    return _selectedDatesPerMonth[month]?.contains(day) ?? false;
  }

  void _handleDaySelection(DateTime selectedDay) {
    _focusedDay=selectedDay;
    int month = selectedDay.month;

    // Initialize the month list if not already
    if (!_selectedDatesPerMonth.containsKey(month)) {
      _selectedDatesPerMonth[month] = [];

    }
    _calculateUnplannedDays();
    List<DateTime> selectedDaysForMonth = _selectedDatesPerMonth[month]!;
    print(_initialDaysPerMonth);
    print(_totalUnplannedDays);
    int availableDaysForMonth = _initialDaysPerMonth+_totalUnplannedDays;

    if (selectedDaysForMonth.contains(selectedDay)) {
      selectedDaysForMonth.remove(selectedDay);
    } else {
      if (selectedDaysForMonth.length < availableDaysForMonth) {
        selectedDaysForMonth.add(selectedDay);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only select $availableDaysForMonth days this month')),
        );
      }
    }
  }

  String _getSelectedDatesFormatted() {
    List<String> formattedDates = [];
    _selectedDatesPerMonth.forEach((month, dates) {
      formattedDates.addAll(dates.map((date) => DateFormat('yyyy-MM-dd').format(date)));
    });
    return formattedDates.join(', ');
  }

  Future<void> _addOrUpdateHabit() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String habitName = _habitNameController.text;

        List<Timestamp> plannedDays = _selectedDatesPerMonth.values
            .expand((dates) => dates)
            .map((date) => Timestamp.fromDate(date))
            .toList();
        _calculateUnplannedDays2();
        if (_habitId != null) {
          await FirebaseFirestore.instance.collection('habits').doc(_habitId).set({
            'habitName': habitName,
            'totalDaysPerMonth': _totalDaysPerMonth,
            'plannedDays': plannedDays,
            'userEmail': user.email,
            'isDone': false,
            'startDate': _habitStartDate,
            'unplannedDays':_totalUnplannedDays
          }, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance.collection('habits').add({
            'habitName': habitName,
            'totalDaysPerMonth': _totalDaysPerMonth,
            'plannedDays': plannedDays,
            'userEmail': user.email,
            'isDone': false,
            'startDate': _habitStartDate,
            'unplannedDays':_totalUnplannedDays
          });
        }

        Navigator.of(context).pop();
      }
    }
  }
}

class HabitDetails {
  final String id;
  final String habitName;
  final int totalDays;
  final List<DateTime> plannedDays;
  final DateTime startDate;

  HabitDetails({
    required this.id,
    required this.habitName,
    required this.totalDays,
    required this.plannedDays,
    required this.startDate,
  });
}
