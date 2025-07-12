import 'dart:async';
import 'package:decor_lens/Services/onboarding_service.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => OnboardingService(), transition: Transition.fade);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    return Scaffold(
      backgroundColor: appColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/home.svg',
              height: ScreenSize.screenHeight * 0.09,
              colorFilter: ColorFilter.mode(white, BlendMode.srcATop),
            ),
            Text(
              'Decor Lens',
              style: TextStyle(
                  fontSize: 35, color: white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
