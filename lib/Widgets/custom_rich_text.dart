import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRichText extends StatelessWidget {
  final String label; // The bold text
  final String value; // The regular text
  final double fontSize; // Text size
  final Color color; // Text color
  final TextStyle? labelFonts;
  final TextStyle? textFonts;

  CustomRichText({
    super.key,
    this.color = Colors.black,
    required this.label,
    required this.value,
    this.fontSize = 16.0,
    this.labelFonts,
    this.textFonts,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$label: ',
        style: labelFonts ??
            GoogleFonts.mPlusRounded1c(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: fontSize,
            ),
        children: [
          TextSpan(
            text: value,
            style: textFonts ??
                GoogleFonts.mPlusCodeLatin(
                  fontWeight: FontWeight.normal,
                  color: color,
                  fontSize: fontSize,
                ),
          ),
        ],
      ),
    );
  }
}
