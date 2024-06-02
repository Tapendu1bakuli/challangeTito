import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/languages/LocalizationService.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/LocalNotification.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/BottomTextWidget.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PermissionStatus? _cameraPermission;
  PermissionStatus? _micPermission;
  bool permissionsCompleted = false;
  PermissionStatus? _notificationsPermission;
  PermissionStatus? _mediaPermission;

  String token = "";
  String language = "";
  var localStorage = new LocalHiveStorage();

  @override
  void initState() {
    setState(() {
      language = HiveStore().get(Keys.language) ?? "English";
      print("language $language");
      LocalizationService().changeLocale(language);
    });
    super.initState();
    flutterLocalNotificationsPlugin.cancelAll();
    if (Platform.isIOS) {
      firebasesetupios();
    }
    displayPermissionRequests();
    gotoScreen();
  }

  firebasesetupios() async {
    if (Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      Firebase.initializeApp();
      FirebaseMessaging.instance.requestPermission();
      var initSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var iOS = IOSInitializationSettings();
      var initializationSettings =
          InitializationSettings(android: initSettingsAndroid, iOS: iOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings);
      FirebaseMessaging.instance.requestPermission();
      final prefs2 = await HiveStore.getInstance();
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        flutterLocalNotificationsPlugin.cancelAll();
        Timer(Duration(seconds: 3), () async {
          final HiveStore prefs = await HiveStore.getInstance();
          if (prefs.getBool('logged_in') == true) {
            Navigator.pushNamed(context, '/Home');
          } else {
            Navigator.pushReplacementNamed(context, '/Login');
          }
        });
      });
      var prefs = await HiveStore.getInstance();
      token = (await FirebaseMessaging.instance.getToken())!;

      // localStorage.updateValue("token", token);
      prefs.setString("notificationtoken", token);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = LocalNotification("new");
        NotificationsBloc.instance.newNotification(notification);
      });

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    //iOS-specific code
  }

  firebasesetupand() async {}

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'],
        message.data['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              styleInformation: BigTextStyleInformation("")),
        ));

    final notification = LocalNotification("new");
    NotificationsBloc.instance.newNotification(notification);
  }

  void displayPermissionRequests() async {
    await requestCameraPermission();
    await requestMicPermission();
    await requestNotificationsPermission();
    await requestFileAccessPermission();
    if (mounted)
      setState(() {
        permissionsCompleted = true;
      });
    // await HiveStore().initBox();
    //HiveStore().clear();
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();

    setState(() {
      _cameraPermission = status;
    });
  }

  Future<void> requestMicPermission() async {
    var status = await Permission.microphone.request();
    if (mounted)
      setState(() {
        _micPermission = status;
      });
  }

  Future<void> requestNotificationsPermission() async {
    var status = await Permission.notification.request();
    if (mounted)
      setState(() {
        _notificationsPermission = status;
      });
  }

  Future<void> requestFileAccessPermission() async {
    var status = await Permission.storage.request();
    if (mounted)
      setState(() {
        _mediaPermission = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: CustomColor.myCustomYellow,
            ),
            BottomTextWidget(),
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 1.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/logo.png"),
                  // fit: BoxFit.fitWidth,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> gotoScreen() async {
    bool isLoggedin = await localStorage.autoLogIn();

    Timer(Duration(seconds: 5), () async {
      if (isLoggedin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/Home',
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/LanguageSelectionScreen',
          (route) => false,
        );
      }
    });
  }
}
