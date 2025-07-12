import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';

class Product {
  final String name;
  final List imageUrl;
  final String price;
  final String category;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      name: data['ItemName'] ?? '',
      imageUrl: data['ImageUrl'] ?? [],
      price: data['ItemPrice'] ?? '',
      category: data['Category'] ?? '',
    );
  }
}

class HomeProvider extends ChangeNotifier {
  int isSelected = 0;

  // Category list
  List<String> categories = [
    'Popular',
    'Chair',
    'Table',
    'Sofa',
    'Cupboard',
    'Bed',
    'Custom',
  ];

  // Store the current product list
  Future<List<QueryDocumentSnapshot>>? _currentProducts;
  Future<List<QueryDocumentSnapshot>>? get currentProducts => _currentProducts;

  final Set<String> _favoriteItemIds = {};
  Set<String> get favoriteItemIds => _favoriteItemIds;

  void fetchProducts(String category) {
    if (category == 'Popular') {
      _currentProducts = FirebaseFirestore.instance
          .collection('Items')
          .get()
          .then((snapshot) => snapshot.docs);
    } else {
      _currentProducts = FirebaseFirestore.instance
          .collection('Items')
          .where('Category', isEqualTo: category)
          .get()
          .then((snapshot) => snapshot.docs);
    }

    notifyListeners();
  }

  void selectCategory(int index) {
    isSelected = index;
    notifyListeners();
  }

  /// Load user's favorites from Firestore
  Future<void> loadFavorites(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Favourite Items')
        .doc(userId)
        .collection('Items')
        .get();

    _favoriteItemIds.clear();
    _favoriteItemIds.addAll(snapshot.docs.map((doc) => doc.id));
    notifyListeners();
  }

  /// Check if item is favorite
  bool isFavorite(String itemId) {
    return _favoriteItemIds.contains(itemId);
  }

  Future<void> toggleFavorites({
    required BuildContext context,
    required String itemId,
    required String user_Id,
    required Map<String, dynamic> itemData,
  }) async {
    final favDocRef = FirebaseFirestore.instance
        .collection('Favourite Items')
        .doc(user_Id)
        .collection('Items')
        .doc(itemId);

    final doc = await favDocRef.get();

    try {
      if (doc.exists) {
        await favDocRef.delete();
        _favoriteItemIds.remove(itemId);
        customSnackbar(
          title: "Favorite Removed",
          message: "${itemData['ItemName']} removed from favorites.",
          titleColor: red,
          icon: Icons.remove_circle_outline,
          iconColor: red,
        );
      } else {
        final favData = {
          'ItemId': itemId,
          'Height': itemData['Height'],
          'Width': itemData['Width'],
          'Space': itemData['Space'],
          'Model': itemData['Model'],
          'Images': itemData['Images'],
          'ItemName': itemData['ItemName'],
          'Category': itemData['Category'],
          'ItemPrice': itemData['ItemPrice'],
          'Description': itemData['ItemDescription'],
          'Timestamp': FieldValue.serverTimestamp(),
        };

        await favDocRef.set(favData);
        _favoriteItemIds.add(itemId);
        customSnackbar(
          title: "Favorite Added",
          message: "${itemData['ItemName']} added to favorites.",
          titleColor: green,
          icon: Icons.check_circle_outline,
          iconColor: green,
        );
      }
      notifyListeners();
    } catch (e) {
      print('Error adding to favorites: $e');
      customSnackbar(
        title: "Error",
        message: "Failed to add to favorites.",
        titleColor: red,
        icon: Icons.warning_amber_outlined,
        iconColor: red,
      );
    }
  }
}
