import 'package:decor_lens/UI/Onboarding%20Screens/onboarding_3.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/onboarding_bottom_clipper.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreenTwo extends StatefulWidget {
  const OnboardingScreenTwo({super.key});

  @override
  State<OnboardingScreenTwo> createState() => _OnboardingScreenTwoState();
}

class _OnboardingScreenTwoState extends State<OnboardingScreenTwo> {
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
                'assets/images/tables/table1.jpg',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Title Text
          Text(
            'Delivery Right to Your Doorstep',
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
              'Sit back, and enjoy the convenience of our drivers delivering your order to your doorstep.',
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
                width: index == 1 ? 12 : 10, // Highlight the second dot
                height: index == 1 ? 12 : 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: index == 1 ? teal : grey,
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
                  style: GoogleFonts.manrope(
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
                onPressed: () {
                  // Implement Navigation to Next Screen
                  Get.to(() => OnboardingScreenThree(),
                      transition: Transition.rightToLeft);
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
