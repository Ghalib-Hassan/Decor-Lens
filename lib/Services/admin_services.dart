import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Services/send_notification_service.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AdminItemService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addItem({
    required String itemName,
    required String category,
    required String itemDescription,
    required String itemPrice,
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
        'Model': modelUrl ?? '',
        'Height': height,
        'Width': width,
        'Space': space,
      });

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

      await SendNotificationService.sendNotificationUsingApi(
        // token: token,
        topic: 'all_users',
        title: "New Item Added!",
        body: "${itemName.trim()} is now available. Check it out!",
        data: {'screen': 'notification'},
      );
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
        'Model': modelUrl ?? '',
        'Height': "", // Store dimensions for 3D model
        'Width': "", // Store dimensions for 3D model
        'Space': "", // Store dimensions for 3D model
      });

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

      await SendNotificationService.sendNotificationUsingApi(
        // token: token,
        topic: 'all_users',
        title: "New Item Added!",
        body: "${itemName.trim()} is now available. Check it out!",
        data: {'screen': 'notification'},
      );
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
    required String height,
    required String width,
    required String space,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Items').doc(itemId).update({
        'ItemName': name,
        'ItemDescription': description,
        'ItemPrice': price,
        'Images': imageUrls,
        'Model': glbFileUrl,
        'Height': height,
        'Width': width,
        'Space': space,
      });

      // ✅ Now update favorite entries
      final favUsersSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Items')
          .where('ItemId', isEqualTo: itemId)
          .get();

      for (var favDoc in favUsersSnapshot.docs) {
        await favDoc.reference.update({
          'ItemName': name,
          'ItemDescription': description,
          'ItemPrice': price,
          'Images': imageUrls,
          'Model': glbFileUrl,
          'Height': height,
          'Width': width,
          'Space': space,
          'Timestamp': FieldValue.serverTimestamp(),
        });
      }

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
      print(e);
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

  static Future<void> updateCustomItem({
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

// ✅ Update favorites too
      final favUsersSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Items')
          .where('ItemId', isEqualTo: itemId)
          .get();

      for (var favDoc in favUsersSnapshot.docs) {
        await favDoc.reference.update({
          'ItemName': name,
          'ItemDescription': description,
          'ItemPrice': price,
          'Images': imageUrls,
          'Model': glbFileUrl,
          'Height': "",
          'Width': "",
          'Space': "",
          'Timestamp': FieldValue.serverTimestamp(),
        });
      }
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
      print(e);
      ;
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
