import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:decor_lens/UI/User%20UI/notification_screen.dart';
import 'package:decor_lens/main.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//The bottom works when the app is in running state (When the user is using the app, only then he could receive the notification)
class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User denied permission');
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint(message.notification!.title.toString());
        debugPrint(message.notification!.body.toString());
        debugPrint(message.data.toString());
        debugPrint(message.data['type']);
        debugPrint(message.data['id']);
      }
      if (message.notification != null) {
        // Display the banner while the app is open
        initLocalNotifications(context, message);
        showNotification(message);
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
      if (Platform.isIOS) {
        iosForegrounMessage();
      } else {
        showNotification(message);
      }
    });
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    //for IOS
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      debugPrint("📲 Notification tapped: ${message.notification!.title}");

      handleMessage(context, message);
    });
  }

  Future iosForegrounMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importance Notifications',
        importance: Importance.max,
        showBadge: true,
        playSound: true);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            playSound: true,
            channelShowBadge: true,
            sound: channel.sound);

    //For IOS
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    //merge settings
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    //show notification
    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: "all_users");
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    print("Token ➡️ $token");
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      debugPrint('Token refreshed');
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) async {
    debugPrint("📩 Handling message: ${message.data}");

    // Ensure message has data before navigating
    if (message.data.isNotEmpty && message.data['type'] == 'message' ||
        message.data['id'] == '123456') {
      String title = message.notification!.title ?? 'No Title';
      String body = message.notification!.body ?? 'No Body';

      await saveNotificationToFirestore(title, body);
      debugPrint("Title: ${message.notification!.title}");
      debugPrint("Body: ${message.notification!.body}");

      Get.to(() => NotificationScreen(),
          transition: Transition.fadeIn, duration: Duration(milliseconds: 500));
    } else if (message.data['screen'] == 'notifictaion') {
      Get.to(() => NotificationScreen(),
          transition: Transition.fadeIn, duration: Duration(milliseconds: 500));
    } else {
      debugPrint("🚨 Skipping navigation: No valid data found in message.");
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    //When app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.data.isNotEmpty) {
        handleMessage(context, initialMessage);
      } else {
        debugPrint("🚨 Skipping initial message: No valid data.");
      }
    }

    //When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.data.isNotEmpty) {
        handleMessage(context, event);
      } else {
        debugPrint("🚨 Skipping background message: No valid data.");
      }
    });
  }
}
