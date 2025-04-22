import 'dart:ui';

import 'package:decor_lens/UI/Onboarding%20Screens/onboarding_2.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/onboarding_bottom_clipper.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipPath(
              clipper: BottomRoundedClipper(), // Custom Clipper
              child: Image.asset(
                'assets/images/chairs/chair4.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Online Home Store and Furniture',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: black.withOpacity(.7),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Discover all styles and budgets of furniture, appliances, kitchens, and more from 500+ brands in your hand.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: blueGrey,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: index == 0 ? 12 : 10, // Make first dot slightly larger
                height: index == 0 ? 12 : 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: index == 0 ? teal : grey,
                ),
              );
            }),
          ),

          const SizedBox(height: 25),

          CustomButton(
            buttonColor: appColor.withOpacity(.7),
            buttonWidth: ScreenSize.screenWidth * 0.9,
            buttonHeight: ScreenSize.screenHeight * 0.06,
            fonts: GoogleFonts.manrope(
              color: white,
              fontWeight: FontWeight.bold,
              fontSize: ScreenSize.screenHeight * 0.018,
            ),
            buttonText: 'Next',
            isLoading: isLoading,
            onPressed: () {
              // Implement Navigation
              Get.to(() => OnboardingScreenTwo(),
                  transition: Transition.rightToLeft);
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
