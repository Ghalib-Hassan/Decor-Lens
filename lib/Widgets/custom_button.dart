import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  double? buttonWidth;
  double? buttonHeight;
  String buttonText;
  Color? buttonColor;
  Color? textColor;
  double? buttonRadius;
  double? buttonFontSize;
  FontWeight? buttonFontWeight;
  BorderSide? buttonBorder;
  TextStyle? fonts;
  Function onPressed;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool isLoading;
  final double? loadingSize;

  CustomButton(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      this.buttonColor,
      this.buttonFontSize,
      this.buttonFontWeight,
      this.buttonHeight,
      this.buttonRadius,
      this.buttonWidth,
      this.textColor,
      this.horizontalPadding,
      this.verticalPadding,
      this.fonts,
      this.buttonBorder,
      this.loadingSize,
      this.isLoading = false});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.buttonWidth ?? 20,
      height: widget.buttonHeight ?? 5,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.3), // Shadow color
            offset: Offset(0, 10), // Shadow position
            blurRadius: 20, // Spread of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(widget.buttonRadius ?? 8.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor ?? appColor,
          padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding ?? 5,
              vertical: widget.verticalPadding ?? 3),
          shape: RoundedRectangleBorder(
            side: widget.buttonBorder ?? BorderSide(color: appColor),
            borderRadius: BorderRadius.all(
              Radius.circular(widget.buttonRadius ?? 8.0),
            ),
          ),
        ),
        onPressed: () => widget.onPressed(),
        child: widget.isLoading
            ? LoadingAnimationWidget.stretchedDots(
                color: white,
                size: widget.loadingSize ?? 30,
              )
            : Text(
                widget.buttonText,
                style: widget.fonts ??
                    GoogleFonts.gelasio(
                      color: widget.textColor ?? white,
                      fontSize: widget.buttonFontSize?.toDouble() ?? 12,
                      fontWeight: widget.buttonFontWeight ?? FontWeight.w600,
                    ),
              ),
      ),
    );
  }
}
