import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/add_address.dart';
import 'package:decor_lens/UI/User%20UI/edit_address.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

/// Address Screen
class AddressScreen extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Your Addresses",
              showLeading: true,
              fontColor: isDarkMode ? white : black,
              leadingIconColor: isDarkMode ? white : black,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomButton(
          buttonBorder: BorderSide(color: appColor),
          buttonHeight: 50,
          buttonWidth: ScreenSize.screenWidth * 0.84,
          buttonColor: isDarkMode ? white : appColor,
          fonts: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? black : white),
          buttonText: 'Add Address',
          onPressed: () {
            Get.to(() => AddAddressScreen(),
                transition: Transition.rightToLeft, duration: 500.ms);
          },
        ).animate().scale(duration: 300.ms),
      ),
      body: uid == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 3,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        height: 100,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    !snapshot.data!.data().toString().contains('addresses')) {
                  return Center(
                    child: Text("No addresses added yet.",
                        style: TextStyle(
                          color: isDarkMode ? white : black,
                          fontSize: 16,
                        )),
                  );
                }

                final addresses = (snapshot.data!.get('addresses') as List);

                if (addresses.isEmpty) {
                  return Center(
                    child: Text(
                      "No addresses added yet.",
                      style: TextStyle(
                        color: isDarkMode ? white : black,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return GestureDetector(
                      onTap: () {
                        Get.back(
                            result:
                                addr); // ⬅️ This sends selected address back
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[900] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black26
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Name and Phone row
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 18, color: appColor),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        addr['Name'] ?? '',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDarkMode ? white : black,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.phone,
                                        size: 16, color: appColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      addr['Phone_number'] ?? '',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                /// Zip Code
                                Row(
                                  children: [
                                    Icon(Icons.local_post_office_outlined,
                                        size: 16, color: appColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Zip: ${addr['Zip_code'] ?? ''}",
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                /// Address
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: red, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        addr['Address'] ?? '',
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: isDarkMode ? white : black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                /// Edit & Delete Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: appColor,
                                      ),
                                      onPressed: () {
                                        Get.to(() => EditAddress(
                                            addressData: addr, index: index));
                                      },
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18),
                                      label: const Text("Edit"),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: red,
                                      ),
                                      onPressed: () async {
                                        final updated = List.from(addresses);
                                        updated.removeAt(index);
                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(uid)
                                            .update({'addresses': updated});
                                      },
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18),
                                      label: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.05),
                    );
                  },
                );
              },
            ),
    );
  }
}
