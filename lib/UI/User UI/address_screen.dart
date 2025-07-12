import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/add_address.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Address Screen
class AddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Your Addresses",
              showLeading: true,
              fontColor: isDarkMode ? white : black,
              leadingIconColor: isDarkMode ? white : black,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      floatingActionButton: CustomButton(
          buttonColor: isDarkMode ? white : appColor,
          buttonHeight: ScreenSize.screenHeight * 0.06,
          buttonWidth: ScreenSize.screenWidth * 0.92,
          fonts: GoogleFonts.manrope(
              color: isDarkMode ? black : white, fontWeight: FontWeight.bold),
          buttonText: 'Add Address',
          onPressed: () {
            Get.to(() => AddAddressScreen(),
                transition: Transition.rightToLeft, duration: 500.ms);
          }).animate().scale(duration: 300.ms),
    );
  }
}
