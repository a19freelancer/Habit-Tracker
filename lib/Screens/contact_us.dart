import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            _buildContactInfo(
              icon: Icons.person,
              label: 'Name',
              value: 'Ward',
            ),
            SizedBox(height: 16),
            _buildContactInfo(
              icon: Icons.email,
              label: 'Email',
              value: 'ward.berckmans@gmail.com',
            ),
            SizedBox(height: 16),
            _buildContactInfo(
              icon: Icons.phone,
              label: 'Phone',
              value: '+123 456 7890',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
