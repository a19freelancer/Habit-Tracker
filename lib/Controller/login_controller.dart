// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// import '../Model/habit_model.dart';
//
// class LoginController extends GetxController {
//   var email = ''.obs;
//   var password = ''.obs;
//   var emailError = ''.obs;
//   var passwordError = ''.obs;
//   var loading = false.obs;
//   var userName = ''.obs;
//   var userProfilePic = ''.obs;
//   var habits = <Habit>[].obs;
//
//   final storage = GetStorage();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   // void onInit() {
//   //   // super.onInit();
//   //   // loadSavedCredentials();
//   // }
//
//   // void loadSavedCredentials() {
//   //   if (storage.read('rememberMe') == true) {
//   //     email.value = storage.read('email') ?? '';
//   //     password.value = storage.read('password') ?? '';
//   //   }
//   // }
//
//   // void validateFields() {
//   //   emailError.value = '';
//   //   passwordError.value = '';
//   //
//   //   if (email.isEmpty) {
//   //     emailError.value = 'Email is required';
//   //   } else if (!GetUtils.isEmail(email.value)) {
//   //     emailError.value = 'Enter a valid email';
//   //   }
//   //
//   //   if (password.isEmpty) {
//   //     passwordError.value = 'Password is required';
//   //   }
//   //
//   //   if (emailError.isEmpty && passwordError.isEmpty) {
//   //     signIn();
//   //   }
//   // }
//
//   // Future<void> signIn() async {
//   //   loading.value = true;
//   //   try {
//   //     UserCredential userCredential = await FirebaseAuth.instance
//   //         .signInWithEmailAndPassword(email: email.value, password: password.value);
//   //
//   //     if (storage.read('rememberMe') == true) {
//   //       storage.write('email', email.value);
//   //       storage.write('password', password.value);
//   //     }
//   //
//   //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//   //         .collection('users')
//   //         .doc(userCredential.user?.uid)
//   //         .get();
//   //
//   //     userName.value = userDoc['name'] ?? 'No Name';
//   //     userProfilePic.value = userDoc['imageUrl'] ?? '';
//   //
//   //     habits.bindStream(habitStream());
//   //
//   //     storage.write('user', {
//   //       'uid': userCredential.user?.uid,
//   //       'name': userName.value,
//   //       'imageUrl': userProfilePic.value,
//   //     });
//   //
//   //     Get.offNamed('/home', arguments: {
//   //       'name': userName.value,
//   //       'imageUrl': userProfilePic.value,
//   //     });
//   //
//   //   } catch (error) {
//   //     Get.snackbar('Error', 'Failed to sign in: $error');
//   //   } finally {
//   //     loading.value = false;
//   //   }
//   // }
//
//   // Stream<List<Habit>> habitStream() {
//   //   return _firestore
//   //       .collection('users')
//   //       .doc(_auth.currentUser?.uid)
//   //       .collection('habits')
//   //       .snapshots()
//   //       .map((QuerySnapshot query) {
//   //     List<Habit> retVal = [];
//   //     query.docs.forEach((element) {
//   //       retVal.add(Habit.fromDocumentSnapshot(element));
//   //     });
//   //     return retVal;
//   //   });
//   // }
//   //
//   // Future<void> addHabit(String name) async {
//   //   await _firestore
//   //       .collection('users')
//   //       .doc(_auth.currentUser?.uid)
//   //       .collection('habits')
//   //       .add({
//   //     'name': name,
//   //     'usedDays': 0,
//   //     'totalDays': 5,
//   //   });
//   // }
//
//   void logout() async {
//     await _auth.signOut();
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//     await googleSignIn.signOut();
//     storage.erase();
//     Get.offNamed('/login');
//   }
//   // Future<UserCredential> signInWithGoogle() async {
//   //   final GoogleSignIn googleSignIn = GoogleSignIn();
//   //
//   //   // Ensure the previous session is cleared
//   //   await googleSignIn.signOut();
//   //
//   //   // Trigger the authentication flow
//   //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//   //
//   //   if (googleUser == null) {
//   //     return Future.error('Sign in aborted by user');
//   //   }
//   //
//   //   // Obtain the auth details from the request
//   //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//   //
//   //   // Create a new credential
//   //   final AuthCredential credential = GoogleAuthProvider.credential(
//   //     accessToken: googleAuth.accessToken,
//   //     idToken: googleAuth.idToken,
//   //   );
//   //
//   //   try {
//   //     // Once signed in, return the UserCredential
//   //     UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//   //
//   //     // Update controller values with Google user info
//   //     userName.value = googleUser.displayName ?? 'No Name';
//   //     userProfilePic.value = googleUser.photoUrl ?? '';
//   //
//   //     // Save user data to local storage
//   //     storage.write('user', {
//   //       'uid': userCredential.user?.uid,
//   //       'name': userName.value,
//   //       'imageUrl': userProfilePic.value,
//   //     });
//   //
//   //     // Navigate to the home page after successful login
//   //     Get.offNamed('/home', arguments: {
//   //       'name': userName.value,
//   //       'imageUrl': userProfilePic.value,
//   //     });
//   //
//   //     return userCredential;
//   //   } catch (error) {
//   //     Get.snackbar('Error', 'Failed to sign in with Google: $error');
//   //     return Future.error('Failed to sign in with Google: $error');
//   //   }
//   // }
// }
//
//
