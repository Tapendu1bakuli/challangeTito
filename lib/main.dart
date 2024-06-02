import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/languages/LocalizationService.dart';
import 'package:titosapp/screens/ForgotPassword.dart';
import 'package:titosapp/screens/LanguageSelectionScreen.dart';
import 'package:titosapp/screens/LoginScreen.dart';
import 'package:titosapp/screens/OTPScreen.dart';
import 'package:titosapp/screens/OTPVerified.dart';
import 'package:titosapp/screens/RegistrationScreen.dart';
import 'package:titosapp/screens/SplashScreen.dart';
import 'package:titosapp/screens/dashboard/ChangePassword.dart';
import 'package:titosapp/screens/dashboard/ChooseChallange.dart';
import 'package:titosapp/screens/dashboard/DashboardStep2Screen.dart';
import 'package:titosapp/screens/dashboard/EditProfile.dart';
import 'package:titosapp/screens/dashboard/HomeScreen.dart';
import 'package:titosapp/screens/dashboard/MyTickets.dart';
import 'package:titosapp/screens/dashboard/PaymentAccount.dart';
import 'package:titosapp/screens/video/StartRecording.dart';
import 'package:titosapp/screens/video/VideoSubmitted.dart';

List<CameraDescription> cameras = [];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title// description
    importance: Importance.high,
    showBadge: true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveStore().initBox();

  if (Platform.isIOS) {
    await FlutterStatusbarcolor.setStatusBarColor(Colors.black);
    if (useWhiteForeground(Colors.black)) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    }
  }
  Firebase.initializeApp();
  Permission.notification;
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    if (e.description != null) {
      print('Error: ${e.code}\nError Message: ${e.description}');
    } else {
      print('Error: ${e.code}');
    }
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,
      translations: LocalizationService(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.locales,
      routes: routes,
      initialRoute: '/Splash',
      title: 'TiTos',
      theme: ThemeData(
          primaryColor: Colors.yellow,
          colorScheme:
              ThemeData().colorScheme.copyWith(secondary: Colors.yellowAccent),
          fontFamily: "Calibri"),
      debugShowCheckedModeBanner: false,
    );
  }
}

var routes = <String, WidgetBuilder>{
  "/Splash": (BuildContext context) => SplashScreen(),
  "/Login": (BuildContext context) => LoginPage(),
  "/Register": (BuildContext context) => RegistrationScreen(),
  "/OTP": (BuildContext context) => OTPScreen(),
  "/OTPVerified": (BuildContext context) => OTPVerified(),
  "/Onboard": (BuildContext context) => DashboardStep2Screen(),
  "/Home": (BuildContext context) => HomeScreen(),
  "/ChooseChallenge": (BuildContext context) => ChooseChallenge(),
  "/StartRecording": (BuildContext context) => StartRecording(),
  "/PaymentAccount": (BuildContext context) => PaymentAccount(),
  //"/CameraScreen": (BuildContext context) => VideoRecording(),
  "/ForgotPasswordScreen": (BuildContext context) => ForgotPasswordScreen(),
  "/ChangePasswordScreen": (BuildContext context) => ChangePasswordScreen(),
  "/EditProfileScreen": (BuildContext context) => EditProfileScreen(),
  "/MyTickets": (BuildContext context) => MyTickets(),

  "/VideoSubmitted": (BuildContext context) => VideoSubmitted(),
  "/LanguageSelectionScreen": (BuildContext context) =>
      LanguageSelectionScreen(),
};
