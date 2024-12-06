import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/services/notifications/notification_services.dart';

import 'constants/colors.dart';
import 'constants/firebase_consts.dart';
import 'firebase_options.dart';
import 'screens/home.dart';
import 'screens/login_screen.dart';

Future<void> _handleBackgroundNotification(RemoteMessage message) async {
  print('Handling Background');
}
NotificationServices notificationServices=NotificationServices();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  await notificationServices.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return const Home();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return const LoginScreen();
      },
    ),
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: mobileBackgroundColor,
    ),
  ));
}
