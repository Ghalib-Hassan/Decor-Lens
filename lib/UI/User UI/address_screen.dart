import 'package:decor_lens/UI/User%20UI/add_address.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Address Screen
class AddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Your Addresses",
              showLeading: true,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      floatingActionButton: CustomButton(
        buttonHeight: ScreenSize.screenHeight * 0.06,
        buttonWidth: ScreenSize.screenWidth * 0.92,
        fonts: GoogleFonts.manrope(color: white, fontWeight: FontWeight.bold),
        buttonText: 'Add Address',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddAddressScreen())),
      ).animate().scale(duration: 300.ms),
    );
  }
}
