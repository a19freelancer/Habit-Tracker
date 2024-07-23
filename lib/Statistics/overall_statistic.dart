import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OverallStatisticsScreen extends StatefulWidget {
  @override
  _OverallStatisticsScreenState createState() => _OverallStatisticsScreenState();
}

class _OverallStatisticsScreenState extends State<OverallStatisticsScreen> {
  late List<Map<String, dynamic>> _doneHabitsData = [];

  @override
  void initState() {
    super.initState();
    _fetchDoneHabitsData();
  }

  Future<void> _fetchDoneHabitsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doneHabitsSnapshot = await FirebaseFirestore.instance
          .collection('DoneHabits')
          .where('email', isEqualTo: user.email)
          .get();

      List<Map<String, dynamic>> doneHabitsData = [];

      doneHabitsSnapshot.docs.forEach((doc) {
        String habitName = doc['habitName'];
        List<Timestamp> completedDates = List<Timestamp>.from(doc['completedDates']);
        String month = completedDates.isNotEmpty ? DateFormat('MMMM').format(completedDates.first.toDate()) : 'Unknown';
        int totalCompletedDays = completedDates.length;

        doneHabitsData.add({
          'habitName': habitName,
          'month': month,
          'totalCompletedDays': totalCompletedDays,
        });
      });

      setState(() {
        _doneHabitsData = doneHabitsData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _doneHabitsData.isEmpty
            ? Center(child: Text('No data found', style: TextStyle(fontSize: 18)))
            : ListView.builder(
          itemCount: _doneHabitsData.length,
          itemBuilder: (context, index) {
            final data = _doneHabitsData[index];
            return Column(
              children: [
                Container(
                  width: 500,
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
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['habitName'],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Month: ${data['month']}',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total Completed Days: ${data['totalCompletedDays']}',
                          style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < _doneHabitsData.length - 1)
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 32,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
