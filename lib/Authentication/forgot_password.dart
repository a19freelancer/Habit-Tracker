import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/Authentication/login_page.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs; // Observable for loading state

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true; // Set loading state to true
      await _auth.sendPasswordResetEmail(email: email);
      showSuccessDialog();
    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to send password reset email: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false; // Set loading state to false after operation completes
    }
  }

  void showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Password Reset Email Sent'),
        content: Text('Please check your email for the password reset link.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
              Get.to(LoginPage()); // Navigate to login page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe2e5ee),
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/logo.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(height: 20),
              const Text(
                'Enter your email ',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xffe7e7e7),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade800.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () {
                    final email = emailController.text.trim();
                    if (email.isNotEmpty && isValidEmail(email)) {
                      resetPassword(email);
                    } else {
                      Get.snackbar(
                        'Error',
                        'Please enter a valid email',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: isLoading.value
                      ? CircularProgressIndicator() // Show circular progress indicator if loading
                      : const Text(
                    "Send Reset Link",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xff384cff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
