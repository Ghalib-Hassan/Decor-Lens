import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Services/payment_services.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/custom_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData.light(), // Force light mode on this screen

      child: Scaffold(
        backgroundColor: adminBack,
        appBar: AppBar(
          backgroundColor: adminAppbar,
          title: Text(
            'Admin Orders',
            style: GoogleFonts.poppins(
              fontSize: screenHeight * 0.03,
              color: white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            physics: ScrollPhysics(parent: BouncingScrollPhysics()),
            dividerColor: black,
            indicatorWeight: 6,
            indicatorColor: white,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: true,
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  'All Orders',
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.02,
                      color: white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Rejected',
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.02,
                      color: white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Accepted',
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.02,
                      color: white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Cancelled',
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.02,
                      color: white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Dispatched',
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.02,
                      color: white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Delivered',
                  style: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.02,
                      color: white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildOrdersList(filter: null), // All Orders
            buildOrdersList(
              filter: 'Rejected',
            ), // Rejected Orders
            buildOrdersList(filter: 'Accepted'), // Accepted Orders
            buildOrdersList(filter: 'Cancelled'), // Cencelled Orders
            buildOrdersList(filter: 'Dispatched'), // Dispatched Orders
            buildOrdersList(filter: 'Delivered'), // Delivered Orders
          ],
        ),
      ),
    );
  }

  Widget buildOrdersList({String? filter}) {
    final screenHeight = MediaQuery.of(context).size.height;
    Query ordersQuery = FirebaseFirestore.instance.collection('Orders');

    if (filter != null) {
      // Query for specific filters (Accepted or Rejected)
      ordersQuery = ordersQuery.where('admin_response', isEqualTo: filter);
    } else {
      // Exclude Accepted and Rejected for All Orders tab
      ordersQuery =
          ordersQuery.where('admin_response', isEqualTo: 'Processing');
    }

    return Theme(
      data: ThemeData.light(), // Force light mode on this screen

      child: StreamBuilder<QuerySnapshot>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'No orders found.',
              style: GoogleFonts.ubuntu(
                  color: black, fontSize: screenHeight * 0.02),
            ));
          }

          List<QueryDocumentSnapshot> orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> order =
                  orders[index].data() as Map<String, dynamic>;

              // Show buttons only in All Orders tab
              bool showButtons = filter == null;

              return buildOrderCard(order,
                  showButtons: showButtons, filter: filter);
            },
          );
        },
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> order,
      {bool showButtons = false, String? filter}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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

          if (isCardPayment) {
            totalProductPrice *= conversionRate;
          }
          totalAmount += totalProductPrice;
        }

        bool isAcceptedTab = filter == 'Accepted';
        bool isDispatchedTab = filter == 'Dispatched';

        return Theme(
          data: ThemeData.light(),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order metadata
                  _buildMetadata(order, screenHeight),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey.shade300),

                  // Product list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productNames.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      int quantity =
                          int.tryParse(productQuantities[index]) ?? 1;
                      double pricePerItem =
                          double.tryParse(productPrices[index]) ?? 0.0;
                      double totalProductPrice = pricePerItem * quantity;
                      if (isCardPayment) {
                        totalProductPrice *= conversionRate;
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              productImages[index],
                              width: screenWidth * 0.15,
                              height: screenHeight * 0.1,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(productNames[index],
                                    style: GoogleFonts.poppins(
                                      fontSize: screenHeight * 0.02,
                                      fontWeight: FontWeight.w600,
                                    )),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: $quantity × $currencySymbol${pricePerItem.toStringAsFixed(2)} = $currencySymbol${totalProductPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                      fontSize: screenHeight * 0.016,
                                      color: Colors.grey[800]),
                                ),
                                Text(
                                  'Height: ${productHeights[index]}, Width: ${productWidths[index]}, Space: ${productSpace[index]}',
                                  style: GoogleFonts.poppins(
                                      fontSize: screenHeight * 0.014),
                                ),
                                Text('Type: ${productTypes[index]}',
                                    style: GoogleFonts.poppins(
                                        fontSize: screenHeight * 0.014)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  Divider(color: Colors.grey.shade300),
                  Text(
                    'Final Total (Incl. Delivery): $currencySymbol ${totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.02,
                    ),
                  ),

                  // Button row(s)
                  const SizedBox(height: 12),
                  if (showButtons)
                    _buildActionButtons(
                        order, 'Accepted', screenHeight, screenWidth),
                  if (isAcceptedTab)
                    _buildActionButtons(
                        order, 'Dispatched', screenHeight, screenWidth),
                  if (isDispatchedTab)
                    _buildDeliveredButton(order, screenHeight, screenWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadata(Map<String, dynamic> order, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRichText(
            label: 'Order #',
            value: order['order_no'].toString(),
            fontSize: screenHeight * 0.018),
        CustomRichText(
            label: 'Ordered by',
            value: order['order_by'],
            fontSize: screenHeight * 0.018),
        CustomRichText(
            label: 'Address',
            value: order['address'],
            fontSize: screenHeight * 0.018),
        CustomRichText(
            label: 'Time',
            value: order['order_time'],
            fontSize: screenHeight * 0.017),
        CustomRichText(
            label: 'Payment',
            value: order['delivery_method'],
            fontSize: screenHeight * 0.017),
        CustomRichText(
            label: 'User UID',
            value: order['User'],
            fontSize: screenHeight * 0.014),
        CustomRichText(
            label: 'City',
            value: order['city'],
            fontSize: screenHeight * 0.014),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, String type,
      double screenHeight, double screenWidth) {
    final isAcceptReject = type == 'Accepted';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomButton(
          buttonColor: isAcceptReject ? green : blue,
          buttonBorder: BorderSide(color: isAcceptReject ? green : blue),
          buttonHeight: screenHeight * 0.045,
          buttonWidth: screenWidth * 0.4,
          buttonText: isAcceptReject ? 'Accept' : 'Dispatch',
          buttonFontSize: screenHeight * 0.016,
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('Orders')
                .doc(order['order_id'])
                .update({
              'admin_response': isAcceptReject ? 'Accepted' : 'Dispatched'
            });
          },
        ),
        CustomButton(
          buttonColor: red,
          buttonBorder: BorderSide(color: red),
          buttonHeight: screenHeight * 0.045,
          buttonWidth: screenWidth * 0.4,
          buttonText: isAcceptReject ? 'Reject' : 'Cancel',
          buttonFontSize: screenHeight * 0.016,
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('Orders')
                .doc(order['order_id'])
                .update({
              'admin_response': isAcceptReject ? 'Rejected' : 'Cancelled'
            });
          },
        ),
      ],
    );
  }

  Widget _buildDeliveredButton(
      Map<String, dynamic> order, double screenHeight, double screenWidth) {
    return Center(
      child: CustomButton(
        buttonColor: green,
        buttonBorder: BorderSide(color: green),
        buttonHeight: screenHeight * 0.045,
        buttonWidth: screenWidth * 0.5,
        buttonText: 'Mark as Delivered',
        buttonFontSize: screenHeight * 0.017,
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('Orders')
              .doc(order['order_id'])
              .update({'admin_response': 'Delivered'});
        },
      ),
    );
  }
}
