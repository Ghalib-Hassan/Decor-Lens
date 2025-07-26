import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/UI/Admin%20UI/admin_review.dart';
import 'package:decor_lens/UI/Admin%20UI/edit_customizable.dart';
import 'package:decor_lens/UI/Admin%20UI/edit_item.dart';
import 'package:decor_lens/UI/Admin%20UI/image_detail.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminViewItems extends StatefulWidget {
  const AdminViewItems({super.key});

  @override
  State<AdminViewItems> createState() => _AdminViewItemsState();
}

class _AdminViewItemsState extends State<AdminViewItems> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 7,
      child: Theme(
        data: ThemeData.light(),
        child: Scaffold(
          backgroundColor: adminBack,
          appBar: AppBar(
            backgroundColor: adminAppbar,
            elevation: 2,
            title: Text(
              'View Items',
              style: GoogleFonts.poppins(
                fontSize: screenHeight * 0.028,
                color: white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: white),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
            bottom: TabBar(
              indicatorColor: white,
              isScrollable: true,
              labelColor: white,
              unselectedLabelColor: white.withOpacity(0.7),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: screenHeight * 0.029,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: screenHeight * 0.018,
              ),
              tabs: const [
                Tab(text: 'Bed'),
                Tab(text: 'Chair'),
                Tab(text: 'Sofa'),
                Tab(text: 'Stool'),
                Tab(text: 'Table'),
                Tab(text: 'Wardrobe'),
                Tab(text: 'Custom'),
              ],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() {}),
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: screenHeight * 0.020,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search by product name...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                    ),
                  ),
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    CategoryTab(
                        category: 'Bed', searchController: searchController),
                    CategoryTab(
                        category: 'Chair', searchController: searchController),
                    CategoryTab(
                        category: 'Sofa', searchController: searchController),
                    CategoryTab(
                        category: 'Stool', searchController: searchController),
                    CategoryTab(
                        category: 'Table', searchController: searchController),
                    CategoryTab(
                        category: 'Wardrobe',
                        searchController: searchController),
                    CategoryTab(
                        category: 'Custom', searchController: searchController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTab extends StatefulWidget {
  final String category;
  final TextEditingController searchController;

  const CategoryTab(
      {super.key, required this.category, required this.searchController});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  Future<List<QueryDocumentSnapshot>> fetchItems() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Items')
        .where('Category', isEqualTo: widget.category)
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData.light(), // Force light mode on this screen

      child: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.aBeeZee(
                  color: black, fontSize: screenHeight * 0.02),
            ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'No items found in ${widget.category}.',
              style: GoogleFonts.aBeeZee(
                  color: black, fontSize: screenHeight * 0.022),
            ));
          }

          // Filter items based on search input
          final filteredItems = snapshot.data!.where((item) {
            String itemName = item['ItemName'].toString().toLowerCase();
            return itemName
                .contains(widget.searchController.text.toLowerCase());
          }).toList();

          if (filteredItems.isEmpty) {
            return Center(
                child: Text(
              'No matching items found.',
              style: GoogleFonts.aBeeZee(
                  color: black, fontSize: screenHeight * 0.022),
            ));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];

              // Check if the 'images' field is not empty and retrieve the first image URL
              String imageUrl = (item['Images'] != null &&
                      item['Images'].isNotEmpty)
                  ? item['Images'][0]
                  : 'https://via.placeholder.com/150'; // Placeholder image if no images

              return FadeInUp(
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: Colors.black26,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: GestureDetector(
                        onTap: () {
                          Get.to(
                              () => ImageDetailScreen(
                                  imageUrl: imageUrl, heroTag: item.id),
                              transition: Transition.fadeIn);
                        },
                        child: Hero(
                          tag: item.id,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        item['ItemName'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Price: Rs ${item['ItemPrice']}',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: blueAccent),
                            onPressed: () async {
                              if (widget.category == 'Custom') {
                                final result = await Get.to(
                                    () => EditCustomizableItem(
                                          item: item,
                                        ),
                                    transition: Transition.fadeIn);
                                if (result == 'updated') {
                                  setState(() {});
                                }
                              } else {
                                final result = await Get.to(
                                    () => EditItems(
                                          item: item,
                                        ),
                                    transition: Transition.fadeIn);
                                if (result == 'updated') {
                                  setState(() {});
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              // ignore: unused_local_variable
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    title: Text(
                                      "Delete Item",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete this item?",
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text("Cancel",
                                            style: GoogleFonts.poppins(
                                                fontSize: 14)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Items')
                                              .doc(item.id)
                                              .delete();
                                          Navigator.of(context).pop(true);
                                          customSnackbar(
                                              title: 'Item Deleted',
                                              message:
                                                  'Item has been deleted successfully',
                                              messageColor: black,
                                              titleColor: green,
                                              icon: Icons.delete_outline,
                                              iconColor: green,
                                              backgroundColor: white);

                                          setState(() {});
                                        },
                                        child: Text(
                                          "Delete",
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.redAccent),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () => Get.to(
                          () => AdminReviewScreen(
                              image: imageUrl, name: item['ItemName']),
                          transition: Transition.fadeIn)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
