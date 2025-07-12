import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key, required this.image, required this.name});

  final String image;
  final String name;

  @override
  _AdminReviewScreenState createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: ThemeData.light(), // Force light mode on this screen
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              MyAppbar(
                title: "Rating & Review",
                textStyle: GoogleFonts.poppins(
                  fontSize: screenHeight * 0.028,
                  fontWeight: FontWeight.w700,
                ),
                showLeading: true,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Product & Average Rating Section
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                              style: GoogleFonts.nunitoSans(
                                color: black,
                                fontSize: screenHeight * 0.025,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Row(
                              children: [
                                Icon(Icons.star, size: 30, color: yellow),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: GoogleFonts.nunitoSans(
                                    color: black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.02,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              '$totalReviews review${totalReviews > 1 ? 's' : ''}',
                              style: GoogleFonts.nunitoSans(
                                color: black,
                                fontSize: screenHeight * 0.015,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Reviews Section
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

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text(
                      'No reviews found',
                      style: GoogleFonts.nunitoSans(
                        color: grey,
                        fontSize: screenHeight * 0.015,
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final review = snapshot.data!.docs[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        color: white.withOpacity(1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row with icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.person),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.reply, color: black),
                                      onPressed: () =>
                                          _showReplyDialog(context, review.id),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: red, size: 20),
                                      onPressed: () =>
                                          _deleteUserReview(review.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Reviewer name and date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review['name'] ?? 'Anonymous',
                                  style: GoogleFonts.nunitoSans(
                                    color: black,
                                    fontSize: screenHeight * 0.02,
                                  ),
                                ),
                                Text(
                                  review['date'] ?? '',
                                  style: GoogleFonts.nunitoSans(
                                    color: grey,
                                    fontSize: screenHeight * 0.015,
                                  ),
                                ),
                              ],
                            ),

                            // Star Rating
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < (review['stars'] ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 15,
                                  color: yellow,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),

                            // User Review Text
                            Text(
                              review['review'] ?? '',
                              style: GoogleFonts.nunitoSans(
                                color: grey,
                                fontSize: screenHeight * 0.018,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(height: screenHeight * 0.01),

                            // Admin Reply Section
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
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (replySnapshot.hasData &&
                                    replySnapshot.data!.docs.isNotEmpty) {
                                  final adminReply =
                                      replySnapshot.data!.docs[0];

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Seller Replied:',
                                              style: GoogleFonts.nunitoSans(
                                                color: black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenHeight * 0.02,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: red, size: 20),
                                              onPressed: () =>
                                                  _deleteAdminReply(review.id),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                adminReply['reply'] ?? '',
                                                style: GoogleFonts.nunitoSans(
                                                  color: black,
                                                  fontSize: screenHeight * 0.02,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              adminReply['date'] ?? '',
                                              style: GoogleFonts.nunitoSans(
                                                color: black,
                                                fontSize: screenHeight * 0.015,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                      ],
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.003),
            ],
          ),
        ),
      ),
    );
  }

  // Reply Dialog
  void _showReplyDialog(BuildContext context, String reviewId) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light(),
          child: AlertDialog(
            title: Text('Seller Replied'),
            content: TextField(
              controller: replyController,
              decoration: InputDecoration(hintText: 'Add a comment....'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (replyController.text.trim().isEmpty) {
                    customSnackbar(
                      title: "Error",
                      message: "Fields should not be empty",
                      titleColor: red,
                      icon: Icons.error_outline,
                      iconColor: red,
                    );
                    return;
                  }

                  final replySnapshot = await FirebaseFirestore.instance
                      .collection('Reviews and Ratings')
                      .doc(widget.name)
                      .collection('reviews')
                      .doc(reviewId)
                      .collection('adminReplies')
                      .get();

                  if (replySnapshot.docs.isNotEmpty) {
                    customSnackbar(
                      title: "Warning",
                      message: "Only reply at once",
                      titleColor: red,
                      icon: Icons.warning_amber,
                      iconColor: red,
                    );
                    Navigator.of(context).pop();
                    return;
                  }

                  _submitAdminReply(reviewId, replyController.text.trim());
                  Navigator.of(context).pop();
                },
                child: Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Submit admin reply
  void _submitAdminReply(String reviewId, String reply) async {
    final formattedDate =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    final reviewRef = FirebaseFirestore.instance
        .collection('Reviews and Ratings')
        .doc(widget.name)
        .collection('reviews')
        .doc(reviewId);

    // final reviewSnap = await reviewRef.get();
    // final userToken = reviewSnap['fcm_token']; // get FCM token
    // final userId = reviewSnap['user_id']; // optional if used in navigation

    await reviewRef.collection('adminReplies').add({
      'reply': reply,
      'date': formattedDate,
    });

    // Send Notification
    // await SendNotificationService.sendNotificationUsingApi(
    //   token: userToken,
    //   title: 'Admin replied to your review',
    //   body: reply,
    //   data: { 'screen': 'review_screen' },
    // );
    // print('send');
  }

  // Delete the admin reply
  void _deleteAdminReply(String reviewId) async {
    final repliesSnapshot = await FirebaseFirestore.instance
        .collection('Reviews and Ratings')
        .doc(widget.name)
        .collection('reviews')
        .doc(reviewId)
        .collection('adminReplies')
        .get();

    if (repliesSnapshot.docs.isNotEmpty) {
      await repliesSnapshot.docs.first.reference.delete();
    }
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
