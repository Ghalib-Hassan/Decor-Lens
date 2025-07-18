import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/address_screen.dart';
import 'package:decor_lens/UI/User%20UI/faq.dart';
import 'package:decor_lens/UI/User%20UI/notification_screen.dart';
import 'package:decor_lens/UI/User%20UI/orders_screen.dart';
import 'package:decor_lens/UI/User%20UI/privacy_policy.dart';
import 'package:decor_lens/UI/User%20UI/security_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/exit_confirmation.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/bottom_navigation_bar.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final TextEditingController nameController = TextEditingController();
  String? updatedProfileUrl;
  bool isUploading = false;

  void _showEditDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);
    String? updatedProfileUrl;

    Future<String?> uploadToCloudinary(File file) async {
      String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      String uploadPreset = "admin_upload_preset";

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        return data['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: userRef.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final darkModeService = Provider.of<DarkModeService>(context);
            final isDarkMode = darkModeService.isDarkMode;
            final data = snapshot.data!.data() as Map<String, dynamic>;
            nameController.text = data['Name'] ?? '';
            updatedProfileUrl ??= data['Profile_picture'];

            return AlertDialog(
              backgroundColor: isDarkMode ? kOffBlack : white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text('Edit Profile',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? white : black,
                  )),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        File file = File(picked.path);
                        updatedProfileUrl = await uploadToCloudinary(file);
                        (context as Element).markNeedsBuild(); // Refresh dialog
                      }
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: updatedProfileUrl != null
                          ? NetworkImage(updatedProfileUrl!)
                          : null,
                      child: updatedProfileUrl == null
                          ? Icon(Icons.camera_alt,
                              size: 30, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: isDarkMode ? white : black),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                          color: isDarkMode ? white : black.withOpacity(0.7)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel',
                      style: GoogleFonts.manrope(
                          color: isDarkMode ? white : black)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Save',
                      style: GoogleFonts.manrope(color: Colors.white)),
                  onPressed: () async {
                    await userRef.update({
                      'Name': nameController.text,
                      if (updatedProfileUrl != null)
                        'Profile_picture': updatedProfileUrl,
                    });

                    Navigator.of(context).pop(true); // return true

                    SnackbarMessages.profileUpdated();
                  },
                )
              ],
            );
          },
        );
      },
    ).then((value) {
      if (value == true) {
        // Refresh UI after dialog closes
        setState(() {});
      }
    });
  }

  void _openWhatsAppWithMessage(String message) async {
    final phoneNumber = '+923185631699'; // Replace with your WhatsApp number
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$phoneNumber?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not open WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    ScreenSize.init(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => kOnExitConfirmation(),
      child: Scaffold(
        backgroundColor: isDarkMode ? kOffBlack : white,
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
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fade(duration: 500.ms)
                      .slideY(begin: -0.5, end: 0),

                  // Profile Card Animation
                  Padding(
                    padding: EdgeInsets.only(
                      left: ScreenSize.screenWidth * 0.05,
                      right: ScreenSize.screenWidth * 0.05,
                      top: 140,
                    ),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseAuth.instance.currentUser != null
                          ? FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get()
                          : null,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(); // Or a shimmer/skeleton
                        }

                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final String name = userData['Name'] ?? 'No Name';
                        final String email = userData['Email'] ?? 'No Email';
                        final String? profileUrl = userData['Profile_picture'];

                        return Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDarkMode ? kOffBlack : white,
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
                                backgroundImage: profileUrl != null
                                    ? NetworkImage(profileUrl)
                                    : AssetImage('assets/images/default.png')
                                        as ImageProvider,
                              ).animate().fade(duration: 600.ms).scale(),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDarkMode ? white : black,
                                      ),
                                    ),
                                    Text(
                                      email,
                                      style: GoogleFonts.manrope(
                                        color: isDarkMode
                                            ? white
                                            : black.withOpacity(.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showEditDialog(context),
                                child: Icon(
                                  Icons.edit,
                                  color: isDarkMode ? white : black,
                                ),
                              ),
                              const SizedBox(width: 15),
                            ],
                          ),
                        );
                      },
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
                    // ExpansionTile(
                    //   showTrailingIcon: true,
                    //   iconColor: isDarkMode ? white : black,
                    //   title: Text(
                    //     'FAQ',
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: isDarkMode ? white : black),
                    //   ),
                    //   children: [
                    //     ListTile(
                    //       title: Text(
                    //         'How to change password?',
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.w500,
                    //             color: isDarkMode ? white : Colors.black45),
                    //       ),
                    //       onTap: () => _openWhatsAppWithMessage(
                    //           "How do I change my password?"),
                    //     ),
                    //     ListTile(
                    //       title: Text(
                    //         'How to enable 2FA?',
                    //         style: TextStyle(
                    //             fontWeight: FontWeight.w500,
                    //             color: isDarkMode ? white : Colors.black45),
                    //       ),
                    //       onTap: () => _openWhatsAppWithMessage(
                    //           "How do I enable two-factor authentication?"),
                    //     ),
                    //   ],
                    // ).animate().fadeIn(duration: 500.ms),

                    buildAccountOption(
                      icon: Icons.help_outline,
                      title: 'FAQs',
                      onTap: () {
                        Get.to(() => FAQScreen(),
                            transition: Transition.rightToLeft);
                      },
                    ),
                    buildAccountOption(
                      icon: Icons.chat_outlined,
                      title: 'Chat with Support',
                      onTap: () async {
                        const supportNumber =
                            '923185631699'; // Replace with actual WhatsApp number
                        final message = Uri.encodeComponent(
                            'Hi, I need help with my account.');
                        final url =
                            'https://wa.me/$supportNumber?text=$message';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        } else {
                          SnackbarMessages.whatsappError();
                        }
                      },
                    ),
                    buildAccountOption(
                      icon: Icons.feedback_outlined,
                      title: 'Give Feedback',
                      onTap: () {
                        // Navigate to feedback screen or launch email intent
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'hassanghalib239@gmail.com',
                          query:
                              'subject=App Feedback&body=Your feedback here...',
                        );
                        launchUrl(emailUri);
                      },
                    ),
                    buildAccountOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        Get.to(() => PrivacyPolicyScreen(),
                            transition: Transition.rightToLeft);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      ),
    );
  }

  /// Section Header Widget
  Widget sectionHeader(String title) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.manrope(
            color: isDarkMode ? white : black,
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
                Get.to(
                  entry.value['screen'],
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 500),
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
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isDarkMode ? kOffBlack : white,
        margin: const EdgeInsets.only(top: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: ListTile(
          leading: Icon(icon,
              color:
                  isDarkMode ? white.withOpacity(.8) : black.withOpacity(.8)),
          title: Text(title,
              style: GoogleFonts.manrope(
                  fontSize: 16,
                  color: isDarkMode
                      ? white.withOpacity(.8)
                      : black.withOpacity(.8))),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 18,
              color:
                  isDarkMode ? white.withOpacity(.8) : black.withOpacity(.8)),
        ),
      ),
    );
  }
}
