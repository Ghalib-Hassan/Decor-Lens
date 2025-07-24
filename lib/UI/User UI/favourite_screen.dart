import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/UI/User%20UI/product_screen.dart';
import 'package:decor_lens/Utils/exit_confirmation.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<Map<String, dynamic>> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteItems();
    checkUserBlockedStatus();
  }

  Future<void> fetchFavoriteItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final itemsSnapshot = await FirebaseFirestore.instance
          .collection('Favourite Items')
          .doc(user.uid)
          .collection('Items')
          .get();

      final List<Map<String, dynamic>> fetchedItems =
          itemsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'image': List<String>.from(data['Images'] ?? []),
          'name': data['ItemName'] ?? '',
          'price': data['ItemPrice'].toString(),
          'category': data['Category'] ?? '',
          'description': data['Description'] ?? '',
          'height': data['Height'] ?? '',
          'width': data['Width'] ?? '',
          'space': data['Space'] ?? '',
          'model': data['Model'], // nullable
        };
      }).toList();

      setState(() {
        favoriteItems = fetchedItems;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching favorites: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> checkUserBlockedStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('uid $userId');

    if (userId == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('User_id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        bool isBlocked = userDoc['is_blocked'] ?? false;

        if (isBlocked) {
          SnackbarMessages.accountBlocked();
          FirebaseAuth.instance.signOut();

          final darkModeService =
              Provider.of<DarkModeService>(context, listen: false);
          await darkModeService.clearDarkModePreference();

          Get.offAll(
            () => UserLogin(),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking blocked status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 3;
    double aspectRatio = screenWidth < 600 ? 0.75 : 0.85;

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => kOnExitConfirmation(),
      child: Scaffold(
        backgroundColor: isDarkMode ? kOffBlack : white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: MyAppbar(
            title: "Favourites",
            fontColor: isDarkMode ? white : black,
          ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: ScreenSize.screenHeight * 0.02),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : favoriteItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/no-favorites.png',
                              width: ScreenSize.screenWidth * 0.3,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No favorite items found",
                              style: GoogleFonts.manrope(
                                  color: isDarkMode ? white : black,
                                  fontSize: ScreenSize.screenHeight * 0.017,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        itemCount: favoriteItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          return _buildProductCard(favoriteItems[index], index)
                              .animate()
                              .fade(duration: 600.ms, delay: (index * 100).ms)
                              .moveY(begin: 50, end: 0);
                        },
                      )),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    ScreenSize.init(context);
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductScreen(
            image: product['image'],
            name: product['name'],
            price: product['price'],
            category: product['category'] ?? '',
            description: product['description'] ?? '',
            height: product['height'],
            width: product['width'],
            space: product['space'],
            model: product['model'],
          ),
          transition: Transition.fadeIn,
          duration: 600.ms,
        );
      },
      child: Card(
        color: isDarkMode ? black : white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: product['image'] != null && product['image'].isNotEmpty
                    ? Image.network(
                        product['image'][0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ).animate().fade(duration: 500.ms).scale()
                    : const Center(child: Text('No Image')),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  product['name'],
                  style: GoogleFonts.manrope(
                    color: isDarkMode ? white : black,
                    fontSize: ScreenSize.screenHeight * 0.015,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fade(duration: 400.ms),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs ${product['price']}',
                    style: GoogleFonts.manrope(
                      color: isDarkMode ? white : black,
                      fontSize: ScreenSize.screenHeight * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
