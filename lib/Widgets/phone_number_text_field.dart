import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneNumberTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: Text(
              '+92',
              style: GoogleFonts.poppins(fontSize: 16, color: black),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: GoogleFonts.poppins(color: black),
              decoration: InputDecoration(
                counterText: '',
                labelText: 'Phone Number',
                labelStyle: GoogleFonts.poppins(color: black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.phone_android, color: grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
