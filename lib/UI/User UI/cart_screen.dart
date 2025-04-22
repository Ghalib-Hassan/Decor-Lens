import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<CartItemModel> cartItems = [
    CartItemModel("EKERO", 'assets/images/chairs/chair1.jpg', 230),
    CartItemModel("STANDMON", 'assets/images/chairs/chair2.jpg', 330),
    CartItemModel("PLATLANS", 'assets/images/chairs/chair3.jpg', 540),
    CartItemModel("SALM", 'assets/images/chairs/chair4.jpg', 710),
  ];

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MyAppbar(title: "My Cart")
            .animate()
            .fade(duration: 500.ms)
            .slideY(begin: -0.3, end: 0),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenSize.screenWidth * 0.05),
        child: cartItems.isNotEmpty
            ? ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return CartItem(
                    item: cartItems[index],
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        cartItems[index].quantity = newQuantity;
                      });
                    },
                  )
                      .animate()
                      .fade(duration: 600.ms, delay: (index * 100).ms)
                      .moveY(begin: 50, end: 0);
                },
              )
            : Center(
                child: Text(
                  "Your cart is empty",
                  style: TextStyle(
                    fontSize: ScreenSize.screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: grey,
                  ),
                ).animate().fade(duration: 500.ms).scale(),
              ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}

class CartItemModel {
  String name;
  String imageUrl;
  double price;
  int quantity;

  CartItemModel(this.name, this.imageUrl, this.price, {this.quantity = 1});
}

class CartItem extends StatelessWidget {
  final CartItemModel item;
  final Function(int) onQuantityChanged;

  const CartItem({
    super.key,
    required this.item,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenSize.screenWidth * 0.02),
      padding: EdgeInsets.all(ScreenSize.screenWidth * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: white,
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
          Expanded(
            child: Image.asset(
              item.imageUrl,
              width: ScreenSize.screenWidth * 0.06,
              height: ScreenSize.screenHeight * 0.15,
              fit: BoxFit.cover,
            ).animate().fade(duration: 600.ms).scale(),
          ),
          SizedBox(width: ScreenSize.screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: ScreenSize.screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: ScreenSize.screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: red.withOpacity(.6)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: ScreenSize.screenWidth * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: grey.withOpacity(0.5)),
                          color: grey.withOpacity(.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  onQuantityChanged(item.quantity - 1);
                                }
                              },
                            ),
                            Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: ScreenSize.screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                onQuantityChanged(item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fade(duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .moveY(begin: 50, end: 0, duration: 600.ms)
        .fade(duration: 500.ms);
  }
}
