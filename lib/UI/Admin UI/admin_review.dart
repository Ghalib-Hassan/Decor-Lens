import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Services/send_notification_service.dart';
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
                            // Header: Reviewer Avatar + Admin Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.grey.shade300,
                                      child: Text(
                                        (review['name'] ?? 'A')[0]
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      review['name'] ?? 'Anonymous',
                                      style: GoogleFonts.nunitoSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenHeight * 0.019,
                                        color: black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (review['admin_approval'] == false) ...[
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _approveReview(review.id),
                                        icon: Icon(
                                          Icons.check,
                                          size: 14,
                                          color: white,
                                        ),
                                        label: Text('Approve',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: white,
                                            )),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _deleteUserReview(review.id),
                                        icon: Icon(
                                          Icons.delete_forever,
                                          size: 14,
                                          color: white,
                                        ),
                                        label: Text('Delete',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: white,
                                            )),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      IconButton(
                                        tooltip: 'Reply to Review',
                                        icon: Icon(Icons.reply,
                                            color: Colors.blueGrey),
                                        onPressed: () => _showReplyDialog(
                                            context, review.id),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete Review',
                                        icon: Icon(Icons.delete_outline,
                                            color: red),
                                        onPressed: () =>
                                            _deleteUserReview(review.id),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 6),

                            // Review date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reviewed on',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: screenHeight * 0.014,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  review['date'] ?? '',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: screenHeight * 0.014,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Star Rating
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < (review['stars'] ?? 0)
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: yellow,
                                  size: 18,
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // Review Text
                            Text(
                              review['review'] ?? '',
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.nunitoSans(
                                fontSize: screenHeight * 0.017,
                                color: black.withOpacity(0.85),
                                height: 1.4,
                              ),
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
                                  return SizedBox(
                                    height: 40,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5)),
                                  );
                                }

                                if (replySnapshot.hasData &&
                                    replySnapshot.data!.docs.isNotEmpty) {
                                  final adminReply =
                                      replySnapshot.data!.docs[0];

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Divider(
                                            height: 1,
                                            color: Colors.grey.shade400),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Seller replied:',
                                              style: GoogleFonts.nunitoSans(
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenHeight * 0.017,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline,
                                                  color: red, size: 20),
                                              onPressed: () =>
                                                  _deleteAdminReply(review.id),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          adminReply['reply'] ?? '',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: screenHeight * 0.017,
                                            color:
                                                Colors.black.withOpacity(0.85),
                                            height: 1.4,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          adminReply['date'] ?? '',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: screenHeight * 0.014,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
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

  void _approveReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Reviews and Ratings')
          .doc(widget.name)
          .collection('reviews')
          .doc(reviewId)
          .update({'admin_approval': true});

      customSnackbar(
        title: 'Approved',
        message: 'Review has been approved!',
        titleColor: Colors.green,
        icon: Icons.check_circle,
        iconColor: Colors.green,
      );
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Failed to approve review.',
        titleColor: red,
        icon: Icons.error,
        iconColor: red,
      );
    }
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

    final reviewSnap = await reviewRef.get();
    final userToken = reviewSnap['fcm_token']; // get FCM token

    await reviewRef.collection('adminReplies').add({
      'reply': reply,
      'date': formattedDate,
    });

    // Send Notification
    await SendNotificationService.sendNotificationUsingApi(
      token: userToken,
      title: 'Admin replied to your review',
      body: reply,
      topic: null,
      data: {},
    );
    print('send');
    print(userToken);
    print(reviewSnap);
    print(reviewId);
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
}
