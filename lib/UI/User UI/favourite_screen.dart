import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class Product {
  final String image;
  final String name;
  final String price;
  final bool isFavorite;

  Product({
    required this.image,
    required this.name,
    required this.price,
    this.isFavorite = false,
  });

  // CopyWith Method for State Updates
  Product copyWith({bool? isFavorite}) {
    return Product(
      image: image,
      name: name,
      price: price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<Product> favoriteProducts = [
    Product(
        image: 'assets/images/chairs/chair1.jpg',
        name: 'Modern Black Lamp',
        price: '\$450'),
    Product(
        image: 'assets/images/chairs/chair2.jpg',
        name: 'Modern Lemon Chair',
        price: '\$300'),
    Product(
        image: 'assets/images/chairs/chair3.jpg',
        name: 'Modern Foam Chair',
        price: '\$500'),
    Product(
        image: 'assets/images/chairs/chair4.jpg',
        name: 'Modern White Chair',
        price: '\$600'),
    Product(
        image: 'assets/images/chairs/chair5.jpg',
        name: 'Modern Mix Chair',
        price: '\$700'),
    Product(
        image: 'assets/images/chairs/chair6.jpg',
        name: 'Modern Plastic Chair',
        price: '\$800'),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 3;
    double aspectRatio = screenWidth < 600 ? 0.75 : 0.85;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(title: "Favorites")
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchBar()
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: -0.3, end: 0),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: favoriteProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  return _buildProductCard(favoriteProducts[index], index)
                      .animate()
                      .fade(duration: 600.ms, delay: (index * 100).ms)
                      .moveY(begin: 50, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }

  /// Search Bar Widget
  Widget _buildSearchBar() {
    return TextField(
      keyboardType: TextInputType.text,
      style: TextStyle(color: black),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: white,
        hintText: 'Search Table',
        hintStyle: GoogleFonts.manrope(color: homeSearch),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  /// Product Card Widget
  Widget _buildProductCard(Product product, int index) {
    ScreenSize.init(context);
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  product.image,
                  fit: BoxFit.contain,
                ).animate().fade(duration: 500.ms).scale(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: ScreenSize.screenHeight * 0.015,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fade(duration: 400.ms),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.price,
                        style: TextStyle(
                          fontSize: ScreenSize.screenHeight * 0.02,
                          fontWeight: FontWeight.bold,
                          color: black,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: ScreenSize.screenWidth * 0.05,
                            color: yellow,
                          ),
                          SizedBox(width: ScreenSize.screenWidth * 0.02),
                          Text(
                            '4.9 (132)',
                            style: GoogleFonts.nunitoSans(
                                fontSize: ScreenSize.screenWidth * 0.03),
                          ),
                        ],
                      ).animate().slideX(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .moveY(begin: 100, end: 0, duration: 600.ms)
          .fade(duration: 500.ms),
    );
  }
}
