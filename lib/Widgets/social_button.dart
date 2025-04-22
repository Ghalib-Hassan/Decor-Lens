import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialButton extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final String text;
  final VoidCallback onPressed;

  const SocialButton({
    this.imagePath,
    this.icon,
    this.iconColor,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: grey.withOpacity(.3)),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            SvgPicture.asset(
              imagePath!,
              height: 25,
            )
          else if (icon != null)
            Icon(icon, color: iconColor, size: 25),
          SizedBox(width: 10),
          Text(text,
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: black.withOpacity(.8),
                  fontSize: 15)),
        ],
      ),
    );
  }
}
