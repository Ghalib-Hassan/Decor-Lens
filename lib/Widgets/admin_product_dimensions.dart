import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildDimensionField(BuildContext context, String label, String hint,
    TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0, left: 40, right: 40),
    child: TextField(
      style: GoogleFonts.poppins(
          color: black.withOpacity(.8),
          fontSize: MediaQuery.of(context).size.height * 0.015),
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: GoogleFonts.poppins(
            color: black.withOpacity(.8),
            fontSize: MediaQuery.of(context).size.height * 0.015),
        labelStyle: GoogleFonts.poppins(
            color: black.withOpacity(.8),
            fontSize: MediaQuery.of(context).size.height * 0.015),
        hintText: hint,
        suffixText: "cm",
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: black)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: black)),
      ),
    ),
  );
}
