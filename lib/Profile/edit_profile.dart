import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;

  Future<void> _showEditDialog({
    required String field,
    required String label,
    required TextEditingController controller,
  }) async {
    final TextEditingController currentPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                bool reauthenticated = await _reauthenticateUser(currentPasswordController.text);
                if (reauthenticated) {
                  if (field == 'name') {
                    await _updateName(controller.text);
                  } else if (field == 'password') {
                    await _updatePassword(controller.text);
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Current password is incorrect')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _reauthenticateUser(String currentPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> _updateName(String name) async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'name': name});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Name updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update name: $e')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updatePassword(String password) async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(password);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    TextEditingController nameController = TextEditingController(text: user?.displayName);
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Name'),
              subtitle: Text(user?.displayName ?? 'User Name'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditDialog(
                    field: 'name',
                    label: 'Name',
                    controller: nameController,
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Email'),
              subtitle: Text(user?.email ?? 'user@example.com'),
            ),
            Divider(),
            ListTile(
              title: Text('Password'),
              subtitle: Text('********'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditDialog(
                    field: 'password',
                    label: 'Password',
                    controller: passwordController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
