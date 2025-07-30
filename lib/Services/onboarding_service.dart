import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decor_lens/UI/Admin%20UI/admin_homepage.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/UI/Onboarding%20Screens/onboarding_1.dart';
import 'package:decor_lens/UI/User%20UI/home_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OnboardingService extends StatefulWidget {
  const OnboardingService({super.key});

  @override
  State<OnboardingService> createState() => _OnboardingServiceState();
}

class _OnboardingServiceState extends State<OnboardingService> {
  bool isWeakNetwork = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      // No internet at all
      return;
    }

    // Timer to detect weak network
    Timer(const Duration(seconds: 60), () {
      if (mounted) {
        setState(() {
          isWeakNetwork = true;
        });
      }
    });

    // Try pinging Google to check if internet is really active
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _navigateUser();
      }
    } on SocketException catch (_) {
      // Still no internet access
    } on TimeoutException {
      // Too slow to connect
    }
  }

  void _navigateUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    try {
      // ✅ Not logged in → Login Screen
      if (user == null) {
        Get.offAll(() => OnboardingScreenOne(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));
        return;
      }

      // ✅ Admin Check
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admin Credentials')
          .doc('admin_id')
          .get();

      final adminEmail = adminDoc.data()?['email']?.toString().trim();
      if (adminEmail != null && user.email == adminEmail) {
        Get.offAll(() => const AdminHomePage(),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 1));
        return;
      }

      // ✅ Regular User Check
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);
      final userDoc = await userDocRef.get();

      // ✅ If document doesn't exist → treat as first login
      if (!userDoc.exists) {
        await userDocRef.set({'isFirstLogin': false}, SetOptions(merge: true));

        Get.offAll(() => const OnboardingScreenOne(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));
        return;
      }

      // ✅ If document exists, check first login flag
      final isFirstLogin = userDoc.data()?['isFirstLogin'] ?? true;

      if (isFirstLogin == true) {
        await userDocRef.update({'isFirstLogin': false});

        Get.offAll(() => const OnboardingScreenOne(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));
        return;
      }

      // ✅ Returning user → Home Screen
      Get.offAll(() => const HomeScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800));
    } catch (e) {
      debugPrint('⚠️ Navigation error: $e');

      // ✅ Safe fallback → Login or Home depending on auth
      if (auth.currentUser == null) {
        Get.offAll(() => UserLogin(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));
      } else {
        Get.offAll(() => const HomeScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 0.5,
            child: Lottie.asset("assets/Lottie/LottieAnimationSec.json"),
          ),
          if (isWeakNetwork) ...[
            const SizedBox(height: 20),
            Text(
              'Internet connection is weak. Please wait...',
              style: TextStyle(color: red),
            ),
          ]
        ],
      ),
    );
  }
}
