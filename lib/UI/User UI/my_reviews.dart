import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyReviews extends StatefulWidget {
  const MyReviews({super.key});

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MyAppbar(
          title: "My Reviews",
          showLeading: true,
          fontColor: isDarkMode ? white : black,
          leadingIconColor: isDarkMode ? white : black,
        ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('Items').get(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!productSnapshot.hasData ||
                    productSnapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: GoogleFonts.ubuntu(
                        color: isDarkMode ? white : black,
                        fontSize: screenHeight * 0.02,
                      ),
                    ),
                  );
                }

                final productDocs = productSnapshot.data!.docs;

                return FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchUserReviews(productDocs),
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!reviewSnapshot.hasData ||
                        reviewSnapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No reviews yet',
                          style: GoogleFonts.ubuntu(
                            color: isDarkMode ? white : black,
                            fontSize: screenHeight * 0.02,
                          ),
                        ),
                      );
                    }

                    final userReviews = reviewSnapshot.data!;

                    return ListView.builder(
                      itemCount: userReviews.length,
                      itemBuilder: (context, index) {
                        final review = userReviews[index];
                        final String productImage = review['product_image'];
                        final String productName = review['product_name'];
                        final String productPrice =
                            review['product_price'].toString();
                        final String reviewText = review['review'];
                        final double stars = review['stars'];
                        final String reviewDate = review['date'];

                        return buildReviewCard(
                          imageUrl: productImage,
                          productName: productName,
                          price: productPrice,
                          stars: stars,
                          date: reviewDate,
                          reviewText: reviewText,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _fetchUserReviews(
      List<QueryDocumentSnapshot> productDocs) async {
    List<QueryDocumentSnapshot> userReviews = [];
    Set<String> addedReviewIds = {}; // 🔹 Track unique review IDs

    for (var product in productDocs) {
      final String productName = product['ItemName'];

      final reviewSnapshot = await _firestore
          .collection('Reviews and Ratings')
          .doc(productName)
          .collection('reviews')
          .where('user_id', isEqualTo: currentUserID)
          .get();

      for (var review in reviewSnapshot.docs) {
        if (!addedReviewIds.contains(review.id)) {
          userReviews.add(review);
          addedReviewIds.add(review.id);
        }
      }
    }

    return userReviews;
  }
}

Widget buildReviewCard({
  required String imageUrl,
  required String productName,
  required String price,
  required double stars,
  required String date,
  required String reviewText,
  required double screenWidth,
  required double screenHeight,
  required bool isDarkMode,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: isDarkMode
            ? [Colors.grey.shade900, Colors.grey.shade800]
            : [Colors.white, Colors.grey.shade100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode ? Colors.black38 : Colors.grey.withOpacity(0.15),
          blurRadius: 14,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: screenWidth * 0.22,
                height: screenHeight * 0.12,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalizeFirstLetter(productName),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.045,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee,
                          size: screenWidth * 0.038,
                          color: isDarkMode
                              ? Colors.greenAccent
                              : Colors.green.shade800),
                      Text(
                        price,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.038,
                          color: isDarkMode
                              ? Colors.greenAccent
                              : Colors.green.shade800,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < stars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 18,
                  color: Colors.amber,
                );
              }),
            ),
            Text(
              date,
              style: GoogleFonts.nunitoSans(
                fontSize: screenWidth * 0.032,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
              width: 0.8,
            ),
          ),
          child: Text(
            reviewText,
            style: GoogleFonts.nunitoSans(
              fontSize: screenWidth * 0.036,
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    ),
  );
}
