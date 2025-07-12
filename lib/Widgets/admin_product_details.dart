import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildUploadHint(
    {required IconData icon, required String text, required double height}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: black, size: height * 0.04),
        SizedBox(height: 8),
        Text(text,
            style: GoogleFonts.ubuntuCondensed(
              color: black,
              fontSize: height * 0.02,
            )),
      ],
    ),
  );
}

Widget buildTextField(
    TextEditingController controller, String hint, double height,
    {int? maxLines = 1, int? maxLength}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.poppins(fontSize: height * 0.02),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: height * 0.02, color: black.withOpacity(.6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

Widget buildPriceField(
    TextEditingController controller, String hint, double height) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(fontSize: height * 0.02),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: height * 0.02, color: Colors.black.withOpacity(.6)),
        suffixText: 'Rs',
        suffixStyle:
            GoogleFonts.poppins(fontSize: height * 0.02, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
