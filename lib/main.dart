import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../NotificationHandler/notification_handler.dart';
import 'Routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localTimeNow = DateTime.now();
  print("🕒 Device Local Time: $localTimeNow");
  await initializeNotifications();
  await scheduleTestNotification();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConnectivityResult _connectivityResult;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    _connectivityResult =
        (await _connectivity.checkConnectivity()) as ConnectivityResult;
    _updateConnectionStatus(_connectivityResult);

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    } as void Function(List<ConnectivityResult> event)?);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _connectivityResult = result;
    });

    if (_connectivityResult == ConnectivityResult.none) {
      _showNoConnectionDialog();
    }
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _checkConnectivity();
              },
              child: Text('Retry', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Close the app
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Text('Exit', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Treat Budget',
      initialRoute: '/splash',
      getPages: Routes.routes,
    );
  }
}
