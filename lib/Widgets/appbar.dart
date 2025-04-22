import 'package:decor_lens/Utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppbar extends StatelessWidget {
  final String title;
  final TextStyle? textStyle;
  final bool showLeading;

  const MyAppbar({
    super.key,
    required this.title,
    this.textStyle,
    this.showLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return AppBar(
      centerTitle: true,
      leading: showLeading
          ? GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.arrow_back_ios_new),
            )
          : null,
      title: Text(
        title,
        style: textStyle ??
            GoogleFonts.manrope(
              fontSize: ScreenSize.screenHeight * 0.03,
              fontWeight: FontWeight.bold,
            ),
      ),
      elevation: 0, // Remove the elevation shadow
    );
  }
}
