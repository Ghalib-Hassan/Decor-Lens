import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRichText extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  final Color color;
  final TextStyle? labelFonts;
  final TextStyle? textFonts;
  final double spacing;

  const CustomRichText({
    super.key,
    required this.label,
    required this.value,
    this.fontSize = 16.0,
    this.color = Colors.black,
    this.labelFonts,
    this.textFonts,
    this.spacing = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      color: color.withOpacity(0.95),
    );

    final defaultValueStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      color: color.withOpacity(0.8),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: labelFonts ?? defaultLabelStyle),
          Expanded(child: Text(value, style: textFonts ?? defaultValueStyle)),
        ],
      ),
    );
  }
}
