import 'package:get/get.dart';
import 'package:habit_tracker/Screens/main_screen.dart';
import '../Screens/home_screen.dart';
import '../Screens/splash_screen.dart';

class Routes {
  static final List<GetPage> routes = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/home', page: () => HomeScreen()),
  ];
}
