import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EmailTextField extends StatefulWidget {
  String? labelText;
  String? hintText;
  double? borderRadius;
  TextEditingController? myController;
  String? Function(String?)? validator;
  TextInputType? keyboardType;

  EmailTextField(
      {super.key,
      this.labelText,
      this.hintText,
      this.borderRadius,
      this.myController,
      this.validator,
      this.keyboardType});

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Theme(
      data: ThemeData.light(), // Force light mode on this screen
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextFormField(
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: TextStyle(color: black, fontSize: screenHeight * 0.02),
          controller: widget.myController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorStyle: TextStyle(
                fontSize: screenHeight *
                    0.015, // Dynamic font size for the error message
                color: red, // Error text color
              ),
              labelText: widget.labelText,
              hintText: widget.hintText,
              labelStyle: TextStyle(
                fontSize: screenHeight * 0.02,
                color: black,
              ),
              prefixIcon: Icon(Icons.email_outlined)),
        ),
      ),
    );
  }
}
