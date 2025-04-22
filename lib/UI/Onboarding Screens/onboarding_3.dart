import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/onboarding_bottom_clipper.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreenThree extends StatefulWidget {
  const OnboardingScreenThree({super.key});

  @override
  State<OnboardingScreenThree> createState() => _OnboardingScreenThreeState();
}

class _OnboardingScreenThreeState extends State<OnboardingScreenThree> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Container (Expanded for better responsiveness)
          Expanded(
            child: ClipPath(
              clipper: BottomRoundedClipper(), // Custom Clipper
              child: Image.asset(
                'assets/images/beds/bed4.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Title Text
          Text(
            'Get Support From Our Skilled Team',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: black.withOpacity(.7),
            ),
          ),
          const SizedBox(height: 15),

          // Subtitle Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'If your products don\'t meet your expectations, we are available 24/7 to assist you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: blueGrey,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Indicator Dots (Refactored with List.generate)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: index == 2 ? 12 : 10, // Highlight the third dot
                height: index == 2 ? 12 : 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: index == 2 ? teal : grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 25),

          // Buttons (Back & Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    color: teal,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 40),

              // Next Button
              CustomButton(
                buttonColor: appColor,
                buttonWidth: ScreenSize.screenWidth * 0.6,
                buttonHeight: ScreenSize.screenHeight * 0.06,
                fonts: GoogleFonts.nunitoSans(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenSize.screenHeight * 0.018,
                ),
                buttonText: 'Next',
                isLoading: isLoading,
                onPressed: () {
                  // Implement Navigation to Login Screen or Home Screen
                  Get.offAll(() => UserLogin(),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 700));
                },
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
