import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/home_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SuccessOrder extends StatelessWidget {
  final String orderId;

  SuccessOrder({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 100, color: green),
              SizedBox(height: 20),
              Text(
                "Order Placed Successfully!",
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? white : black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Your order ID is:",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                orderId,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: blueGrey,
                ),
              ),
              SizedBox(height: 30),
              CustomButton(
                buttonText: "Continue Shopping",
                buttonColor: isDarkMode ? white : appColor,
                fonts: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? black : white,
                ),
                buttonHeight: 50,
                buttonWidth: double.infinity,
                onPressed: () => Get.offAll(() => HomeScreen(),
                    transition: Transition.fadeIn,
                    duration: 600.ms), // navigate to home screen
              ),
            ],
          ),
        ),
      ),
    );
  }
}
