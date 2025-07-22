import 'package:decor_lens/Services/get_server_key.dart';
import 'package:decor_lens/Services/notification_services.dart';
import 'package:decor_lens/Utils/exit_confirmation.dart';
import 'package:decor_lens/Utils/home_screen_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Provider/home_screen_provider.dart';
import 'package:decor_lens/UI/User%20UI/account_screen.dart';
import 'package:decor_lens/UI/User%20UI/product_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/home_screen_utils.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationService notificationService = NotificationService();
  final HomeProvider productProvider = HomeProvider();
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      Provider.of<HomeProvider>(context, listen: false).loadFavorites(userId);
      Provider.of<HomeProvider>(context, listen: false).isFavorite(userId);
    }
    productProvider.fetchProducts("Popular");
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    ScreenSize.init(context);
    final int crossAxisCount = ScreenSize.screenWidth < 600 ? 2 : 3;
    final double aspectRatio = ScreenSize.screenWidth < 600 ? 0.75 : 0.85;

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => kOnExitConfirmation(),
      child: Consumer<HomeProvider>(builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: isDarkMode ? kOffBlack : white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Search bar + Notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔍 Search Button
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? grey : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search,
                            size: 26,
                            color: isDarkMode ? white : Colors.black87),
                        onPressed: () {
                          Get.to(() => HomeScreenSearch(),
                              transition: Transition.fadeIn);
                        },
                      ),
                    ),

                    // 🏠 Center Logo and Title
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: isDarkMode
                              ? AssetImage('assets/images/icon-home-512-2.png')
                              : AssetImage('assets/images/icon-home-512.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Decor Lens',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? white : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // 🔔 Notification Button
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.notifications_none,
                            size: 26,
                            color: isDarkMode ? white : Colors.black87),
                        onPressed: () async {
                          GetServerKey getServerKey = GetServerKey();
                          String accesstoken = await getServerKey
                              .getServerKeyToken(); // Navigator.push(context,
                          print(accesstoken);
                          //     MaterialPageRoute(builder: (_) => MyAccount()));
                        },
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms).slideY(begin: -0.3, end: 0),

                const SizedBox(height: 24),

                /// Category List
                SizedBox(
                  height: ScreenSize.screenHeight * 0.09,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: icons.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                          });

                          // Fetch based on selection
                          String selected = names[index];
                          if (selected == 'Popular') {
                            productProvider.fetchProducts("Popular");
                          } else {
                            productProvider.fetchProducts(selected);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDarkMode ? homeListview : kOffBlack)
                                      : (isDarkMode
                                          ? Colors.black26
                                          : homeListview),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    icons[index],
                                    height: 25,
                                    color: isSelected
                                        ? (isDarkMode
                                            ? kOffBlack
                                            : homeListview)
                                        : (isDarkMode
                                            ? homeListview
                                            : kOffBlack),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                names[index],
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isDarkMode ? white : black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// Product Grid
                Expanded(
                  child: FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: productProvider.currentProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: isDarkMode ? white : black),
                        ));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text(
                          'No items found.',
                          style: TextStyle(color: isDarkMode ? white : black),
                        ));
                      }

                      final items = snapshot.data!;
                      return Consumer<HomeProvider>(
                          builder: (context, provider, _) {
                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final List<dynamic>? images = item['Images'];
                            final String itemName = item['ItemName'];
                            final String itemPrice = item['ItemPrice'];

                            return GestureDetector(
                              onTap: () => Get.to(
                                  () => ProductScreen(
                                        image: (images ?? [])
                                            .whereType<String>()
                                            .toList(),
                                        name: itemName,
                                        price: itemPrice,
                                        category: item['Category'] ?? '',
                                        description:
                                            item['ItemDescription'] ?? '',
                                        height: item['Height'] ?? '',
                                        width: item['Width'] ?? '',
                                        space: item['Space'] ?? '',
                                        model: item['Model'] ?? '',
                                      ),
                                  transition: Transition.fadeIn,
                                  duration: 600.ms),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode ? black : white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: grey.withOpacity(0.15),
                                      spreadRadius: 3,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Image with Favorite Icon
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(12)),
                                            child: images != null &&
                                                    images.isNotEmpty
                                                ? Image.network(
                                                    images.first,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  )
                                                : const Center(
                                                    child: Text('No Image')),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Consumer<HomeProvider>(
                                              builder: (context, provider, _) {
                                                final userId = FirebaseAuth
                                                    .instance.currentUser?.uid;
                                                final isFavorite = provider
                                                    .isFavorite(item.id);

                                                return GestureDetector(
                                                  onTap: () {
                                                    if (userId != null) {
                                                      provider.toggleFavorites(
                                                        context: context,
                                                        user_Id: userId,
                                                        itemId: item.id,
                                                        itemData: item.data()
                                                            as Map<String,
                                                                dynamic>,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: white
                                                          .withOpacity(0.9),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    child: Icon(
                                                      isFavorite
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: red,
                                                      size: 20,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    /// Title + Price
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(itemName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.manrope(
                                                  color: isDarkMode
                                                      ? white
                                                      : black,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text('Rs $itemPrice',
                                              style: GoogleFonts.manrope(
                                                color:
                                                    isDarkMode ? white : black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fade(duration: 500.ms)
                                .moveY(begin: 30, end: 0);
                          },
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
        );
      }),
    );
  }
}
