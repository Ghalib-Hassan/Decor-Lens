import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> kOnExitConfirmation() async {
  bool shouldExit = false;
  await kDefaultDialog(
    "Exit",
    "Are you sure you want to exit the app?",
    onYesPressed: () {
      shouldExit = true;
      if (Platform.isAndroid || Platform.isIOS) {
        exit(0); // Fully terminates the app
      } else {
        SystemNavigator.pop(); // Just in case for other platforms
      }
    },
  );
  return shouldExit;
}

Future kDefaultDialog(String title, String message,
    {VoidCallback? onYesPressed}) async {
  if (GetPlatform.isIOS) {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
            },
            child: Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: onYesPressed,
            child: Text("Yes"),
          ),
        ],
      ),
    );
  } else {
    await Get.dialog(
      Theme(
        data: ThemeData.light(),
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: onYesPressed,
              child: Text("Yes"),
            ),
          ],
        ),
      ),
    );
  }
}
