import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AdminItemService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<String>> fetchAllFCMTokens() async {
    List<String> tokens = [];

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('LoggedInUsers').get();
    for (var doc in snapshot.docs) {
      String? token = doc['fcm_token'];
      if (token != null && token.isNotEmpty) {
        tokens.add(token);
      }
    }

    return tokens;
  }

  Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
    required List<String> tokens,
  }) async {
    const String serverKey =
        'a84f5e83085e6acb8db573a22739432e7a4dc314a72c6d3001fb937f0f6142ad278aebd4c708b8a3'; // Replace with your Firebase server key
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    for (String token in tokens) {
      var notificationData = {
        "to": token,
        "notification": {
          "title": title,
          "body": body,
          "sound": "default",
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
        },
      };

      await http.post(
        Uri.parse(fcmUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode(notificationData),
      );
      print('sended');
    }
  }

  Future<void> addItem({
    required String itemName,
    required String category,
    required String itemDescription,
    required String itemPrice,
    required String deliveryPrice,
    required List<File?> images,
    required File? glbFile,
    required String height,
    required String width,
    required String space,
    required BuildContext context,
  }) async {
    try {
      List<String> imageUrls = [];

      for (var i = 0; i < 5; i++) {
        if (images[i] != null) {
          var uploadUri = Uri.parse(
              "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/image/upload");
          var request = http.MultipartRequest('POST', uploadUri);

          request.files
              .add(await http.MultipartFile.fromPath('file', images[i]!.path));
          request.fields['upload_preset'] = "admin_upload_preset";

          var response = await request.send();
          var responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(responseBody);
            imageUrls.add(jsonResponse['secure_url']);
          } else {
            throw Exception('Failed to upload image ${i + 1}');
          }
        }
      }

      String? modelUrl;
      if (glbFile != null) {
        var uploadUri = Uri.parse(
            "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/raw/upload");
        var request = http.MultipartRequest('POST', uploadUri);

        request.files
            .add(await http.MultipartFile.fromPath('file', glbFile.path));
        request.fields['upload_preset'] = "admin_upload_preset";

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(responseBody);
          modelUrl = jsonResponse['secure_url'];
        } else {
          throw Exception('Failed to upload 3D model');
        }
      }

      String id = DateTime.now().millisecondsSinceEpoch.toString();
      await db.collection('Items').doc(id).set({
        'Id': id,
        'ItemName': capitalizeFirstLetter(itemName),
        'Category': category,
        'ItemDescription': itemDescription,
        'ItemPrice': itemPrice,
        'Images': imageUrls,
        'Model': modelUrl!.isEmpty ? null : modelUrl,
        'Height': height,
        'Width': width,
        'Space': space,
        'Delivery_amount': deliveryPrice,
      });

      // Fetch all logged-in users' FCM tokens
      print('sending');
      // List<String> tokens = await fetchAllFCMTokens();

      // // Send push notification
      // await sendNotificationToAllUsers(
      //   title: "New Item Added!",
      //   body: "${itemName.text.trim()} is now available. Check it out!",
      //   tokens: tokens,
      // );

      customSnackbar(
        title: 'Success',
        message: 'Item added successfully',
        messageColor: black,
        titleColor: green,
        icon: Icons.check_circle_outline,
        iconColor: green,
        backgroundColor: white,
      );

      Navigator.pop(context);

      //  SendNotificationService.sendNotificationUsingApi(
      //   topic: "all",
      //                         title: " New Item added",
      //                         body: "notify body",
      //                         data: {'screens': 'cart'});
      // Future<List<String>> fetchAllFCMTokens() async {
      //   QuerySnapshot usersSnapshot =
      //       await FirebaseFirestore.instance.collection('LoggedIn Users').get();

      //   List<String> tokens = [];

      //   for (var doc in usersSnapshot.docs) {
      //     var data = doc.data() as Map<String, dynamic>;
      //     if (data.containsKey('fcm_Token')) {
      //       tokens.add(data['fcmToken']);
      //     }
      //   }

      //   return tokens;
      // }

      // Fetch all logged-in users' FCM tokens
      // ignore: unused_local_variable
      // List<String> tokens = await fetchAllFCMTokens();

      // Send notification to each token
      // for (String token in tokens) {
      // await SendNotificationService.sendNotificationUsingApi(
      //   // token: token,
      //   topic: 'all',
      //   title: "New Item Added!",
      //   body: "${itemName.text.trim()} is now available. Check it out!",
      //   data: {'screen': 'ProductScreen'},
      // );

      // await saveNotificationToFirestore("New Item Added!",
      //     "${itemName.text.trim()} is now available. Check it out!");

      print('notification sent');
      // }
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Error adding item: $e',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    }
  }

  Future<void> addCustomItem({
    required String itemName,
    required String itemDescription,
    required String itemPrice,
    required String deliveryPrice,
    required List<File?> images,
    required File? glbFile,
    required BuildContext context,
  }) async {
    try {
      List<String> imageUrls = [];

      for (var i = 0; i < 5; i++) {
        if (images[i] != null) {
          var uploadUri = Uri.parse(
              "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/image/upload");
          var request = http.MultipartRequest('POST', uploadUri);

          request.files
              .add(await http.MultipartFile.fromPath('file', images[i]!.path));
          request.fields['upload_preset'] = "admin_upload_preset";

          var response = await request.send();
          var responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(responseBody);
            imageUrls.add(jsonResponse['secure_url']);
          } else {
            throw Exception('Failed to upload image ${i + 1}');
          }
        }
      }

      String? modelUrl;
      if (glbFile != null) {
        var uploadUri = Uri.parse(
            "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/raw/upload");
        var request = http.MultipartRequest('POST', uploadUri);

        request.files
            .add(await http.MultipartFile.fromPath('file', glbFile.path));
        request.fields['upload_preset'] = "admin_upload_preset";

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(responseBody);
          modelUrl = jsonResponse['secure_url'];
        } else {
          throw Exception('Failed to upload 3D model');
        }
      }

      String id = DateTime.now().millisecondsSinceEpoch.toString();
      await db.collection('Items').doc(id).set({
        'Id': id,
        'ItemName': capitalizeFirstLetter(itemName),
        'Category': 'Custom',
        'ItemDescription': itemDescription,
        'ItemPrice': itemPrice,
        'Images': imageUrls,
        'Model': modelUrl,
        'Height': "", // Store dimensions for 3D model
        'Width': "", // Store dimensions for 3D model
        'Space': "", // Store dimensions for 3D model
        'Delivery_amount': deliveryPrice,
      });

      // Fetch all logged-in users' FCM tokens
      print('sending');
      // List<String> tokens = await fetchAllFCMTokens();

      // // Send push notification
      // await sendNotificationToAllUsers(
      //   title: "New Item Added!",
      //   body: "${itemName.text.trim()} is now available. Check it out!",
      //   tokens: tokens,
      // );

      customSnackbar(
        title: 'Success',
        message: 'Item added successfully',
        messageColor: black,
        titleColor: green,
        icon: Icons.check_circle_outline,
        iconColor: green,
        backgroundColor: white,
      );

      Navigator.pop(context);

      //  SendNotificationService.sendNotificationUsingApi(
      //   topic: "all",
      //                         title: " New Item added",
      //                         body: "notify body",
      //                         data: {'screens': 'cart'});
      // Future<List<String>> fetchAllFCMTokens() async {
      //   QuerySnapshot usersSnapshot =
      //       await FirebaseFirestore.instance.collection('LoggedIn Users').get();

      //   List<String> tokens = [];

      //   for (var doc in usersSnapshot.docs) {
      //     var data = doc.data() as Map<String, dynamic>;
      //     if (data.containsKey('fcm_Token')) {
      //       tokens.add(data['fcmToken']);
      //     }
      //   }

      //   return tokens;
      // }

      // Fetch all logged-in users' FCM tokens
      // ignore: unused_local_variable
      // List<String> tokens = await fetchAllFCMTokens();

      // Send notification to each token
      // for (String token in tokens) {
      // await SendNotificationService.sendNotificationUsingApi(
      //   // token: token,
      //   topic: 'all',
      //   title: "New Item Added!",
      //   body: "${itemName.text.trim()} is now available. Check it out!",
      //   data: {'screen': 'ProductScreen'},
      // );

      // await saveNotificationToFirestore("New Item Added!",
      //     "${itemName.text.trim()} is now available. Check it out!");

      print('notification sent');
      // }
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Error adding item: $e',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    }
  }

  static Future<void> updateItem({
    required BuildContext context,
    required String itemId,
    required String name,
    required String description,
    required String price,
    required List<String> imageUrls,
    required String glbFileUrl,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Items').doc(itemId).update({
        'ItemName': name,
        'ItemDescription': description,
        'ItemPrice': price,
        'Images': imageUrls,
        'Model': glbFileUrl,
        'Height': "",
        'Width': "",
        'Space': "",
      });

      customSnackbar(
        title: 'Success',
        message: 'Item updated successfully!',
        messageColor: black,
        titleColor: green,
        icon: Icons.check_circle,
        iconColor: green,
        backgroundColor: white,
      );
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Failed to update item: $e',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    }
  }
}
