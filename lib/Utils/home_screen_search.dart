import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/product_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreenSearch extends StatefulWidget {
  const HomeScreenSearch({super.key});

  @override
  State<HomeScreenSearch> createState() => _HomeScreenSearchState();
}

class _HomeScreenSearchState extends State<HomeScreenSearch> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context, listen: true);
    final isDarkMode = darkModeService.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDarkMode ? black : white,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {}); // Refresh UI on search input change
                },
                decoration: InputDecoration(
                  hintText: "Search products...",
                  hintStyle: TextStyle(color: isDarkMode ? white : black),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: isDarkMode ? white : black),
              ),
            ),
            if (searchController
                .text.isNotEmpty) // Show clear button only if text exists
              IconButton(
                icon: Icon(Icons.clear,
                    color: isDarkMode ? white : black, size: 20),
                onPressed: () {
                  searchController.clear(); // Clear text field
                  setState(() {}); // Refresh UI after clearing
                },
              ),
          ],
        ),
        backgroundColor: isDarkMode ? black : white,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new, color: isDarkMode ? white : black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Items').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(
                          color: isDarkMode ? white : black),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No Matching Products Found 🥺",
                      style: TextStyle(
                        color: isDarkMode ? white : grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final items = snapshot.data!.docs;

                // Convert filteredItems to a List
                final filteredItems = items.where((doc) {
                  final itemName = (doc['ItemName'] as String).toLowerCase();
                  return itemName.contains(searchController.text.toLowerCase());
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      "No Matching Products Found 🥺",
                      style: TextStyle(
                        color: isDarkMode ? white : grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: GridView.builder(
                    itemCount: filteredItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.55,
                      mainAxisSpacing: 30,
                      crossAxisSpacing: 0,
                    ),
                    itemBuilder: (context, index) {
                      var item =
                          filteredItems[index]; // ✅ Get the correct document

                      final List<dynamic> productImages = item['Images'] ?? [];

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => ProductScreen(
                              image:
                                  (productImages).whereType<String>().toList(),
                              name: item['ItemName'],
                              price: item['ItemPrice'].toString(),
                              description: item['ItemDescription'],
                              model: item['Model'],
                              height: item['Height'],
                              width: item['Width'],
                              space: item['Space'],
                              category: item['Category'],
                            ),
                            duration: const Duration(milliseconds: 500),
                            transition: Transition.fade,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.height * 0.15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: isDarkMode ? black : white,
                                boxShadow: [
                                  BoxShadow(
                                    color: grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: (productImages.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Hero(
                                        tag: item.id,
                                        child: Image.network(
                                          productImages.first,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'No Image',
                                        style: GoogleFonts.nunitoSans(
                                          color: isDarkMode ? grey : black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                capitalizeFirstLetter(item['ItemName']),
                                style: GoogleFonts.nunitoSans(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? grey : black,
                                  fontSize: screenHeight * 0.014,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                'Rs ${item['ItemPrice']}',
                                style: GoogleFonts.nunitoSans(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? white : black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
