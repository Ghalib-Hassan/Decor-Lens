import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void customSnackbar({
  String? title,
  String? message,
  Color titleColor = Colors.black,
  Color messageColor = Colors.black,
  Color? backgroundColor = Colors.white,
  IconData? icon,
  Color iconColor = Colors.yellow,
}) {
  final defaultTitle = title ?? (message == null ? "Alert" : "");
  final defaultMessage = message ?? "";

  // Final icon widget if provided
  final Widget? iconWidget = icon != null
      ?
      //     ? Container(
      //         padding: const EdgeInsets.all(6),
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           color: iconColor.withOpacity(0.15),
      //         ),
      //         child: Center(
      //           child:
      Icon(
          icon,
          size: 24,
          color: iconColor,
        )
      //         ),
      //       )
      : null;

  Get.snackbar(
    defaultTitle,
    defaultMessage,
    snackPosition: SnackPosition.TOP,
    backgroundColor: backgroundColor ?? white.withOpacity(.5),
    borderRadius: 16,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    padding: const EdgeInsets.all(16),
    icon: iconWidget != null
        ? Padding(
            padding: const EdgeInsets.only(
                left: 8.0), // Adds space between the icon and the left border
            child: iconWidget,
          )
        : null,
    shouldIconPulse: false,
    duration: const Duration(seconds: 3),
    boxShadows: [
      BoxShadow(
        color: black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
    titleText: defaultTitle.isNotEmpty
        ? Text(
            defaultTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          )
        : null,
    messageText: defaultMessage.isNotEmpty
        ? Text(
            defaultMessage,
            style: TextStyle(
              fontSize: 14,
              color: messageColor,
            ),
          )
        : null,
    isDismissible: true,
    snackStyle: SnackStyle.FLOATING,
    animationDuration: const Duration(milliseconds: 700),
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeIn,
  );
}
