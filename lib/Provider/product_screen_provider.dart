import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductProvider with ChangeNotifier {
  String customHeight = '', customWidth = '', customSpace = '';
  int quantity = 1;
  late String mainImage = '';
  bool isModelSelected = false;
  bool isLoading = false;

  void initializeMainImage(List<String> images) {
    mainImage = images.isNotEmpty ? images[0] : '';
    notifyListeners();
  }

  void resetCustomDimensions() {
    customHeight = '';
    customWidth = '';
    customSpace = '';
    notifyListeners();
  }

  Future<void> fetchCustomItemDimensions(String productName) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final customItemQuery = await FirebaseFirestore.instance
        .collection('Custom Items')
        .where('ProductName', isEqualTo: productName)
        .where('userId', isEqualTo: userId)
        .get();

    if (customItemQuery.docs.isNotEmpty) {
      var doc = customItemQuery.docs.first;
      customHeight = doc['Height'] ?? '';
      customWidth = doc['Width'] ?? '';
      customSpace = doc['Space'] ?? '';
    } else {
      customHeight = '';
      customWidth = '';
      customSpace = '';
    }
    notifyListeners();
  }

  void switchImage(String selectedImage) {
    isModelSelected = false;
    mainImage = selectedImage;
    notifyListeners();
  }

  void switchTo3DModel() {
    isModelSelected = true;
    notifyListeners();
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  void incrementQuantity() {
    quantity++;
    notifyListeners();
  }

  Future<void> updateCustomItem({
    required String productName,
    required String description,
    required String image,
    required String price,
    required int quantity,
    required String height,
    required String width,
    required String space,
    required String category,
    required Function(String message, bool isSuccess) onComplete,
  }) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final customItemQuery = await FirebaseFirestore.instance
        .collection('CustomItems')
        .where('productName', isEqualTo: productName)
        .where('userId', isEqualTo: userId)
        .get();

    try {
      if (customItemQuery.docs.isNotEmpty) {
        // Update
        String docId = customItemQuery.docs.first.id;
        await FirebaseFirestore.instance
            .collection('CustomItems')
            .doc(docId)
            .update({
          'height': height,
          'width': width,
          'space': space,
        });
        customHeight = height;
        customWidth = width;
        customSpace = space;
        notifyListeners();
        onComplete("Dimensions updated successfully.", true);
      } else {
        // Add new
        await FirebaseFirestore.instance.collection('CustomItems').add({
          'userId': userId,
          'productName': productName,
          'description': description,
          'image': image,
          'price': price,
          'addedAt': DateTime.now(),
          'quantity': quantity,
          'height': height,
          'width': width,
          'space': space,
          'category': category,
        });
        customHeight = height;
        customWidth = width;
        customSpace = space;
        notifyListeners();
        onComplete("Customization done successfully.", true);
      }
    } catch (e) {
      onComplete("An error occurred: ${e.toString()}", false);
    }
  }

  Future<void> addToCart(
      String productName,
      String description,
      String image,
      String price,
      String height,
      String width,
      String space,
      String category) async {
    isLoading = true;
    notifyListeners();

    try {
      String userId =
          FirebaseAuth.instance.currentUser!.uid; // Get current user ID

      final cartItemQuery = await FirebaseFirestore.instance
          .collection('Cart Items')
          .where('ProductName', isEqualTo: productName)
          .where('userId',
              isEqualTo: userId) // Check if this user already has this item
          .get();

      if (cartItemQuery.docs.isNotEmpty
          // || customItemQuery.docs.isNotEmpty
          ) {
        customSnackbar(
          title: 'Product is in the Cart',
          message: 'Product is already in the cart!',
          titleColor: orangeAccent,
          icon: Icons.info_outline,
          iconColor: orangeAccent,
        );
      } else {
        // else {
        await FirebaseFirestore.instance.collection('Cart Items').add({
          'userId': userId,
          'ProductName': productName,
          'Description': description,
          'Image': image,
          'Price': price,
          'AddedAt': DateTime.now(),
          'Quantity': quantity,
          'Height': height,
          'Width': width,
          'Space': space,
          'Category': category
        });

        customSnackbar(
          title: 'Product Added',
          message: 'Product has been added to the cart',
          titleColor: green,
          icon: Icons.check,
          iconColor: green,
        );

        // Get.to(
        //   () => Cart(),
        //   transition: Transition.fadeIn,
        //   duration: const Duration(milliseconds: 600),
        // );
      }
    } catch (e) {
      customSnackbar(
        title: 'Failed to add',
        message: 'Failed to add to cart! $e',
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
