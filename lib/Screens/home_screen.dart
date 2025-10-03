import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Habit/add_habit.dart';
import '../Habit/habit_list.dart';
import 'drawer.dart';
import '../DataBaseHelper/habit.dart';
import '../Habit/habit_details.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('MMMM y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 5,
        title: const Text('Treat Budget',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
      ),
      body: Column(
        children: [
          _buildDateHeader(currentDate),
          const Expanded(child: HabitsGroupedByDay()),
        ],
      ),
      floatingActionButton: _buildCustomSpeedDial(context),
      drawer: SideDrawer(),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.blue.shade800, size: 28),
          const SizedBox(width: 12),
          Text(
            date,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  SpeedDial _buildCustomSpeedDial(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      activeIcon: Icons.close,
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
      overlayColor: Colors.black54,
      elevation: 8,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add, color: Colors.blue.shade800),
          backgroundColor: Colors.white,
          label: 'Add New Budget',
          labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddHabitScreen()),
            );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.settings, color: Colors.blue.shade800),
          backgroundColor: Colors.white,
          label: 'Manage Budgets',
          labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800),
          onTap: () => Get.to(MyHabitsScreen()),
        ),
      ],
    );
  }
}

class HabitsGroupedByDay extends StatefulWidget {
  const HabitsGroupedByDay({super.key});

  @override
  _HabitsGroupedByDayState createState() => _HabitsGroupedByDayState();
}

class _HabitsGroupedByDayState extends State<HabitsGroupedByDay> {
  final DateTime now = DateTime.now();
  late Future<List<Map<String, dynamic>>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _habitsFuture = DBHelper().getHabitsByUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DBHelper().watchHabitsByUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Log to console for devs
          debugPrint('DB Stream Error: ${snapshot.error}');
          // Show user-visible fallback
          return Center(
            child: Text(
              '⚠️ Oops! Something went wrong loading budgets.',
              style: TextStyle(fontSize: 16, color: Colors.red.shade600),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('😊 You have no budgets.',
                  style: TextStyle(fontSize: 18, color: Colors.grey)));
        }

        List<Map<String, dynamic>> habits = snapshot.data!.map((habit) {
          final List<String> plannedDays =
              (habit['plannedDays'] as String).split(',');
          final List<DateTime> habitDates = plannedDays.map((date) {
            return DateFormat('yyyy-MM-dd').parse(date);
          }).toList();

          return {
            'habitName': habit['habitName'],
            'habitId': habit['id'],
            'habitDates': habitDates,
            'isDone': habit['isDone'] ?? 0, // Ensure isDone is treated as int
            'dayspermonth': habit['totalDaysPerMonth']
          };
        }).toList();

        final currentAndFutureHabits = habits.where((habit) {
          return (habit['habitDates'] as List<DateTime>).any((date) {
            return date.isAfter(now) ||
                (date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year);
          });
        }).toList();

        Map<DateTime, List<Map<String, dynamic>>> groupedHabits = {};

        for (var habit in currentAndFutureHabits) {
          final List<DateTime> habitDates =
              habit['habitDates'] as List<DateTime>;
          for (var date in habitDates) {
            if (date.isAfter(now) ||
                (date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year)) {
              final key = DateTime(date.year, date.month, date.day);
              if (groupedHabits.containsKey(key)) {
                groupedHabits[key]!.add(habit);
              } else {
                groupedHabits[key] = [habit];
              }
            }
          }
        }

        final today = DateTime(now.year, now.month, now.day);
        final sortedDates = groupedHabits.keys.toList()
          ..sort((a, b) {
            if (a == today) return -1;
            if (b == today) return 1;
            return a.compareTo(b);
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
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15, bottom: 8),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: date == today
                          ? Colors.blue.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                ...habitsForDate.map((habit) => _buildHabitCard(habit)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    final bool isDone = habit['isDone'] == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDone ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDone ? Colors.green.shade100 : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            leading: Icon(
              isDone ? Icons.check_circle : Icons.circle_outlined,
              color: isDone ? Colors.green.shade600 : Colors.grey.shade400,
              size: 28,
            ),
            title: Text(
              habit['habitName'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey.shade600 : Colors.grey.shade800,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitDetailsScreen(habit: habit),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
