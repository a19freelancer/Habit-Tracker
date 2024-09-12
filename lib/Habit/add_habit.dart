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
  Map<int, List<DateTime>> _selectedDatesPerMonth ={};
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

    // Calculate the number of complete months that have passed, including the current month
    int monthsElapsed = (currentMonthStart.year - habitStartMonth.year) * 12 +
        (currentMonthStart.month - habitStartMonth.month) + 1;

    // Total possible days up to and including the current month
    int totalPossibleDays = monthsElapsed * _totalDaysPerMonth;

    // Calculate the total number of planned days so far, including the current month
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
                  readOnly: widget.initialHabit != null, // Makes the field read-only if habit exists
                  validator: (value) {
                    if (widget.initialHabit == null) {// Only validate if adding a new habit
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of days';
                      } else if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Please enter a valid number of days';
                      }
                    }


                    return null;
                  },
                  onChanged: (value) {
                    if (widget.initialHabit == null) { // Only allow changes if adding a new habit
                      setState(() {
                        _initialDaysPerMonth = int.tryParse(value) ?? 0;
                        _totalDaysPerMonth = _initialDaysPerMonth;
                        _selectedDatesPerMonth.clear();
                        _calculateUnplannedDays();
                      });
                    }
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
                      // Check if the day is in the list of planned days for the respective month
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
                      // Optionally, you can customize the already selected (planned) days
                      markerDecoration: BoxDecoration(
                        color: Colors.green,  // Mark planned days with a green dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                )
                    : Container(),

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

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  bool _isDaySelected(DateTime day) {

    DateTime dayWithoutTimezone = DateTime(day.year, day.month, day.day);
    int month = dayWithoutTimezone.month;
    List<DateTime>? selectedDates = _selectedDatesPerMonth[month];
    bool  isSelected=false;
    if(selectedDates!=null){
      isSelected = selectedDates.any((selectedDate) => isSameDate(selectedDate, day));_selectedDatesPerMonth[month]?.contains(dayWithoutTimezone) ?? false;
    }
    // If the day is selected, print the date
    print('Day: $dayWithoutTimezone');
    print('Month: $month');
    print(_selectedDatesPerMonth);
    print(widget.initialHabit?.plannedDays);
    if (isSelected) {
      print("Selected Date: ${day.toString()}");
    }

    return isSelected;
  }


  void _handleDaySelection(DateTime selectedDay) {
    print('unplanned days before $_totalUnplannedDays');
    // Strip the time component from the selected day
    DateTime dayWithoutTimezone = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    int month = dayWithoutTimezone.month;
    List<DateTime>? selectedDates = _selectedDatesPerMonth[month];
    _focusedDay = dayWithoutTimezone;

    // Initialize the month list if not already initialized
    if (!_selectedDatesPerMonth.containsKey(month)) {
      _selectedDatesPerMonth[month] = [];
    }

    _calculateUnplannedDays();
    List<DateTime> selectedDaysForMonth = _selectedDatesPerMonth[month]!;

    int availableDaysForMonth = _totalDaysPerMonth + _totalUnplannedDays;

    // Check if the day is already selected by comparing only the date (not time)
    bool isAlreadySelected = selectedDaysForMonth.any(
            (selectedDate) => selectedDate.year == dayWithoutTimezone.year && selectedDate.month == dayWithoutTimezone.month && selectedDate.day == dayWithoutTimezone.day);

    if (isAlreadySelected) {
      // Unselect the day if already selected
      selectedDaysForMonth.removeWhere(
            (selectedDate) => selectedDate.year == dayWithoutTimezone.year && selectedDate.month == dayWithoutTimezone.month && selectedDate.day == dayWithoutTimezone.day,
      );

    } else {
      // Add the day if it's not already selected and within the limit
      if (selectedDaysForMonth.length < availableDaysForMonth) {
        selectedDaysForMonth.add(dayWithoutTimezone);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only select $availableDaysForMonth days this month')),
        );
      }
    }
    _calculateUnplannedDays();
    print('unplanned days after$_totalUnplannedDays');
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
        _calculateUnplannedDays();
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
