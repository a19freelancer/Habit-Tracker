import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/Screens/contact_us.dart';

import '../Profile/edit_profile.dart';
import 'about_app_screen.dart';
class SideDrawer extends StatelessWidget {
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return  Drawer(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('images/avatar.png'), // Replace with your placeholder image asset path
          ),
          SizedBox(height: 16),
          Text(
            user?.displayName ?? 'User Name',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About App'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AboutAppScreen()),
              );
            },
          ),
          Divider(),
          // ListTile(
          //   leading: Icon(Icons.update),
          //   title: Text('Update'),
          //   onTap: () {
          //     // Navigate to Update screen
          //   },
          // ),
          // Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.perm_contact_cal_rounded),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ContactUsScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showLogoutConfirmationDialog(context),
          ),
          Divider(),
        ],
      ),
      );


  }
}