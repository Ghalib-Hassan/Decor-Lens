import 'package:decor_lens/UI/User%20UI/address_screen.dart';
import 'package:decor_lens/UI/User%20UI/notification_screen.dart';
import 'package:decor_lens/UI/User%20UI/orders_screen.dart';
import 'package:decor_lens/UI/User%20UI/security_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Stack(
              children: [
                Container(
                  height: 185,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: appColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenSize.screenWidth * 0.09,
                        vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Account',
                          style: GoogleFonts.manrope(
                            fontSize: ScreenSize.screenHeight * 0.025,
                            color: white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.notifications_none, size: 30, color: white),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: -0.5, end: 0),

                // Profile Card Animation
                Padding(
                  padding: EdgeInsets.only(
                      left: ScreenSize.screenWidth * 0.05,
                      right: ScreenSize.screenWidth * 0.05,
                      top: 140),
                  child: Container(
                    width: double.infinity,
                    height: 90,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: grey.withOpacity(0.15),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: amber,
                          child: Icon(Icons.person, size: 35, color: white),
                        ).animate().fade(duration: 600.ms).scale(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Claire Copper',
                                style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text('Claire.Copper@gmail.com',
                                  style: GoogleFonts.manrope(
                                      color: black.withOpacity(.7))),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                ).animate().moveY(begin: 100, end: 0, duration: 600.ms),

                // Scattered Bubbles with animation
                for (var position in [
                  {'top': 20.0, 'left': 50.0, 'size': 15.0},
                  {'top': 50.0, 'left': 120.0, 'size': 25.0},
                  {'top': 80.0, 'left': 200.0, 'size': 20.0},
                  {'top': 30.0, 'right': 40.0, 'size': 18.0},
                  {'top': 100.0, 'right': 80.0, 'size': 30.0},
                  {'top': 100.0, 'right': 380.0, 'size': 30.0},
                ])
                  Positioned(
                    top: position['top'] as double,
                    left: position.containsKey('left')
                        ? position['left'] as double
                        : null,
                    right: position.containsKey('right')
                        ? position['right'] as double
                        : null,
                    child: Container(
                      height: position['size'] as double,
                      width: position['size'] as double,
                      decoration: BoxDecoration(
                        color: white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ).animate().fade(duration: 800.ms).scale(delay: 200.ms),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // General Section
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenSize.screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader('General'),
                  ..._buildAnimatedAccountOptions(),
                  const SizedBox(height: 20),
                  sectionHeader('Help'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  /// Section Header Widget
  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.manrope(
            color: black,
            fontSize: ScreenSize.screenHeight * 0.02,
            fontWeight: FontWeight.bold),
      ),
    ).animate().fade(duration: 500.ms).slideX(begin: -0.2, end: 0);
  }

  /// Animated Account Options
  List<Widget> _buildAnimatedAccountOptions() {
    List<Map<String, dynamic>> options = [
      {
        'icon': Icons.delivery_dining,
        'title': 'Orders',
        'screen': OrdersScreen()
      },
      {
        'icon': Icons.bookmark_outline,
        'title': 'Saved Address',
        'screen': AddressScreen()
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'screen': OrdersScreen()
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'screen': NotificationScreen()
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Security',
        'screen': SecurityScreen()
      },
    ];

    return options
        .asMap()
        .entries
        .map((entry) => buildAccountOption(
              icon: entry.value['icon'],
              title: entry.value['title'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => entry.value['screen']),
                );
              },
            ).animate().fade(duration: 500.ms, delay: (entry.key * 100).ms))
        .toList();
  }

  /// Reusable Widget for Account Options
  Widget buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(top: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: ListTile(
          leading: Icon(icon, color: black.withOpacity(.8)),
          title: Text(title, style: GoogleFonts.manrope(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 18, color: black.withOpacity(.8)),
        ),
      ),
    );
  }
}
