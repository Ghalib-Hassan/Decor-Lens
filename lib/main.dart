import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Provider/home_screen_provider.dart';
import 'package:decor_lens/Provider/product_screen_provider.dart';
import 'package:decor_lens/Services/onboarding_service.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// List to store notifications (No duplicates)
Set<String> notificationIds = {}; // Stores unique notification IDs
List<Map<String, String>> notifications = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = AppConstants.stripePublishableKey;
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Handle Foreground Firebase Notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("🔔 Foreground Firebase Notification received");

    if (message.notification != null) {
      // String title = message.notification!.title ?? 'No Title';
      // String body = message.notification!.body ?? 'No Body';

      // saveNotificationToFirestore(title, body);
      debugPrint("Title: ${message.notification!.title}");
      debugPrint("Body: ${message.notification!.body}");

      // Update UI
      Get.find<NotificationController>().updateNotifications();
    }
  });

  //Calling firebaseMessagingBackgroundHandler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Register DarkModeService before running the app
  Get.put(DarkModeService());

  // Register the NotificationController
  Get.put(NotificationController());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkModeService()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> saveNotificationToFirestore(String title, String body) async {
  String? notificationId = FirebaseAuth.instance.currentUser?.uid;
  if (notificationId == null) return;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference notificationsRef = firestore.collection('Notifications');

  // Step 1: Fetch all previous notifications for this user
  var allPrevious = await notificationsRef
      .where('notificationId', isEqualTo: notificationId)
      .get();

  // Step 2: Check for exact match (title + body) in ALL previous data
  bool isDuplicate = allPrevious.docs.any((doc) =>
      doc['title'].toString().trim() == title.trim() &&
      doc['body'].toString().trim() == body.trim());

  if (isDuplicate) {
    debugPrint("🚫 Duplicate notification found. Skipping save.");
    return;
  }

  // Step 3: Update 'latest' flag of previous "latest" notifications
  for (var doc in allPrevious.docs.where((doc) => doc['latest'] == "1")) {
    await doc.reference.update({'latest': "0"});
  }

  // Step 4: Add new notification with latest = "1"
  await notificationsRef.add({
    'notificationId': notificationId,
    'title': title.trim(),
    'body': body.trim(),
    'latest': "1",
    'timestamp': FieldValue.serverTimestamp(),
  });

  debugPrint("✅ New notification added: $title | $body");

  // Step 5: Update UI if controller is available
  try {
    Get.find<NotificationController>().updateNotifications();
  } catch (e) {
    debugPrint("⚠️ NotificationController not found: $e");
  }
}

//The bottom works when the app is running in background (When the user opened the app but the app is in background)
Set<String> receivedNotificationIds = {}; // Track received notification IDs
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.messageId != null &&
      receivedNotificationIds.contains(message.messageId)) {
    debugPrint(
        "🚨 Skipping duplicate background notification: ${message.messageId}");
    return; // Prevent duplicate processing
  }

  receivedNotificationIds.add(message.messageId!);
  debugPrint("🔔 Background notification received");

  if (message.notification != null) {
    String title = message.notification!.title ?? 'No Title';
    String body = message.notification!.body ?? 'No Body';

    await saveNotificationToFirestore(title, body);
    debugPrint("Title: ${message.notification!.title}");
    debugPrint("Body: ${message.notification!.body}");

    // Update UI once
    Get.find<NotificationController>().updateNotifications();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  initState() {
    super.initState();
    subscribeToTopic(); // Subscribe to the topic when the app starts
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkModeService()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Decor Lens',
        theme: darkModeService.isDarkMode
            ? ThemeData.dark().copyWith(
                scaffoldBackgroundColor: black,
              )
            : ThemeData.light(),
        home: const OnboardingService(),
      ),
    );
  }

  void subscribeToTopic() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic('all_users');
    print('subscribe to all topic');
  }
}

// Controller to update notifications
class NotificationController extends GetxController {
  void updateNotifications() {
    update(); // Triggers UI refresh
  }
}
