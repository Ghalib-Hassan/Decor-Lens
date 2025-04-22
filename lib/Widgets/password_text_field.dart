import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PasswordTextField extends StatefulWidget {
  String labelText;
  double? borderRadius;
  TextEditingController? myController;
  String? Function(String?)? validator;
  TextInputType? keyboardType;

  PasswordTextField(
      {super.key,
      required this.labelText,
      this.borderRadius,
      this.myController,
      this.validator,
      this.keyboardType});

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  void obscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Theme(
      data: ThemeData.light(), // Force light mode on this screen
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: TextStyle(color: black, fontSize: screenHeight * 0.02),
        obscureText: _obscureText,
        controller: widget.myController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          errorStyle: TextStyle(
            fontSize:
                screenHeight * 0.015, // Dynamic font size for the error message
            color: red, // Error text color
          ),
          labelText: widget.labelText,
          labelStyle: TextStyle(
            fontSize: screenHeight * 0.018,
            color: black,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              color: grey,
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: obscure,
          ),
        ),
      ),
    );
  }
}
