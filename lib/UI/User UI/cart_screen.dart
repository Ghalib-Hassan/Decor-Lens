import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/product_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/exit_confirmation.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  final int initialTabIndex; // New parameter
  const Cart({super.key, this.initialTabIndex = 0});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  double totalAmount = 0.0;
  double cartTotalAmount = 0.0;
  double customTotalAmount = 0.0;
  bool isLoading = false;
  String? orderMethod;
  Map<String, bool> priceIncreased = {};
  late TabController _tabController;

  Map<String, String?> orderMethods = {}; // Store order method per item
  Map<String, TextEditingController> heightControllers = {};
  Map<String, TextEditingController> widthControllers = {};
  Map<String, TextEditingController> spaceControllers = {};

  List<QueryDocumentSnapshot> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCustomItemsAndSetInitialValues();
    fetchAllItemsAndCalculateTotal();

    // Initialize tracking for each item
    FirebaseFirestore.instance.collection('Cart Items').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        priceIncreased[doc.id] = false;
      }
    });

    // Initialize TabController with the received index
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
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
      orderMethods[itemId] = null; // Initialize order method selection

      heightControllers[itemId] = TextEditingController(
          text: item['Height'] != '' ? item['Height'].toString() : '');
      widthControllers[itemId] = TextEditingController(
          text: item['Width'] != '' ? item['Width'].toString() : '');
      spaceControllers[itemId] = TextEditingController(
          text: item['Space'] != '' ? item['Space'].toString() : '');
    }
    setState(() {});
  }

  bool validateOrderMethods() {
    for (var item in cartItems) {
      String itemId = item.id;

      // Check if height, width, and space are filled
      if ((heightControllers[itemId]?.text.isEmpty ?? true) ||
          (widthControllers[itemId]?.text.isEmpty ?? true) ||
          (spaceControllers[itemId]?.text.isEmpty ?? true)) {
        customSnackbar(
          title: 'Enter Dimensions',
          message: 'Please enter height, width, and space for all items!',
          titleColor: red,
          icon: Icons.error_outline,
          iconColor: red,
        );

        return false;
      }
    }
    return true;
  }

  Future<void> fetchAllItemsAndCalculateTotal() async {
    List<QueryDocumentSnapshot> standardItems = await fetchItems();
    List<QueryDocumentSnapshot> customItems = await fetchCustomItems();

    double total = 0.0;

    for (var item in standardItems) {
      double productPrice = double.tryParse(item['Price']) ?? 0.0;
      int quantity = item['Quantity'];
      total += productPrice * quantity;
    }
    cartTotalAmount = total;

    total = 0.0;
    for (var item in customItems) {
      double productPrice = double.tryParse(item['Price']) ?? 0.0;
      int quantity = item['Quantity'];
      total += productPrice * quantity;
    }
    customTotalAmount = total;

    setState(() {
      totalAmount = cartTotalAmount + customTotalAmount;
    });
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
      int quantity = doc['Quantity'];
      double productPrice = double.tryParse(doc['Price'].toString()) ?? 0.0;

      // Update UI immediately
      quantity++;
      double newTotalPrice = productPrice * quantity;

      // Update cartTotalAmount and totalAmount locally
      setState(() {
        cartTotalAmount += productPrice;
        totalAmount = cartTotalAmount + customTotalAmount;
      });

      // Firestore update in background
      await collection.doc(itemId).update({
        'Quantity': quantity,
        'TotalPrice': newTotalPrice,
      });

      // Optional: refresh cart items again if needed
      // await fetchAllItemsAndCalculateTotal();
    }
  }

  Future<void> decrementItem(String itemId, bool isCustom) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection(isCustom ? 'Custom Items' : 'Cart Items');

    DocumentSnapshot doc = await collection.doc(itemId).get();

    if (doc.exists) {
      int quantity = doc['Quantity'];
      double productPrice = double.tryParse(doc['Price'].toString()) ?? 0.0;

      if (quantity > 1) {
        // Update UI immediately
        quantity--;
        double newTotalPrice = productPrice * quantity;

        setState(() {
          cartTotalAmount -= productPrice;
          totalAmount = cartTotalAmount + customTotalAmount;
        });

        // Firestore update in background
        await collection.doc(itemId).update({
          'Quantity': quantity,
          'TotalPrice': newTotalPrice,
        });

        // Optional: refresh cart items again if needed
        // await fetchAllItemsAndCalculateTotal();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => kOnExitConfirmation(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: isDarkMode ? kOffBlack : white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: isDarkMode ? black : white,
            iconTheme: IconThemeData(color: isDarkMode ? white : black),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: isDarkMode ? white : black,
                    size: screenHeight * 0.028),
                const SizedBox(width: 8),
                Text(
                  'My Cart',
                  style: GoogleFonts.manrope(
                    fontSize: screenHeight * 0.026,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? white : black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            bottom: TabBar(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
              ),
              indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: -3, vertical: 6),
              labelPadding: const EdgeInsets.symmetric(horizontal: 1),
              tabs: [
                Tab(
                  child: Text(
                    'Standard Orders',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      fontSize: screenHeight * 0.016,
                      color: isDarkMode ? white : black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Custom Orders',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      fontSize: screenHeight * 0.016,
                      color: isDarkMode ? white : black,
                    ),
                  ),
                ),
              ],
              unselectedLabelColor:
                  isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  FutureBuilder(
                      future: fetchItems(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? white : black,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No items found.',
                              style: GoogleFonts.poppins(
                                  color: isDarkMode ? white : black,
                                  fontSize: screenHeight * 0.02),
                            ),
                          );
                        }
                        final items = snapshot.data!;

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.data![index];

                            String price = item['Price'];
                            int quantity = item['Quantity'];

                            double productPrice = double.tryParse(price) ?? 0.0;
                            double totalPrice = productPrice * quantity;
                            return buildCartItem(
                              context: context,
                              item: item,
                              image: item['Image'],
                              productName: item['ProductName'],
                              description: item['Description'],
                              price: item['Price'],
                              height: item['Height'],
                              width: item['Width'],
                              space: item['Space'],
                              category: item['Category'],
                              totalPrice: totalPrice,
                              incrementItem: incrementItem,
                              decrementItem: decrementItem,
                              fetchAllItemsAndCalculateTotal:
                                  fetchAllItemsAndCalculateTotal,
                            );
                          },
                        );
                      }),
                  FutureBuilder(
                      future: fetchCustomItems(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? white : black,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No items found.',
                              style: GoogleFonts.poppins(
                                  color: isDarkMode ? white : black,
                                  fontSize: screenHeight * 0.02),
                            ),
                          );
                        }
                        final items = snapshot.data!;

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            String price = item['Price'];
                            // // Ensure 'image' is always a List
                            List<String> image = (item['Image'] is List)
                                ? List<String>.from(item['Image'])
                                : [item['Image']];
                            int quantity = item['Quantity'];

                            double productPrice = double.tryParse(price) ?? 0.0;
                            double totalPrice = productPrice * quantity;

                            return buildCustomCartItem(
                              context: context,
                              item: item,
                              image: image,
                              productName: item['ProductName'],
                              description: item['Description'],
                              price: item['Price'],
                              height: item['Height'],
                              width: item['Width'],
                              space: item['Space'],
                              category: item['Category'],
                              quantity: item['Quantity'],
                              itemId: item.id,
                              heightController: heightControllers[item.id]!,
                              widthController: widthControllers[item.id]!,
                              spaceController: spaceControllers[item.id]!,
                              totalPrice: totalPrice,
                              incrementItem: incrementItem,
                              decrementItem: decrementItem,
                              fetchAllItemsAndCalculateTotal:
                                  fetchAllItemsAndCalculateTotal,
                              setStateCallback: () => setState(() {}),
                            );
                          },
                        );
                      }),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: GoogleFonts.nunitoSans(
                                color: grey, fontSize: screenHeight * 0.02),
                          ),
                          Text(
                            'Rs ${totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.nunitoSans(
                              color: isDarkMode ? white : black,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomButton(
                      buttonColor: isDarkMode ? white : appColor,
                      buttonWidth: screenWidth * 0.8,
                      buttonHeight: screenHeight * 0.06,
                      isLoading: isLoading,
                      buttonText: 'Check out',
                      fonts: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? black : white,
                        fontSize: screenWidth * 0.05,
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        String userId = FirebaseAuth.instance.currentUser!.uid;

                        if (!validateOrderMethods()) {
                          setState(() => isLoading = false);
                          return;
                        }

                        // Fetch orders and custom items
                        QuerySnapshot cartSnapshot = await FirebaseFirestore
                            .instance
                            .collection('Cart Items')
                            .where('userId', isEqualTo: userId)
                            .get();
                        QuerySnapshot customSnapshot = await FirebaseFirestore
                            .instance
                            .collection('Custom Items')
                            .where('userId', isEqualTo: userId)
                            .get();

                        if (cartSnapshot.docs.isEmpty &&
                            customSnapshot.docs.isEmpty) {
                          customSnackbar(
                            title: 'Cart Empty',
                            message: 'Your cart is empty!',
                            titleColor: red,
                            icon: Icons.error_outline,
                            iconColor: red,
                          );

                          setState(() {
                            isLoading = false;
                          });
                          return; // Stop execution if both are empty
                        }

                        List<Map<String, dynamic>> combinedCartItems = [];

                        // Add standard orders to checkout list
                        for (var item in cartSnapshot.docs) {
                          combinedCartItems.add({
                            'ProductName': item['ProductName'],
                            'Image': item['Image'],
                            'Quantity': item['Quantity'],
                            'Price': item['Price'],
                            'Product_type': 'Standard order',
                            'Height': item['Height'],
                            'Width': item['Width'],
                            'Space': item['Space'],
                          });
                        }

                        // Add custom orders to checkout list
                        for (var item in customSnapshot.docs) {
                          String itemId = item.id;
                          combinedCartItems.add({
                            'ProductName': item['productName'],
                            'Image': item['Image'],
                            'Quantity': item['Quantity'],
                            'Price': item['Price'],
                            'Product_type': 'Custom order',
                            'Height': heightControllers[itemId]?.text ?? '',
                            'Width': widthControllers[itemId]?.text ?? '',
                            'Space': spaceControllers[itemId]?.text ?? '',
                          });
                        }

                        // Get.off(
                        //   () => CheckoutScreen(
                        //     totalAmount: totalAmount,
                        //     cartItems: combinedCartItems,
                        //   ),
                        //   transition: Transition.fadeIn,
                        //   duration: const Duration(milliseconds: 600),
                        // );
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
        ),
      ),
    );
  }

  Widget buildCartItem({
    required BuildContext context,
    required dynamic item,
    required String image,
    required String productName,
    required String description,
    required String price,
    required String height,
    required String width,
    required String space,
    required String category,
    required double totalPrice,
    required Function(String id, bool fromDelete) incrementItem,
    required Function(String id, bool fromDelete) decrementItem,
    required Function fetchAllItemsAndCalculateTotal,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: isDarkMode ? black.withOpacity(.7) : white.withOpacity(.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(
                () => ProductScreen(
                  image: [image],
                  name: productName,
                  price: price,
                  description: description,
                  height: height,
                  width: width,
                  space: space,
                  category: category,
                ),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 600),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: item.id,
                  child: Image.network(
                    image,
                    width: screenWidth * 0.2,
                    height: screenHeight * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ).animate().fade(duration: 500.ms).scale(),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeFirstLetter(productName),
                  style: GoogleFonts.nunitoSans(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? white : black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.006),
                Text(
                  'Rs ${price}',
                  style: TextStyle(
                    fontSize: screenHeight * 0.018,
                    color: green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    Container(
                      height: screenWidth * 0.08,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: grey.withOpacity(0.5)),
                        color: grey.withOpacity(.2),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 18,
                              color: isDarkMode ? white : grey,
                            ),
                            onPressed: () => decrementItem(item.id, false),
                          ),
                          Text(
                            item['Quantity'].toString(),
                            style: TextStyle(
                              fontSize: screenHeight * 0.018,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? white : black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 18,
                              color: isDarkMode ? white : grey,
                            ),
                            onPressed: () => incrementItem(item.id, false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('Cart Items')
                      .doc(item.id)
                      .delete();

                  customSnackbar(
                    title: 'Item Removed',
                    message: 'Item removed from cart',
                    titleColor: blueAccent,
                    icon: Icons.error_outline,
                    iconColor: blueAccent,
                  );

                  fetchAllItemsAndCalculateTotal();
                },
                icon: Icon(Icons.cancel_outlined,
                    size: 25, color: kNoghreiSilver),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                'Rs $totalPrice',
                style: TextStyle(
                  fontSize: screenHeight * 0.017,
                  color: isDarkMode ? white : black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 500.ms)
        .moveY(begin: 50, end: 0, duration: 600.ms);
  }

  Widget buildCustomCartItem({
    required BuildContext context,
    required dynamic item,
    required List<String> image,
    required String productName,
    required String description,
    required String price,
    required String height,
    required String width,
    required String space,
    required String category,
    required int quantity,
    required String itemId,
    required TextEditingController heightController,
    required TextEditingController widthController,
    required TextEditingController spaceController,
    required double totalPrice,
    required Function(String id, bool fromDelete) incrementItem,
    required Function(String id, bool fromDelete) decrementItem,
    required Function fetchAllItemsAndCalculateTotal,
    required Function setStateCallback,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.002),
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: isDarkMode ? black.withOpacity(.7) : white.withOpacity(.7),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(color: grey.withOpacity(0.3)),
            ),
            boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => ProductScreen(
                      image: image,
                      name: productName,
                      price: price,
                      description: description,
                      height: height,
                      width: width,
                      space: space,
                      category: category,
                    ),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 600),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Hero(
                      tag: item.id,
                      child: Image.network(
                        image[0],
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.12,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ).animate().fade(duration: 500.ms).scale(),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalizeFirstLetter(productName),
                      style: GoogleFonts.nunitoSans(
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? white : black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.006),
                    Text(
                      'Rs $price',
                      style: TextStyle(
                        fontSize: screenHeight * 0.018,
                        color: green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      children: [
                        Container(
                          height: screenWidth * 0.08,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: grey.withOpacity(0.5)),
                            color: grey.withOpacity(.2),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: isDarkMode ? white : grey,
                                ),
                                onPressed: () => decrementItem(item.id, true),
                              ),
                              Text(
                                '$quantity',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.018,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? white : black,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: isDarkMode ? white : grey,
                                ),
                                onPressed: () => incrementItem(item.id, true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('Custom Items')
                          .doc(item.id)
                          .delete();

                      customSnackbar(
                        title: 'Item Removed',
                        message: 'Item removed from cart',
                        titleColor: blueAccent,
                        icon: Icons.error_outline,
                        iconColor: blueAccent,
                      );

                      Get.back(result: {'reset': true});
                      fetchAllItemsAndCalculateTotal();
                      setStateCallback();
                    },
                    icon: Icon(Icons.cancel_outlined,
                        size: 25, color: kNoghreiSilver),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Rs $totalPrice',
                    style: TextStyle(
                      fontSize: screenHeight * 0.017,
                      color: isDarkMode ? white : black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .moveY(begin: 50, end: 0, duration: 600.ms)
            .fade(duration: 500.ms),

        /// 🔧 Custom Dimensions Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildDimensionField('Height', heightController),
              buildDimensionField('Width', widthController),
              buildDimensionField('Space', spaceController),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget buildDimensionField(String label, TextEditingController controller) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to left
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: MediaQuery.of(context).size.height * 0.018,
            fontWeight: FontWeight.w600, // Bold for better visibility
            color: isDarkMode ? white : black,
          ),
        ),
        const SizedBox(height: 5), // Adds spacing between label & field
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25, // Slightly wider
          child: TextField(
            controller: controller,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              color: isDarkMode ? white : black,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center, // Centers input text
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10, top: 15, left: 5),
                child: Text(
                  'cm',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? white : black,
                  ),
                ),
              ),
              filled: true,
              fillColor: isDarkMode
                  ? Colors.grey[900]
                  : Colors.grey[200], // Modern look
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                borderSide: BorderSide.none, // Removes default border
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    for (var controller in heightControllers.values) {
      controller.dispose();
    }
    for (var controller in widthControllers.values) {
      controller.dispose();
    }
    for (var controller in spaceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
