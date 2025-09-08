import 'package:flutter/material.dart';
import 'package:habit_tracker/Screens/contact_us.dart';
import 'about_app_screen.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt_rounded, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Treat Budget',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 24, left: 16, right: 16),
              children: [
                _buildListTile(context,
                    icon: Icons.info_outline_rounded,
                    title: 'About App',
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutAppScreen()),
                        )),
                SizedBox(height: 12),
                _buildListTile(
                  context,
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactUsScreen()),
                  ),
                )
              ],
            ),
          ),

          // App Version
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade800),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
        hoverColor: Colors.blue.shade50,
      ),
    );
  }
}
