import 'package:decor_lens/Utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppbar extends StatelessWidget {
  final String title;
  final TextStyle? textStyle;
  final bool showLeading;
  final Color? fontColor;
  final Color? leadingIconColor;

  const MyAppbar(
      {super.key,
      required this.title,
      this.textStyle,
      this.showLeading = false,
      this.fontColor,
      this.leadingIconColor});

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: showLeading
          ? GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: leadingIconColor,
              ),
            )
          : null,
      title: Text(
        title,
        style: textStyle ??
            GoogleFonts.manrope(
              fontSize: ScreenSize.screenHeight * 0.03,
              fontWeight: FontWeight.bold,
              color: fontColor ?? Colors.black,
            ),
      ),
      elevation: 0, // Remove the elevation shadow
    );
  }
}
