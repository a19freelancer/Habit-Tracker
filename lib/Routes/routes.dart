import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/Screens/main_screen.dart';
import '../Authentication/signup_page.dart';
import '../Authentication/login_page.dart';
import '../Screens/home_screen.dart';
import '../Screens/splash_screen.dart';

class Routes {

  static final List<GetPage> routes = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/signup', page: () => const SignUp()),
    GetPage(name: '/home', page: () =>  HomeScreen()),

  
  ];
}
