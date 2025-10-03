import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../DataBaseHelper/habit.dart';
import 'habit_details.dart';
import 'add_habit.dart';

class MyHabitsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Budgets',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: HabitsList(),
    );
  }
}

class HabitsList extends StatefulWidget {
  @override
  State<HabitsList> createState() => _HabitsListState();
}

class _HabitsListState extends State<HabitsList> {
  late Future<List<Map<String, dynamic>>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  void _fetchHabits() {
    setState(() {
      _habitsFuture = DBHelper().getHabitsByUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _habitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.blue.shade800,
          ));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_emotions_outlined,
                    size: 60, color: Colors.grey.shade400),
                SizedBox(height: 16),
                Text('No budgets found',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
                Text('Tap + to create new budgets',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        final habits = snapshot.data!;

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: habits.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final habit = habits[index];
            final habitName = habit['habitName'];
            final totalDays = habit['totalDaysPerMonth'];
            final plannedDaysList = habit['plannedDays'] != null
                ? habit['plannedDays'].split(',')
                : [];
            final plannedDays =
                plannedDaysList.isEmpty ? 0 : plannedDaysList.length;
            final unplannedDays = habit['unplannedDays'];

            final String monthName = plannedDaysList.isNotEmpty
                ? DateFormat('MMMM').format(DateTime.parse(plannedDaysList[0]))
                : 'Unplanned';

            return _buildHabitCard(
              context,
              habit: habit,
              habitName: habitName,
              totalDays: totalDays,
              plannedDays: plannedDays,
              unplannedDays: unplannedDays,
              monthName: monthName,
            );
          },
        );
      },
    );
  }

  Widget _buildHabitCard(
    BuildContext context, {
    required Map<String, dynamic> habit,
    required String habitName,
    required int totalDays,
    required int plannedDays,
    required int unplannedDays,
    required String monthName,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          onTap: () => _navigateToEditScreen(context, habit),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_outlined,
                color: Colors.blue.shade800, size: 28),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(habitName,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800)),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey.shade500),
                onPressed: () =>
                    _showDeleteConfirmationDialog(context, habit['id']),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              _buildStatRow(
                icon: Icons.calendar_month_outlined,
                primaryText: '$totalDays days/month',
                secondaryText: 'Target',
              ),
              SizedBox(height: 4),
              _buildStatRow(
                icon: Icons.check_circle_outline,
                primaryText: '$plannedDays planned',
                secondaryText: 'Completed',
                color: Colors.green.shade600,
              ),
              SizedBox(height: 4),
              _buildStatRow(
                icon: Icons.warning_amber_outlined,
                primaryText: '$unplannedDays unplanned',
                secondaryText: 'Missed',
                color: Colors.orange.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String primaryText,
    required String secondaryText,
    Color color = Colors.grey,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(primaryText,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500)),
            Text(secondaryText,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        )
      ],
    );
  }

  void _navigateToEditScreen(BuildContext context, Map<String, dynamic> habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(
          initialHabit: HabitDetails(
            id: habit['id'].toString(),
            habitName: habit['habitName'],
            totalDays: habit['totalDaysPerMonth'],
            plannedDays: (habit['plannedDays']?.split(',') ?? [])
                .map<DateTime>((date) => DateTime.parse(date))
                .toList(),
            startDate: DateTime.parse(habit['startDate']),
          ),
        ),
      ),
    ).then((_) => _fetchHabits());
  }

  void _showDeleteConfirmationDialog(BuildContext context, int habitId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever_outlined,
                    size: 40, color: Colors.red.shade400),
                SizedBox(height: 16),
                Text('Delete Budget?',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('This action cannot be undone',
                    style: TextStyle(color: Colors.grey.shade600)),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.grey.shade700)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                      ),
                      child: Text('Delete'),
                      onPressed: () async {
                        await DBHelper().deleteHabit(habitId);
                        Navigator.of(context).pop();
                        _fetchHabits();
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
  }
}
