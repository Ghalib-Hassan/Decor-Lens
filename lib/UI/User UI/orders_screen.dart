import 'package:decor_lens/Services/payment_services.dart';
import 'package:decor_lens/Widgets/custom_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  String selectedStatus = 'All';
  final List<String> statusOptions = [
    'All',
    'Processing',
    'Accepted',
    'Rejected',
    'Cancelled',
    'Dispatched',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MyAppbar(
          title: "Orders",
          showLeading: true,
          fontColor: isDarkMode ? white : black,
          leadingIconColor: isDarkMode ? white : black,
        ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                filled: true,
                fillColor: grey.withOpacity(.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black,
                      width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: isDarkMode ? black : white,
              icon: Icon(Icons.arrow_drop_down,
                  color: isDarkMode ? white : black),
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(
                    status,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: isDarkMode ? white : black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedStatus = value!),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .where('User', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders found.',
                      style: GoogleFonts.nunitoSans(
                          color: isDarkMode ? white : black, fontSize: 18),
                    ),
                  );
                }

                List<DocumentSnapshot> orders = snapshot.data!.docs;
                if (selectedStatus != 'All') {
                  orders = orders
                      .where((order) =>
                          order['admin_response'].toString().toLowerCase() ==
                          selectedStatus.toLowerCase())
                      .toList();
                }

                orders.sort((a, b) =>
                    (b['order_no'] as int).compareTo(a['order_no'] as int));

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) =>
                      buildOrderCard(orders[index], context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderCard(dynamic order, BuildContext context) {
    final darkModeService =
        Provider.of<DarkModeService>(context, listen: false);
    final isDarkMode = darkModeService.isDarkMode;

    List<String> productImages = order['product_images'].split(', ');
    List<String> productNames = order['product_names'].split(', ');
    List<String> productQuantities = order['product_quantities'].split(', ');
    List<String> productPrices = order['product_prices'].split(', ');
    List<String> productHeights = order['product_height'].split(', ');
    List<String> productWidths = order['product_width'].split(', ');
    List<String> productSpace = order['product_space'].split(', ');
    List<String> productTypes = order['product_type'].split(', ');
    double deliveryAmount = order['delivery_amount'];

    bool isCardPayment = order['delivery_method'] == "Card Payment";
    return FutureBuilder<double>(
      future: isCardPayment
          ? CurrencyConverterHelper.fetchExchangeRate()
          : Future.value(1.0),
      builder: (context, snapshot) {
        double conversionRate = snapshot.data ?? 0.0036;

        double deliveryFee =
            deliveryAmount * (isCardPayment ? conversionRate : 1.0);
        double totalAmount = deliveryFee;
        String currencySymbol = isCardPayment ? '\$' : '₨';

        for (int i = 0; i < productPrices.length; i++) {
          int quantity = int.tryParse(productQuantities[i]) ?? 1;
          double pricePerItem = double.tryParse(productPrices[i]) ?? 0.0;
          double totalProductPrice = pricePerItem * quantity;
          if (isCardPayment) totalProductPrice *= conversionRate;
          totalAmount += totalProductPrice;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.grey[900]!, Colors.grey[850]!]
                  : [white, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  runSpacing: 6,
                  children: [
                    CustomRichText(
                        label: 'Order No',
                        value: order['order_no'].toString(),
                        fontSize: 15,
                        color: isDarkMode ? white : black),
                    CustomRichText(
                        label: 'Order by',
                        value: order['order_by'],
                        fontSize: 15,
                        color: isDarkMode ? white : black),
                    CustomRichText(
                        label: 'Address',
                        value: order['address'],
                        fontSize: 15,
                        color: isDarkMode ? white : black),
                    CustomRichText(
                        label: 'Payment Method',
                        value: order['delivery_method'],
                        fontSize: 15,
                        color: isDarkMode ? white : black),
                    CustomRichText(
                        label: 'Order Time',
                        value: order['order_time'],
                        fontSize: 15,
                        color: isDarkMode ? white : black),
                    CustomRichText(
                      label: 'Order Status',
                      value: order['admin_response'] == 'Processing'
                          ? 'Pending...'
                          : order['admin_response'] == 'Accepted'
                              ? 'Processing'
                              : order['admin_response'],
                      fontSize: 15,
                      color:
                          isDarkMode ? Colors.orangeAccent : Colors.deepOrange,
                    ),
                  ],
                ),
                Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productNames.length,
                  itemBuilder: (context, index) {
                    int quantity = int.tryParse(productQuantities[index]) ?? 1;
                    double pricePerItem =
                        double.tryParse(productPrices[index]) ?? 0.0;
                    double totalProductPrice = pricePerItem * quantity;
                    if (isCardPayment) totalProductPrice *= conversionRate;

                    // const double conversionRate = 0.0036; // Rs to USD conversion
                    // double deliveryFee = deliveryAmount;

                    // double totalAmount =
                    //     isCardPayment ? (deliveryFee * conversionRate) : deliveryFee;
                    // String currencySymbol = isCardPayment ? '\$' : '₨';

                    // for (int i = 0; i < productPrices.length; i++) {
                    //   int quantity = int.tryParse(productQuantities[i]) ?? 1;
                    //   double pricePerItem = double.tryParse(productPrices[i]) ?? 0.0;
                    //   double totalProductPrice = pricePerItem * quantity;

                    //   if (isCardPayment) {
                    //     totalProductPrice *= conversionRate; // Convert to USD
                    //   }
                    //   totalAmount += totalProductPrice;
                    // }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              productImages[index],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(productNames[index],
                                    style: GoogleFonts.nunitoSans(
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode ? white : black,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: $quantity, Price: $currencySymbol${totalProductPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.nunitoSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Size: ${productHeights[index]} x ${productWidths[index]}, Space: ${productSpace[index]}, Type: ${productTypes[index]}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: $currencySymbol${totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDarkMode ? white : black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
