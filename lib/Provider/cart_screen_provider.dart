import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  double totalAmount = 0.0;
  double cartTotalAmount = 0.0;
  double customTotalAmount = 0.0;
  bool isLoading = false;
  Map<String, bool> priceIncreased = {};

  Map<String, String?> orderMethods = {}; // Store order method per item
  Map<String, TextEditingController> heightControllers = {};
  Map<String, TextEditingController> widthControllers = {};
  Map<String, TextEditingController> spaceControllers = {};

  List<QueryDocumentSnapshot> cartItems = [];

  CartProvider() {
    initCart();
  }

  Future<void> initCart() async {
    await fetchCustomItemsAndSetInitialValues();
    await fetchAllItemsAndCalculateTotal();
    await initializePriceIncreasedFlags();
  }

  Future<void> initializePriceIncreasedFlags() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Cart Items').get();
    for (var doc in snapshot.docs) {
      priceIncreased[doc.id] = false;
    }
    notifyListeners();
  }

  Future<void> fetchCustomItemsAndSetInitialValues() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Custom Items')
        .where('userId', isEqualTo: userId)
        .get();

    cartItems = querySnapshot.docs;
    for (var item in cartItems) {
      String itemId = item.id;
      orderMethods[itemId] = null;

      heightControllers[itemId] = TextEditingController(
          text: item['Height'] != '' ? item['Height'].toString() : '');
      widthControllers[itemId] = TextEditingController(
          text: item['Width'] != '' ? item['Width'].toString() : '');
      spaceControllers[itemId] = TextEditingController(
          text: item['Space'] != '' ? item['Space'].toString() : '');
    }
    notifyListeners();
  }

  bool validateOrderMethods() {
    for (var item in cartItems) {
      String itemId = item.id;
      if ((heightControllers[itemId]?.text.isEmpty ?? true) ||
          (widthControllers[itemId]?.text.isEmpty ?? true) ||
          (spaceControllers[itemId]?.text.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchAllItemsAndCalculateTotal() async {
    List<QueryDocumentSnapshot> standardItems = await fetchItems();
    List<QueryDocumentSnapshot> customItems = await fetchCustomItems();

    double totalStandard = 0.0;
    double totalCustom = 0.0;

    for (var item in standardItems) {
      double productPrice = double.tryParse(item['Price']) ?? 0.0;
      int quantity = item['Quantity'];
      totalStandard += productPrice * quantity;
    }

    for (var item in customItems) {
      double productPrice = double.tryParse(item['Price']) ?? 0.0;
      int quantity = item['Quantity'];
      totalCustom += productPrice * quantity;
    }

    cartTotalAmount = totalStandard;
    customTotalAmount = totalCustom;
    totalAmount = cartTotalAmount + customTotalAmount;
    notifyListeners();
  }

  Future<List<QueryDocumentSnapshot>> fetchItems() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Cart Items')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> fetchCustomItems() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Custom Items')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs;
  }

  Future<void> incrementItem(String itemId, bool isCustom) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection(isCustom ? 'Custom Items' : 'Cart Items');

    DocumentSnapshot doc = await collection.doc(itemId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      int quantity = data['Quantity'] ?? 1;
      double price = double.tryParse(data['Price'].toString()) ?? 0.0;

      quantity++;
      double newTotal = price * quantity;

      await collection.doc(itemId).update({
        'Quantity': quantity,
        'TotalPrice': newTotal,
      });

      await fetchAllItemsAndCalculateTotal();
    }
  }

  Future<void> decrementItem(String itemId, bool isCustom) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection(isCustom ? 'Custom Items' : 'Cart Items');

    DocumentSnapshot doc = await collection.doc(itemId).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      int quantity = data['Quantity'] ?? 1;
      double price = double.tryParse(data['Price'].toString()) ?? 0.0;

      if (quantity > 1) {
        quantity--;
        double newTotal = price * quantity;

        await collection.doc(itemId).update({
          'Quantity': quantity,
          'TotalPrice': newTotal,
        });

        await fetchAllItemsAndCalculateTotal();
      }
    }
  }
}
