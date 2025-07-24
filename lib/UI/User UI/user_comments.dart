import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class UserComments extends StatefulWidget {
  const UserComments(
      {super.key,
      required this.image,
      required this.name,
      required this.price});

  final String image;
  final String name;
  final String price;

  @override
  State<UserComments> createState() => _UserCommentsState();
}

class _UserCommentsState extends State<UserComments> {
  TextEditingController nameController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    checkUserBlockedStatus();
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

  Future<void> fetchUserName() async {
    try {
      final userId = auth.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userName = userDoc['Name'];
        setState(() {
          nameController.text = userName; // Populate the controller
        });
        debugPrint(userName);
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: isDarkMode ? black : white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyAppbar(title: 'Rating & Review', showLeading: true),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.image,
                      width: screenWidth * 0.25,
                      height: screenHeight * 0.12,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Reviews and Ratings')
                        .doc(widget.name)
                        .collection('reviews')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data?.docs ?? [];
                      final totalReviews = reviews.length;

                      double averageRating = 0.0;
                      if (totalReviews > 0) {
                        averageRating = reviews
                                .map((doc) => doc['stars'] as double)
                                .reduce((a, b) => a + b) /
                            totalReviews;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            widget.name.toUpperCase(),
                            style: GoogleFonts.manrope(
                                color: isDarkMode ? white : black,
                                fontSize: screenHeight * 0.025),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 30,
                                color: yellow,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: GoogleFonts.manrope(
                                    color: isDarkMode ? white : black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.02),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            '$totalReviews review${totalReviews > 1 ? 's' : ''}',
                            style: GoogleFonts.manrope(
                                color: isDarkMode ? white : black,
                                fontSize: screenHeight * 0.015),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Reviews Section
            FutureBuilder(
              future: Future.delayed(Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  // ⏳ Show shimmer for 3 seconds
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: grey.withOpacity(.1),
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        height: 10, width: 100, color: white),
                                    const SizedBox(height: 6),
                                    Container(
                                        height: 10, width: 200, color: white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // ✅ Show actual reviews after 3 seconds
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Reviews and Ratings')
                        .doc(widget.name)
                        .collection('reviews')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(); // fallback if needed
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No reviews found',
                            style: GoogleFonts.manrope(
                              color: grey,
                              fontSize: screenHeight * 0.015,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final review = docs[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? black : white.withOpacity(1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: grey.withOpacity(.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔠 User Info Row
                                Row(
                                  children: [
                                    Container(
                                      height: screenHeight * 0.045,
                                      width: screenHeight * 0.045,
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? white : black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          review['name']
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: GoogleFonts.manrope(
                                            color: isDarkMode ? black : white,
                                            fontSize: screenHeight * 0.025,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Text(
                                        review['name'] ?? 'Anonymous',
                                        style: GoogleFonts.nunitoSans(
                                          color: isDarkMode ? white : black,
                                          fontSize: screenHeight * 0.02,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: review['user_id'] ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid,
                                      child: PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert,
                                            color: isDarkMode ? white : black),
                                        onSelected: (String choice) {
                                          if (choice == 'Edit') {
                                            _showEditDialog(
                                                review.id, review['review']);
                                          } else if (choice == 'Delete') {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext) {
                                                return Theme(
                                                  data: ThemeData.light(),
                                                  child: AlertDialog(
                                                    title: Text(
                                                      'Delete Comment?',
                                                      style: GoogleFonts
                                                          .merriweather(
                                                        color: black,
                                                        fontSize:
                                                            screenHeight * 0.02,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('Cancel',
                                                            style: GoogleFonts
                                                                .ubuntu(
                                                                    color:
                                                                        grey)),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                      TextButton(
                                                        child: Text('Delete',
                                                            style: GoogleFonts
                                                                .ubuntu(
                                                                    color:
                                                                        red)),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _deleteUserReview(
                                                              review.id);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'Edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'Delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                // 🌟 Stars and Date
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        review['date'] ?? 'Unknown Date',
                                        style: GoogleFonts.nunitoSans(
                                          color: Colors.blueGrey,
                                          fontSize: screenHeight * 0.016,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      for (int i = 0; i < 5; i++)
                                        Icon(
                                          i < (review['stars'] ?? 0)
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: yellow,
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                // 📝 Review Text
                                Text(
                                  review['review'] ?? '',
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.nunitoSans(
                                    color: grey,
                                    fontSize: screenHeight * 0.018,
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                // 🧑‍💼 Admin Reply (if any)
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Reviews and Ratings')
                                      .doc(widget.name)
                                      .collection('reviews')
                                      .doc(review.id)
                                      .collection('adminReplies')
                                      .snapshots(),
                                  builder: (context, replySnapshot) {
                                    if (replySnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox(); // Optional shimmer
                                    }
                                    if (replySnapshot.hasData &&
                                        replySnapshot.data!.docs.isNotEmpty) {
                                      final adminReply =
                                          replySnapshot.data!.docs[0];
                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(top: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: grey.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Seller Replied:',
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: screenHeight * 0.019,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isDarkMode ? white : black,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              adminReply['reply'] ?? '',
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: screenHeight * 0.018,
                                                color:
                                                    isDarkMode ? white : black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: screenHeight * 0.08),
          ],
        ),
      ),
      floatingActionButton: CustomButton(
        buttonColor: isDarkMode ? white : appColor,
        buttonWidth: screenWidth * 0.925,
        buttonHeight: screenHeight * 0.06,
        fonts: GoogleFonts.nunitoSans(
            color: isDarkMode ? black : white, fontSize: screenHeight * 0.02),
        buttonText: 'Write a review',
        onPressed: () {
          showReviewDialog(context);
        },
      ),
    );
  }

  void showReviewDialog(BuildContext context) {
    final TextEditingController reviewController = TextEditingController();
    final screenHeight = MediaQuery.of(context).size.height;
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: white,
          title: Text('Write a Review',
              style: GoogleFonts.mPlus1(
                fontSize: screenHeight * 0.03,
                color: black,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: GoogleFonts.nunitoSans(
                  fontSize: screenHeight * 0.02,
                  color: black,
                ),
                controller: nameController,
                decoration: InputDecoration(
                    hintText: nameController.text.isEmpty
                        ? 'Enter your name'
                        : nameController.text,
                    hintStyle: GoogleFonts.nunitoSans(
                      fontSize: screenHeight * 0.02,
                      color: black,
                    )),
              ),
              TextField(
                style: GoogleFonts.nunitoSans(
                    fontSize: screenHeight * 0.02, color: black),
                controller: reviewController,
                decoration: InputDecoration(
                    hintText: 'Your Review',
                    hintStyle: GoogleFonts.nunitoSans(
                      fontSize: screenHeight * 0.02,
                      color: black,
                    )),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Rating',
                      style: GoogleFonts.nunitoSans(
                          color: black, fontSize: screenHeight * 0.02)),
                  AnimatedRatingStars(
                    initialRating: rating,
                    customFilledIcon: Icons.star,
                    customHalfFilledIcon: Icons.star_half,
                    customEmptyIcon: Icons.star_border,
                    onChanged: (value) {
                      rating = value;
                    },
                    filledColor: yellow,
                    starSize: 20,
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.nunitoSans(
                      fontSize: screenHeight * 0.013, color: Colors.blueGrey)),
            ),
            TextButton(
              onPressed: () async {
                // NotificationService notificationService = NotificationService();
                // String userToken =
                //     await notificationService.getDeviceToken(); // ✅ Await here
                // print('FCM Token: $userToken');
                final currentDate = DateTime.now();
                final formattedDate =
                    '${currentDate.day}/${currentDate.month}/${currentDate.year}';

                if (nameController.text.trim().isEmpty ||
                    reviewController.text.trim().isEmpty) {
                  SnackbarMessages.emptyFieldsError();

                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('Reviews and Ratings')
                      .doc(widget.name)
                      .collection('reviews')
                      .add({
                    'user_id': FirebaseAuth.instance.currentUser?.uid,
                    'name': nameController.text.trim().toUpperCase(),
                    'review': reviewController.text.trim(),
                    'stars': rating,
                    'date': formattedDate,
                    'product_name': widget.name,
                    'product_price': widget.price,
                    'product_image': widget.image,
                    // 'fcmToken': userToken, // store FCM token here
                  });
                  SnackbarMessages.commentPosted();

                  Navigator.pop(context);
                } catch (e) {
                  SnackbarMessages.failedToPostComment();
                }
              },
              child: Text('Post Review',
                  style: GoogleFonts.nunitoSans(
                      fontSize: screenHeight * 0.013, color: Colors.blueGrey)),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String reviewId, String existingReviewText) {
    final TextEditingController _editController =
        TextEditingController(text: existingReviewText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Review',
              style: GoogleFonts.merriweather(fontSize: 18)),
          content: TextField(
            controller: _editController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Update your comment',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: GoogleFonts.ubuntu(color: grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child:
                  Text('Save', style: GoogleFonts.ubuntu(color: Colors.green)),
              onPressed: () async {
                final updatedReview = _editController.text.trim();
                if (updatedReview.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('Reviews and Ratings')
                      .doc(widget.name)
                      .collection('reviews')
                      .doc(reviewId)
                      .update({'review': updatedReview});
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Delete the user review
  void _deleteUserReview(String reviewId) async {
    await FirebaseFirestore.instance
        .collection('Reviews and Ratings')
        .doc(widget.name)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }
}
