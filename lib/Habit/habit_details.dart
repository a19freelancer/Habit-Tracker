import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  _HabitDetailsScreenState createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late Map<DateTime, int> _monthlyPlanned = {};
  late Map<DateTime, int> _monthlyCompleted = {};
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _processHabitData();
  }

  void _processHabitData() {
    final plannedDays = widget.habit['habitDates'];

    _monthlyPlanned = _groupByMonth(plannedDays);
    _monthlyCompleted = _calculateCompletedDays(plannedDays);
  }

  Map<DateTime, int> _groupByMonth(List<DateTime> dates) {
    final map = <DateTime, int>{};
    for (final date in dates) {
      final month = DateTime(date.year, date.month);
      map[month] = (map[month] ?? 0) + 1;
    }
    return map;
  }

  Map<DateTime, int> _calculateCompletedDays(List<DateTime> plannedDates) {
    final map = <DateTime, int>{};
    final now = DateTime.now();

    for (final date in plannedDates) {
      if (date.isBefore(now)) {
        final month = DateTime(date.year, date.month);
        map[month] = (map[month] ?? 0) + 1;
      }
    }
    return map;
  }

  List<DateTime> _getAllMonths() {
    final months =
        <DateTime>{..._monthlyPlanned.keys, ..._monthlyCompleted.keys}.toList();
    months.sort();
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = widget.habit['dayspermonth'] as int? ?? 0;
    final plannedCount = _monthlyPlanned.values.fold(0, (sum, v) => sum + v);
    final remaining = (totalDays * _monthlyPlanned.length) - plannedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit['habitName']),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(totalDays, plannedCount, remaining),
            const SizedBox(height: 24),
            _buildMonthlyChart(),
            const SizedBox(height: 24),
            _buildMonthlyDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int total, int planned, int remaining) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatItem('Days/Month', total.toString(), Colors.blue.shade800,
            Icons.calendar_month),
        _buildStatItem('Planned', planned.toString(), Colors.green.shade600,
            Icons.checklist_rounded),
        _buildStatItem('Remaining', remaining.toString(),
            Colors.orange.shade600, Icons.pending_actions_rounded),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final months = _getAllMonths();
    final now = DateTime.now();

    return Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: BarChart(
          BarChartData(
            barGroups: months.map((m) {
              return BarChartGroupData(
                x: months.indexOf(m),
                barRods: [
                  BarChartRodData(
                    toY: _monthlyPlanned[m]?.toDouble() ?? 0,
                    color: Colors.blue.shade800,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: _monthlyCompleted[m]?.toDouble() ?? 0,
                    color: Colors.green.shade600,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Removed top titles
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: false), // Removed right-side vertical titles
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < months.length) {
                      return Text(DateFormat('MMM y').format(months[index]),
                          style: TextStyle(fontSize: 12));
                    }
                    return Container();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: true),
            gridData: FlGridData(show: false),
            maxY: _monthlyPlanned.values
                .fold(0, (max, v) => v > max ? v : max)
                .toDouble(),
          ),
        ));
  }

  Widget _buildMonthlyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._getAllMonths().map((month) => _buildMonthCard(month)),
      ],
    );
  }

  Widget _buildMonthCard(DateTime month) {
    final planned = _monthlyPlanned[month] ?? 0;
    final completed = _monthlyCompleted[month] ?? 0;
    final isCurrentMonth =
        month.month == _currentDate.month && month.year == _currentDate.year;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM y').format(month)),
              Text('$completed/$planned days',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: planned > 0 ? completed / planned : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          if (isCurrentMonth) ...[
            const SizedBox(height: 12),
            Text(
              '${_calculateRemainingCurrentMonth(planned, completed)} days remaining this month',
              style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
            )
          ]
        ],
      ),
    );
  }

  int _calculateRemainingCurrentMonth(int planned, int completed) {
    final currentMonthDays =
        _monthlyPlanned[DateTime(_currentDate.year, _currentDate.month)] ?? 0;
    final futureDays = currentMonthDays - completed;
    return futureDays > 0 ? futureDays : 0;
  }
}
