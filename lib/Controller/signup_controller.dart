import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging

class SignUpController extends GetxController {
  var name = ''.obs;
  var nameError = ''.obs;
  var email = ''.obs;
  var emailError = ''.obs;
  var password = ''.obs;
  var passwordError = ''.obs;
  var isValid = false.obs;
  var loading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance; // Instance of Firebase Messaging

  void validateFields() {
    nameError.value = name.value.isEmpty ? 'Please enter your name' : '';
    emailError.value = email.value.isEmpty ? 'Please enter your email' : '';
    passwordError.value = password.value.isEmpty ? 'Please enter your password' : '';

    isValid.value = nameError.value.isEmpty && emailError.value.isEmpty && passwordError.value.isEmpty;

    if (isValid.value) {
      signUp();
    }
  }

  Future<void> signUp() async {
    loading.value = true;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value.trim(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.value,
        'email': email.value,
      });

      // Save device token
      saveDeviceToken(userCredential.user!.uid);

      // Navigate to home page after successful sign-up
      Get.offNamed('/home', arguments: {
        'name': name.value,
        'email': email.value,
        'imageUrl': '', // Add default image URL if available
      });
    } catch (e) {
      Get.snackbar('Sign Up Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    loading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        loading.value = false;
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        // Check if user already exists in Firestore
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Save user data to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'imageUrl': user.photoURL,
          });
        }

        // Save device token
        saveDeviceToken(user.uid);

        // Navigate to home page after successful sign-in
        Get.offNamed('/home', arguments: {
          'name': user.displayName,
          'email': user.email,
          'imageUrl': user.photoURL,
        });
      }
    } catch (e) {
      Get.snackbar('Google Sign-In Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  void saveDeviceToken(String userId) async {
    String? token = await _messaging.getToken();

    if (token != null) {
      await _firestore.collection('userTokens').doc(userId).set({
        'tokens': FieldValue.arrayUnion([token]),
      });
    }
  }
}
