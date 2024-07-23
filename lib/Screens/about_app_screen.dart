import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About This App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 16),
              Text(
                'This app is designed to help you manage your habits efficiently. Here are some of the key features:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.blueAccent),
              _buildFeatureTile(
                context,
                icon: Icons.add_circle,
                title: 'Create Habit',
                description: 'Easily create new habits and set goals for yourself.',
                color: Colors.green,
              ),
              Divider(color: Colors.blueAccent),
              _buildFeatureTile(
                context,
                icon: Icons.delete,
                title: 'Delete Habit',
                description: 'Remove habits that are no longer relevant to you.',
                color: Colors.red,
              ),
              Divider(color: Colors.blueAccent),
              _buildFeatureTile(
                context,
                icon: Icons.update,
                title: 'Replan Habit',
                description: 'Replan your habits to better fit your schedule.',
                color: Colors.orange,
              ),
              Divider(color: Colors.blueAccent),
              _buildFeatureTile(
                context,
                icon: Icons.check_circle,
                title: 'Mark as Done',
                description: 'Mark habits as done to track your progress.',
                color: Colors.blue,
              ),
              Divider(color: Colors.blueAccent),
              _buildFeatureTile(
                context,
                icon: Icons.bar_chart,
                title: 'View Statistics',
                description: 'View detailed statistics to analyze your habit performance.',
                color: Colors.purple,
              ),
              Divider(color: Colors.blueAccent),
              _buildFeatureTile(
                context,
                icon: Icons.notifications,
                title: 'Reminders',
                description: 'Set reminders to ensure you never miss a habit.',
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, {required IconData icon, required String title, required String description, required Color color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: TextStyle(fontSize: 16)),
    );
  }
}
