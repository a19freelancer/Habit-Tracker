import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Statistics/monthly_statistic.dart';
import '../Statistics/overall_statistic.dart';

class HabitProgressScreen extends StatelessWidget {
  const HabitProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Progress'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             const  CurrentMonthHabitsList(), // Custom widget for Current Month Habits List
              const SizedBox(height: 20),

              // Monthly Statistics Container
              GestureDetector(
                onTap: () {
                  Get.to(MonthlyStatisticsScreen());
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  padding: EdgeInsets.all(16.0),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: const AssetImage('images/stats_1.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Monthly Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Overall Statistics Container
              GestureDetector(
                onTap: () {
                  Get.to(OverallStatisticsScreen());
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: const AssetImage('images/stats_2.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Overall Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
             const  SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for Current Month Habits List
class CurrentMonthHabitsList extends StatelessWidget {
  const CurrentMonthHabitsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('CurrentMonthHabits')
          .where('userEmail',
              isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const  Center(child: CircularProgressIndicator());
        }

        final habits = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];

            return Card(
              child: ListTile(
                title: Text(habit['habitName']),
                subtitle: Text('Days: ${habit['days']}'),
              ),
            );
          },
        );
      },
    );
  }
}
