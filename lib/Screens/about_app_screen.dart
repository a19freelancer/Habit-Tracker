import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Treat Budget',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 32),
              _buildFeatureCard(
                icon: Icons.add_task_rounded,
                title: 'Create Budget',
                description:
                    'Easily create new budgets and set personalized goals',
                color: Colors.green.shade600,
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.delete_forever_rounded,
                title: 'Delete Budget',
                description: 'Remove budgets that are no longer relevant',
                color: Colors.red.shade600,
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.update_rounded,
                title: 'Replan Budget',
                description: 'Adjust schedules for better budget management',
                color: Colors.orange.shade600,
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.check_circle_outline_rounded,
                title: 'Mark as Done',
                description: 'Track progress with completion marking',
                color: Colors.blue.shade600,
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.analytics_rounded,
                title: 'View Statistics',
                description: 'Analyze performance with detailed insights',
                color: Colors.purple.shade600,
              ),
              SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.notifications_active_rounded,
                title: 'Reminders',
                description: 'Never miss a budget with smart notifications',
                color: Colors.teal.shade600,
              ),
              SizedBox(height: 24),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(Icons.self_improvement_rounded,
              size: 64, color: Colors.blue.shade800),
        ),
        SizedBox(height: 24),
        Text(
          'Transform Your Life',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'A powerful tool to build and maintain positive habits through:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800)),
                  SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
