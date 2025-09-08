import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../DataBaseHelper/habit.dart';
import '../NotificationHandler/notification_handler.dart';

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
      _habitStartDate = widget.initialHabit!.startDate;
      _habitId = widget.initialHabit!.id;
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
    DateTime currentMonthStart =
        DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime habitStartMonth =
        DateTime(_habitStartDate.year, _habitStartDate.month, 1);

    // Calculate the number of complete months that have passed, including the current month
    int monthsElapsed = (currentMonthStart.year - habitStartMonth.year) * 12 +
        (currentMonthStart.month - habitStartMonth.month) +
        1;

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
    DateTime currentMonthStart =
        DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime habitStartMonth =
        DateTime(_habitStartDate.year, _habitStartDate.month, 1);

    // Calculate the number of complete months that have passed, excluding the current month
    int monthsElapsed = (currentMonthStart.year - habitStartMonth.year) * 12 +
        (currentMonthStart.month - habitStartMonth.month) +
        1;

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

  Future<bool> _willPop() async {
    await _addOrUpdateHabit(); // Call update function
    return true; // Allow screen to pop
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.initialHabit != null ? 'Edit Habit' : 'Create New Habit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue.shade800,
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHabitNameField(),
                    const SizedBox(height: 24),
                    _buildDaysPerMonthField(),
                    const SizedBox(height: 28),
                    _buildCalendarSection(),
                    const SizedBox(height: 24),
                    if (widget.initialHabit == null) _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitNameField() {
    return TextFormField(
      controller: _habitNameController,
      decoration: InputDecoration(
        labelText: 'Habit Name',
        floatingLabelStyle: TextStyle(color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
        hintText: 'Enter habit name...',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a habit name';
        }
        return null;
      },
    );
  }

  Widget _buildDaysPerMonthField() {
    return TextFormField(
      controller: _daysController,
      decoration: InputDecoration(
        labelText: 'Days per Month',
        floatingLabelStyle: TextStyle(color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: widget.initialHabit != null,
        fillColor: widget.initialHabit != null ? Colors.grey.shade100 : null,
        hintText: 'Enter number of days...',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: widget.initialHabit != null
            ? Icon(Icons.lock_outline, size: 20, color: Colors.grey)
            : null,
      ),
      style: TextStyle(
        fontSize: 16,
        color: widget.initialHabit != null
            ? Colors.grey.shade600
            : Colors.grey.shade800,
      ),
      keyboardType: TextInputType.number,
      readOnly: widget.initialHabit != null,
      enabled: widget.initialHabit == null,
      validator: (value) {
        if (widget.initialHabit == null) {
          if (value == null || value.trim().isEmpty) {
            return 'Required field';
          }
          final int? days = int.tryParse(value);
          if (days == null || days <= 0) {
            return 'Enter a valid number';
          }
        }
        return null;
      },
      onChanged: (value) {
        if (widget.initialHabit == null) {
          final int? days = int.tryParse(value);
          setState(() {
            _initialDaysPerMonth = days ?? 0;
            _totalDaysPerMonth = _initialDaysPerMonth;
            _selectedDatesPerMonth.clear();
            _calculateUnplannedDays();
          });
        }
      },
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _totalDaysPerMonth > 0
                ? Colors.grey.shade800
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        if (_totalDaysPerMonth > 0)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            padding: EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: _habitStartDate,
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _isDaySelected(day),
              enabledDayPredicate: (day) => true,
              onDaySelected: (selectedDay, focusedDay) {
                final today = DateUtils.dateOnly(DateTime.now());
                if (!selectedDay.isBefore(today)) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _handleDaySelection(selectedDay);
                  });
                }
              },
              onPageChanged: (focusedDay) =>
                  setState(() => _focusedDay = focusedDay),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Colors.grey.shade800),
                weekendTextStyle: TextStyle(color: Colors.grey.shade800),
                disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                outsideTextStyle: TextStyle(color: Colors.grey.shade400),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final today = DateUtils.dateOnly(DateTime.now());
                  final selectedDate = DateUtils.dateOnly(day);

                  if (_isDaySelected(day) && selectedDate.isBefore(today)) {
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(day.day.toString(),
                            style: TextStyle(color: Colors.blue.shade800)),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800),
                formatButtonVisible: false,
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.blue.shade800),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.blue.shade800),
                headerPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        onPressed: _totalDaysPerMonth > 0 ? _addOrUpdateHabit : null,
        child: Text(
          'Save Habit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
    bool isSelected = false;
    if (selectedDates != null) {
      isSelected =
          selectedDates.any((selectedDate) => isSameDate(selectedDate, day));
      _selectedDatesPerMonth[month]?.contains(dayWithoutTimezone) ?? false;
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
    DateTime dayWithoutTimezone =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    int month = dayWithoutTimezone.month;
    if (dayWithoutTimezone.year == DateTime.now().year ||
        dayWithoutTimezone.month == DateTime.now().month ||
        dayWithoutTimezone.day == DateTime.now().day) {
      print('Today is clicked');
    }
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
    bool isAlreadySelected = selectedDaysForMonth.any((selectedDate) =>
        selectedDate.year == dayWithoutTimezone.year &&
        selectedDate.month == dayWithoutTimezone.month &&
        selectedDate.day == dayWithoutTimezone.day);

    if (isAlreadySelected) {
      // Unselect the day if already selected
      selectedDaysForMonth.removeWhere(
        (selectedDate) =>
            selectedDate.year == dayWithoutTimezone.year &&
            selectedDate.month == dayWithoutTimezone.month &&
            selectedDate.day == dayWithoutTimezone.day,
      );
    } else {
      // Add the day if it's not already selected and within the limit
      if (selectedDaysForMonth.length < availableDaysForMonth) {
        selectedDaysForMonth.add(dayWithoutTimezone);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'You can only select $availableDaysForMonth days this month')),
        );
      }
    }
    _calculateUnplannedDays();
    print('unplanned days after$_totalUnplannedDays');
    if (widget.initialHabit != null) {}
  }

  String _getSelectedDatesFormatted() {
    List<String> formattedDates = [];
    _selectedDatesPerMonth.forEach((month, dates) {
      formattedDates
          .addAll(dates.map((date) => DateFormat('yyyy-MM-dd').format(date)));
    });
    return formattedDates.join(', ');
  }

  Future<void> _addOrUpdateHabit() async {
    if (_formKey.currentState!.validate()) {
      String habitName = _habitNameController.text;

      List<String> plannedDays = _selectedDatesPerMonth.values
          .expand((dates) => dates)
          .map((date) => date.toIso8601String())
          .toList();

      _calculateUnplannedDays();

      Map<String, dynamic> habitData = {
        'habitName': habitName,
        'totalDaysPerMonth': _totalDaysPerMonth,
        'plannedDays':
            plannedDays.join(','), // Store as a comma-separated string
        'isDone': 0, // SQLite doesn't have boolean, use 0 and 1
        'startDate': _habitStartDate.toIso8601String(),
        'unplannedDays': _totalUnplannedDays,
      };

      final dbHelper = DBHelper();
      int habitId;

      if (_habitId != null) {
        habitId = int.parse(_habitId!);
        await dbHelper.updateHabit(habitId, habitData);
      } else {
        habitId = await dbHelper.insertHabit(habitData);
      }

      // ✅ Schedule notifications for the habit
      // await scheduleHabitForPlannedDays(
      //     habitId, habitName, plannedDays.join(','));

      Navigator.of(context).pop();
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
