import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Services/payment_services.dart';
import 'package:decor_lens/UI/User%20UI/address_screen.dart';
import 'package:decor_lens/UI/User%20UI/success_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final double orderAmount;
  final List<Map<String, dynamic>> cartItems;

  CheckoutScreen({required this.orderAmount, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedPaymentMethod = 'Cash on Delivery';
  Map<String, dynamic>? shippingAddress;
  double deliveryCharges = 0.0;
  bool placeOrder = false;
  String city = '';
  Map<String, dynamic>? paymentIntentData;
  PaymentService paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    loadShippingAndDelivery();
  }

  Future<void> loadShippingAndDelivery() async {
    await fetchShippingAddress();
    await fetchDeliveryCharges();
  }

  Future<void> fetchShippingAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      final addressList =
          List<Map<String, dynamic>>.from(data['addresses'] ?? []);

      if (addressList.isNotEmpty) {
        setState(() {
          shippingAddress = addressList[0];
          city = shippingAddress!['City'] ?? '';
        });
      } else {
        setState(() {
          shippingAddress = null;
          city = '';
        });
      }

      await fetchDeliveryCharges();
    }
  }

  Future<void> fetchDeliveryCharges() async {
    if (city.isEmpty) {
      setState(() {
        deliveryCharges = 500.0;
      });
      return;
    }

    try {
      final citySnapshot = await FirebaseFirestore.instance
          .collection('City Deliveries')
          .where('city', isEqualTo: city)
          .limit(1)
          .get();

      if (citySnapshot.docs.isNotEmpty) {
        final cityData = citySnapshot.docs.first.data();
        setState(() {
          deliveryCharges =
              double.tryParse(cityData['delivery_amount'].toString()) ?? 500.0;
        });
      } else {
        setState(() {
          deliveryCharges = 500.0;
        });
      }
    } catch (e) {
      setState(() {
        deliveryCharges = 500.0;
      });
    }
  }

  void openAddressSelector() {
    Get.to(() => AddressScreen())?.then((result) async {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          shippingAddress = result;
          city = result['City'] ?? '';
        });
        await fetchDeliveryCharges();
      } else {
        await fetchShippingAddress();
      }
    });
  }

  Future<void> clearCartAfterOrder() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference cartCollection =
        FirebaseFirestore.instance.collection('Cart Items');
    CollectionReference customCollection =
        FirebaseFirestore.instance.collection('Custom Items');

    // Delete all items in both collections for the user
    QuerySnapshot cartSnapshot =
        await cartCollection.where('userId', isEqualTo: userId).get();
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
    QuerySnapshot customSnapshot =
        await customCollection.where('userId', isEqualTo: userId).get();
    for (var doc in customSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  //Make Payment
  Future<void> makePayment(String orderId) async {
    try {
      int totalAmountInCents = ((widget.orderAmount + deliveryCharges)).toInt();

      // Create Payment Intent
      paymentIntentData = await paymentService.createPaymentIntent(
          totalAmountInCents.toString(), "USD");

      if (paymentIntentData == null ||
          !paymentIntentData!.containsKey('client_secret')) {
        throw Exception('Invalid Payment Intent Data');
      }

      // Initialize Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        googlePay: stripe.PaymentSheetGooglePay(
            testEnv: true, currencyCode: "USD", merchantCountryCode: "US"),
        merchantDisplayName: "Decor Lens",
      ));

      // Present Payment Sheet
      await displayPaymentSheet(orderId);
    } catch (e) {
      debugPrint('Error in makePayment: $e');
      await deleteOrderOnPaymentFail(orderId); // <--- Important!
    }
  }

  // Display Payment Sheet
  Future<void> displayPaymentSheet(String orderId) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      await clearCartAfterOrder(); // ✅ Only after successful payment
      setState(() => paymentIntentData = null);

      customSnackbar(
        title: 'Paid Successfully',
        message: 'Your order has been paid successfully.',
        titleColor: green,
        icon: Icons.check_circle_outline,
        iconColor: green,
      );

      // Navigate to success screen
      Get.to(
        () => SuccessOrder(orderId: orderId),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 600),
      );
    } on stripe.StripeException {
      await deleteOrderOnPaymentFail(orderId); // <--- Delete order on cancel
      customSnackbar(
        title: 'Payment Canceled',
        message: 'You have canceled the payment.',
        titleColor: blueAccent,
        icon: Icons.warning_amber,
        iconColor: blueAccent,
      );
    } catch (e) {
      await deleteOrderOnPaymentFail(orderId); // <--- Delete order on error
      customSnackbar(
        title: 'Payment Failed',
        message: 'Unexpected error occurred while processing payment.',
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
    }
  }

  Future<void> deleteOrderOnPaymentFail(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .delete();
      debugPrint('Order $orderId deleted due to failed/canceled payment.');
    } catch (e) {
      debugPrint('Failed to delete order $orderId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    final totalAmount = widget.orderAmount + deliveryCharges;

    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MyAppbar(
          title: "Checkout",
          showLeading: true,
          fontColor: isDarkMode ? white : black,
          leadingIconColor: isDarkMode ? white : black,
        ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle("Shipping Address", isDarkMode),
            SizedBox(height: 8),
            shippingAddress != null
                ? buildAddressCard(isDarkMode)
                : buildNoAddressWarning(),
            SizedBox(height: 20),
            buildSectionTitle("Payment Method", isDarkMode),
            SizedBox(height: 8),
            buildPaymentDropdown(isDarkMode),
            Spacer(),
            buildPriceDetails(isDarkMode, totalAmount),
            SizedBox(height: 20),
            CustomButton(
              buttonHeight: 50,
              buttonWidth: ScreenSize.screenWidth * 0.97,
              buttonColor: isDarkMode ? white : appColor,
              fonts: GoogleFonts.manrope(
                color: isDarkMode ? black : white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              isLoading: placeOrder,
              buttonText: 'Place Order',
              onPressed: () async {
                setState(() {
                  placeOrder = true;
                });

                try {
                  double orderTotalAmount = totalAmount;

                  // Collect user input and validation
                  String userName = shippingAddress!['Name'];
                  String userAddress = shippingAddress!['Address'];

                  print(shippingAddress!['Name']);
                  print(shippingAddress!['Address']);
                  String adminResponse = 'Processing';

                  String formatDateTime(DateTime dateTime) {
                    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
                        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
                  }

                  String orderTime = formatDateTime(DateTime.now());

                  if (userName.isEmpty ||
                      userAddress.isEmpty ||
                      selectedPaymentMethod == null) {
                    customSnackbar(
                      title: 'Error',
                      message: 'Please fill in all the required fields!',
                      titleColor: red,
                      messageColor: black,
                      icon: Icons.error_outline,
                      iconColor: red,
                    );

                    setState(() {
                      placeOrder = false;
                    });
                    return;
                  }

                  // Prepare product details for storage
                  String productNames = widget.cartItems
                      .map((item) => item['ProductName'])
                      .join(', ');
                  String productImages =
                      widget.cartItems.map((item) => item['Image']).join(', ');
                  String productPrices = widget.cartItems
                      .map((item) => item['Price'].toString())
                      .join(', ');
                  String productQuantities = widget.cartItems
                      .map((item) => item['Quantity'].toString())
                      .join(', ');
                  String productHeight = widget.cartItems
                      .map((item) => item['Height'].toString())
                      .join(', ');
                  String productWidth = widget.cartItems
                      .map((item) => item['Width'].toString())
                      .join(', ');
                  String productSpace = widget.cartItems
                      .map((item) => item['Space'].toString())
                      .join(', ');
                  String productType = widget.cartItems
                      .map((item) => item['Product_type'].toString())
                      .join(', ');

                  // Firestore references
                  CollectionReference ordersCollection =
                      FirebaseFirestore.instance.collection('Orders');

                  // Fetch the last order number from Firestore
                  QuerySnapshot lastOrderSnapshot = await ordersCollection
                      .orderBy('order_no', descending: true)
                      .limit(1)
                      .get();

                  // Default order number (starts from 1 if no previous orders exist)
                  int newOrderNo = 20250;

                  if (lastOrderSnapshot.docs.isNotEmpty) {
                    var lastOrder = lastOrderSnapshot.docs.first;
                    newOrderNo = (lastOrder['order_no'] ?? 0) + 1;
                  }

                  // Step 2: Add Order to Firestore
                  DocumentReference orderDoc = await ordersCollection.add({
                    'order_no': newOrderNo, // Unique incremental order number
                    'order_by': userName,
                    'address': userAddress,
                    'city': city,
                    'order_time': orderTime,
                    'delivery_method': selectedPaymentMethod,
                    'delivery_amount': deliveryCharges,
                    'order_amount': widget.orderAmount,
                    'total_amount': orderTotalAmount,
                    'admin_response': adminResponse,
                    'product_names': productNames,
                    'product_images': productImages,
                    'product_prices': productPrices,
                    'product_quantities': productQuantities,
                    'product_height': productHeight,
                    'product_width': productWidth,
                    'product_space': productSpace,
                    'product_type': productType,
                    'User': FirebaseAuth.instance.currentUser!.uid,
                  });

                  // Retrieve the auto-generated document ID
                  String orderId = orderDoc.id;

                  // Update the document with the order ID
                  await orderDoc.update({'order_id': orderId});

                  if (selectedPaymentMethod == 'Card Payment') {
                    await makePayment(orderId);

                    setState(() {
                      placeOrder = false;
                    });
                    return;
                  }

                  // Cash on Delivery: safe to clear immediately
                  await clearCartAfterOrder();

                  setState(() {
                    placeOrder = false;
                  });

                  // Navigate to success page
                  Get.offAll(
                    () => SuccessOrder(
                      orderId: orderId,
                    ),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 600),
                  );
                } catch (e) {
                  // Handle errors
                  customSnackbar(
                      title: 'Failed 😞',
                      message: 'Failed to place order. Please try again.',
                      titleColor: red,
                      icon: Icons.error_outline,
                      iconColor: red);

                  setState(() {
                    placeOrder = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title, bool isDarkMode) => Text(
        title,
        style: GoogleFonts.manrope(
          color: isDarkMode ? white : black.withOpacity(.6),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget buildAddressCard(bool isDarkMode) => Card(
        color: isDarkMode ? black : white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(
            shippingAddress!['Name'],
            style: GoogleFonts.manrope(
              color: isDarkMode ? white : black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            shippingAddress!['Address'],
            style: GoogleFonts.manrope(
              color: isDarkMode ? white : black.withOpacity(.8),
            ),
          ),
          trailing: TextButton(
            onPressed: openAddressSelector,
            child: Icon(Icons.edit, color: blueAccent),
          ),
        ),
      );

  Widget buildNoAddressWarning() => Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red[50],
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "No shipping address found. Please add an address to place the order.",
                style: TextStyle(color: Colors.red[800], fontSize: 14),
              ),
            ),
          ],
        ),
      );

  Widget buildPaymentDropdown(bool isDarkMode) =>
      DropdownButtonFormField<String>(
        dropdownColor: isDarkMode ? kOffBlack : white,
        iconEnabledColor: isDarkMode ? white : black,
        iconDisabledColor: isDarkMode ? white : black,
        value: selectedPaymentMethod,
        items: [
          DropdownMenuItem(
            value: 'Cash on Delivery',
            child: Row(
              children: [
                Icon(Icons.money, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'Cash on Delivery',
                  style: GoogleFonts.manrope(
                    color: isDarkMode ? white : black.withOpacity(.6),
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'Card Payment',
            child: Row(
              children: [
                Icon(FontAwesomeIcons.ccStripe, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Card Payment',
                  style: GoogleFonts.manrope(
                    color: isDarkMode ? white : black.withOpacity(.6),
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (value) => setState(() => selectedPaymentMethod = value),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );

  Widget buildPriceDetails(bool isDarkMode, double totalAmount) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1.2),
          buildPriceRow("Order Amount:", widget.orderAmount, isDarkMode),
          buildPriceRow("Delivery Charges:", deliveryCharges, isDarkMode),
          Divider(thickness: 1.2),
          buildPriceRow("Total:", totalAmount, isDarkMode, isBold: true),
        ],
      );

  Widget buildPriceRow(String label, double amount, bool isDarkMode,
          {bool isBold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDarkMode ? white : black.withOpacity(.8),
            ),
          ),
          Text(
            'Rs ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontSize: isBold ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? white : black,
            ),
          ),
        ],
      );
}
