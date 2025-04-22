import 'package:decor_lens/UI/User%20UI/account_screen.dart';
import 'package:decor_lens/UI/User%20UI/product_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/home_screen_utils.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    final int crossAxisCount =
        ScreenSize.screenWidth < 600 ? 2 : 3; // Responsive grid

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Search Bar & Notifications**
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyAccount()),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),

            const SizedBox(height: 20),

            /// **Category ListView**
            SizedBox(
              height: ScreenSize.screenHeight * 0.09,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: homeListview),
                          child: Icon(
                            icons[index],
                            color: black,
                            size: 25,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          names[index],
                          style: GoogleFonts.manrope(fontSize: 12),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 600.ms).slideX(begin: 0.2, end: 0);
                },
              ),
            ),

            /// **Product GridView (Responsive)**
            Expanded(
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Dynamic columns
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 25,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => ProductScreen(),
                          transition: Transition.fadeIn,
                          duration: Duration(milliseconds: 600));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.3),
                              spreadRadius: 4,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          color: white,
                        ),
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.favorite,
                                      size: 25,
                                    ),
                                  ),
                                )),
                            Column(
                              children: [
                                /// **Product Image**
                                Expanded(
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.contain,
                                  ).animate().fade(duration: 500.ms).scale(),
                                ),

                                /// **Product Name**
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      texts[index],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.manrope(
                                        fontSize:
                                            ScreenSize.screenHeight * 0.015,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ).animate().fade(duration: 400.ms),
                                  ),
                                ),

                                /// **Price & Add to Cart**
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          prices[index],
                                          style: TextStyle(
                                            fontSize:
                                                ScreenSize.screenHeight * 0.02,
                                            fontWeight: FontWeight.bold,
                                            color: black,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: ScreenSize.screenHeight *
                                                    0.014,
                                                color: yellow,
                                              ),
                                              SizedBox(
                                                  width:
                                                      ScreenSize.screenWidth *
                                                          0.02),
                                              Text(
                                                '4.9 (132)',
                                                style: GoogleFonts.nunitoSans(
                                                    fontSize: ScreenSize
                                                            .screenHeight *
                                                        0.014),
                                              ),
                                            ],
                                          )
                                              .animate()
                                              .slideX(begin: 0.2, end: 0),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .moveY(begin: 100, end: 0, duration: 600.ms)
                        .fade(duration: 500.ms),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
