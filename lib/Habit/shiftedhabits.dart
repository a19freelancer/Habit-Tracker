import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShiftedHabitsScreen extends StatefulWidget {
  @override
  _ShiftedHabitsScreenState createState() => _ShiftedHabitsScreenState();
}

class _ShiftedHabitsScreenState extends State<ShiftedHabitsScreen> {
  late List<Map<String, dynamic>> _shiftedHabits = [];

  @override
  void initState() {
    super.initState();
    _fetchShiftedHabits();
  }

  Future<void> _fetchShiftedHabits() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final shiftedHabitsSnapshot = await FirebaseFirestore.instance
            .collection('ShiftedHabits')
            .where('email', isEqualTo: user.email)
            .get();

        List<Map<String, dynamic>> shiftedHabits = [];

        shiftedHabitsSnapshot.docs.forEach((doc) {
          String habitName = doc['habitName'];
          List<Timestamp> newDates = List.from(doc['newDates']);
          List<Timestamp> shiftedDates = List.from(doc['shiftedDates']);

          shiftedHabits.add({
            'habitName': habitName,
            'newDates': newDates,
            'shiftedDates': shiftedDates,
          });
        });

        setState(() {
          _shiftedHabits = shiftedHabits;
        });
      } catch (e) {
        print('Error fetching shifted habits data: $e');
        // Handle error (e.g., show error message)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shifted Habits'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _shiftedHabits.isEmpty
            ? Center(
          child: Text(
            'No shifted habits found for the current user.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: _shiftedHabits.length,
          itemBuilder: (context, index) {
            String habitName = _shiftedHabits[index]['habitName'];
            List<Timestamp> newDates = _shiftedHabits[index]['newDates'];
            List<Timestamp> shiftedDates =
            _shiftedHabits[index]['shiftedDates'];
            int totalShiftedDays = shiftedDates.length;

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'New Dates:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: newDates
                          .map((timestamp) =>
                          Text(timestamp.toDate().toString()))
                          .toList(),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Shifted Dates (Total Days: $totalShiftedDays):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: shiftedDates
                          .map((timestamp) =>
                          Text(timestamp.toDate().toString()))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
