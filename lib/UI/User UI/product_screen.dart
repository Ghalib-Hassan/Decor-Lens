import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Provider/product_screen_provider.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/UI/User%20UI/cart_screen.dart';
import 'package:decor_lens/UI/User%20UI/user_comments.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/admin_product_dimensions.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductScreen extends StatefulWidget {
  final List<String> image;
  final String? model;
  final String name;
  final String price;
  final String description;
  final String height;
  final String width;
  final String space;
  final String category;

  const ProductScreen({
    super.key,
    required this.image,
    this.model,
    required this.name,
    required this.price,
    required this.description,
    required this.height,
    required this.width,
    required this.space,
    required this.category,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // late String mainImage;
  bool isLoading = false;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    checkUserBlockedStatus();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final result = Get.arguments as Map<String, dynamic>?;
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.quantity = 1; // Reset quantity for new product
      provider.initializeMainImage(widget.image);

      if (widget.category == 'Custom') {
        if (result != null && result['reset'] == true) {
          provider.resetCustomDimensions();
        } else {
          provider.fetchCustomItemDimensions(widget.name);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // final thumbnailImages =
    //     widget.image.where((img) => img != provider.mainImage).toList();
    final mediaPages = buildMediaPages(screenWidth, screenHeight);

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? kOffBlack : white,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Main Display (Image or 3D)

              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            children: mediaPages,
                          ),

                          // ← Left Arrow
                          if (_currentIndex > 0)
                            Positioned(
                              left: 10,
                              child: IconButton(
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 28,
                                    color: Colors.black87),
                                onPressed: () {
                                  if (_currentIndex > 0) {
                                    _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                              ),
                            ),

                          // → Right Arrow
                          if (_currentIndex < mediaPages.length - 1)
                            Positioned(
                              right: 10,
                              child: IconButton(
                                icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 28,
                                    color: Colors.black87),
                                onPressed: () {
                                  if (_currentIndex < mediaPages.length - 1) {
                                    _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: mediaPages.length,
                      effect: WormEffect(
                        dotColor: Colors.grey.shade400,
                        activeDotColor: Colors.blueAccent,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(),

              // SizedBox(height: screenHeight * 0.02),

              // /// Thumbnails
              // if (thumbnailImages.isNotEmpty ||
              //     (widget.model != null && widget.model!.isNotEmpty))
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       ...thumbnailImages.map((img) {
              //         return GestureDetector(
              //           onTap: () => provider.switchImage(img),
              //           child: buildThumbnail(img, screenWidth),
              //         );
              //       }),
              //       // ✅ Image thumbnail even if only one image
              //       if (provider.mainImage.isNotEmpty)
              //         GestureDetector(
              //           onTap: () => provider.switchImage(provider.mainImage),
              //           child: buildThumbnail(provider.mainImage, screenWidth),
              //         ),

              //       // ✅ 3D model thumbnail
              //       if (widget.model != null && widget.model!.isNotEmpty)
              //         GestureDetector(
              //           onTap: provider.switchTo3DModel,
              //           child: Padding(
              //             padding: EdgeInsets.symmetric(
              //                 horizontal: screenWidth * 0.01),
              //             child: Container(
              //               width: screenWidth * 0.15,
              //               height: screenWidth * 0.15,
              //               decoration: BoxDecoration(
              //                 boxShadow: [
              //                   BoxShadow(
              //                     color: black.withOpacity(0.08),
              //                     blurRadius: 15,
              //                     spreadRadius: 2,
              //                     offset: const Offset(0, 6),
              //                   ),
              //                   BoxShadow(
              //                     color: white.withOpacity(0.6),
              //                     blurRadius: 8,
              //                     spreadRadius: -6,
              //                     offset: const Offset(-4, -4),
              //                   ),
              //                 ],
              //                 borderRadius: BorderRadius.circular(10),
              //                 border: Border.all(
              //                   color: provider.isModelSelected
              //                       ? appColor
              //                       : Colors.grey.shade300,
              //                   width: 2,
              //                 ),
              //                 color: Colors.grey.shade200,
              //               ),
              //               child: const Center(
              //                 child: Icon(Icons.threed_rotation, size: 28),
              //               ),
              //             ),
              //           ).animate().fadeIn(duration: 500.ms).slideY(),
              //         ),
              //     ],
              //   ).animate().fadeIn(duration: 600.ms).scale(),

              SizedBox(height: screenHeight * 0.015),

              if (widget.category != 'Custom' ||
                  (provider.customHeight.isNotEmpty &&
                      provider.customWidth.isNotEmpty &&
                      provider.customSpace.isNotEmpty))
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: screenWidth * 0.025,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Height: ${widget.category == 'Custom' ? provider.customHeight : widget.height} cm',
                          style: GoogleFonts.manrope(
                            fontSize: screenHeight * 0.017,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text('•', style: TextStyle(fontSize: 18, color: grey)),
                        Text(
                          'Width: ${widget.category == 'Custom' ? provider.customWidth : widget.width} cm',
                          style: GoogleFonts.manrope(
                            fontSize: screenHeight * 0.017,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text('•', style: TextStyle(fontSize: 18, color: grey)),
                        Text(
                          'Space: ${widget.category == 'Custom' ? provider.customSpace : widget.space} cm',
                          style: GoogleFonts.manrope(
                            fontSize: screenHeight * 0.017,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                height: screenHeight * 0.03,
              ),

              /// Product Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.name,
                                style: GoogleFonts.manrope(
                                    color: isDarkMode ? white : black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.055))
                            .animate()
                            .slideX(),
                        // SizedBox(height: screenHeight * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: provider.decrementQuantity,
                              child: Icon(Icons.remove_circle_outline,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: screenWidth * 0.08),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Text(
                              '${provider.quantity}',
                              style: GoogleFonts.manrope(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? white : black,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            GestureDetector(
                              onTap: provider.incrementQuantity,
                              child: Icon(Icons.add_circle_outline,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: screenWidth * 0.08),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Rs ${widget.price}',
                      style: GoogleFonts.manrope(
                          color: isDarkMode ? white : black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500),
                    ).animate().fade(duration: 500.ms),
                    SizedBox(height: screenHeight * 0.01),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Reviews and Ratings')
                          .doc(widget.name)
                          .collection('reviews')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();

                        final allReviews = snapshot.data!.docs;

                        // ✅ Only include approved reviews
                        final approvedReviews = allReviews
                            .where((doc) => doc['admin_approval'] == true)
                            .toList();

                        final totalReviews = approvedReviews.length;

                        double averageRating = 0.0;
                        if (totalReviews > 0) {
                          averageRating = approvedReviews
                                  .map((doc) => doc['stars'] as double)
                                  .reduce((a, b) => a + b) /
                              totalReviews;
                        }

                        return Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: screenWidth * 0.05,
                              color: yellow,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: GoogleFonts.nunitoSans(
                                color: isDarkMode ? white : black,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => UserComments(
                                    price: widget.price,
                                    image: widget.image[0],
                                    name: widget.name,
                                  ),
                                  transition: Transition.rightToLeft,
                                );
                              },
                              child: Text(
                                '($totalReviews review${totalReviews > 1 ? 's' : ''})',
                                style: GoogleFonts.nunitoSans(
                                  color: grey,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    ReadMoreText(
                      '${widget.description}.',
                      style: GoogleFonts.manrope(
                          color: isDarkMode ? white : black.withOpacity(.5),
                          fontSize: screenWidth * 0.04),
                      trimLines: 2,
                      colorClickableText: lightBlueAccent,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'Read more',
                      trimExpandedText: ' Read less',
                      textAlign: TextAlign.justify,
                      moreStyle: GoogleFonts.manrope(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: blueAccent),
                      lessStyle: GoogleFonts.manrope(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: blueAccent),
                    ).animate().fadeIn(duration: 700.ms).slideX(),
                    SizedBox(height: screenHeight * 0.08),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.category == 'Custom'
              ? [
                  GestureDetector(
                    onTap: () async {
                      String userId = FirebaseAuth.instance.currentUser!.uid;

                      final customItemQuery = await FirebaseFirestore.instance
                          .collection('Custom Items')
                          .where('ProductName', isEqualTo: widget.name)
                          .where('userId', isEqualTo: userId)
                          .get();
                      print('custom query ${customItemQuery.docs}');

                      if (customItemQuery.docs.isEmpty) {
                        SnackbarMessages.customizeFirst();

                        return;
                      }

                      var customItem = customItemQuery.docs.first;
                      String customHeight =
                          customItem['Height']?.toString() ?? '';
                      String customWidth =
                          customItem['Width']?.toString() ?? '';
                      String customSpace =
                          customItem['Space']?.toString() ?? '';

                      if (customHeight.trim().isEmpty ||
                          customWidth.trim().isEmpty ||
                          customSpace.trim().isEmpty ||
                          customHeight == '0.0' ||
                          customWidth == '0.0' ||
                          customSpace == '0.0') {
                        SnackbarMessages.customizeFirst();
                        return;
                      }

                      final provider =
                          Provider.of<ProductProvider>(context, listen: false);
                      await FirebaseFirestore.instance
                          .collection('Custom Items')
                          .doc(customItem.id)
                          .update({
                        'Quantity': provider.quantity
                      }); // 👈 Safe update

                      print(
                          '✅ Quantity updated in Firestore: ${provider.quantity}');

                      SnackbarMessages.addToCart();

                      await Get.to(
                        () => Cart(initialTabIndex: 1),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 600),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: kChristmasSilver,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: black,
                        size: screenWidth * 0.08,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.06),
                  CustomButton(
                    buttonColor: isDarkMode ? white : appColor,
                    buttonRadius: 6,
                    buttonWidth: screenWidth * 0.6,
                    buttonHeight: screenHeight * 0.06,
                    buttonText: 'Customize',
                    fonts: GoogleFonts.manrope(
                        color: isDarkMode ? black : white,
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.bold),
                    onPressed: () async {
                      showCustomizationDialog(
                        context,
                        widget.name,
                        widget.description,
                        widget.image[0],
                        widget.price,
                        provider.quantity,
                        widget.height,
                        widget.width,
                        widget.space,
                        widget.category,
                      );
                    },
                  ),
                ]
              : [
                  SizedBox(width: screenWidth * 0.05),
                  CustomButton(
                    buttonColor: isDarkMode ? white : appColor,
                    buttonRadius: 6,
                    buttonHeight: ScreenSize.screenHeight * 0.06,
                    buttonWidth: ScreenSize.screenWidth * 0.83,
                    buttonText: 'Add to cart',
                    isLoading: isLoading,
                    fonts: GoogleFonts.manrope(
                        fontSize: ScreenSize.screenHeight * 0.025,
                        color: isDarkMode ? black : white,
                        fontWeight: FontWeight.bold),
                    onPressed: () async {
                      setState(() => isLoading = true);
                      await provider.addToCart(
                        capitalizeFirstLetter(widget.name),
                        widget.description,
                        widget.image[0],
                        widget.price,
                        widget.height,
                        widget.width,
                        widget.space,
                        widget.category,
                      );
                      setState(() => isLoading = false);
                    },
                  ),
                ],
        ),
      ),
    );
  }

  /// Thumbnail Widget
  Widget buildThumbnail(String imagePath, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: Container(
        width: screenWidth * 0.15,
        height: screenWidth * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: white,
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: white.withOpacity(0.6),
              blurRadius: 6,
              spreadRadius: -4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(),
    );
  }

  List<Widget> buildMediaPages(double screenWidth, double screenHeight) {
    final media = [...widget.image];

    if (widget.model != null && widget.model!.isNotEmpty) {
      media.add("MODEL_VIEW");
    }

    return media.map((item) {
      if (item == "MODEL_VIEW") {
        return Container(
          height: screenHeight * 0.5,
          width: screenWidth * 0.85,
          color: Colors.grey.shade100,
          child: ModelViewer(
            src: widget.model.toString(),
            iosSrc: widget.model.toString(),
            alt: "3D Model",
            ar: true,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: Colors.transparent,
          ),
        );
      } else {
        return Image.network(
          item,
          fit: BoxFit.cover,
          width: screenWidth * 0.85,
          height: screenHeight * 0.5,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      }
    }).toList();
  }

  void showCustomizationDialog(
      BuildContext context,
      String productName,
      String description,
      String image,
      String price,
      int quantity,
      String height,
      String width,
      String space,
      String category) {
    TextEditingController heightController = TextEditingController();
    TextEditingController widthController = TextEditingController();
    TextEditingController spaceController = TextEditingController();

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    // final darkModeService =
    //     Provider.of<DarkModeService>(context, listen: false);
    // final isDarkMode = darkModeService.isDarkMode;

    showGeneralDialog(
      barrierColor: black.withOpacity(0.7),
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Theme(
          data: ThemeData.light(),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 1),
              end: Offset(0, 0),
            ).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOut,
            )),
            child: Dialog(
              backgroundColor: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Customize Product",
                          style: GoogleFonts.ubuntu(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      buildDimensionField(
                        context,
                        "Enter Height",
                        "Height",
                        heightController,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      buildDimensionField(
                        context,
                        "Enter Width",
                        "Width",
                        widthController,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      buildDimensionField(
                        context,
                        "Enter Space",
                        "Space",
                        spaceController,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                            buttonHeight: screenHeight * 0.045,
                            buttonWidth: screenWidth * 0.25,
                            buttonText: 'Add / Update',
                            buttonColor: black,
                            fonts: GoogleFonts.aDLaMDisplay(
                                color: white, fontSize: screenHeight * 0.01),
                            onPressed: () async {
                              if (heightController.text.trim().isEmpty ||
                                  widthController.text.trim().isEmpty ||
                                  spaceController.text.trim().isEmpty) {
                                SnackbarMessages.enterAllDimensions();
                                return;
                              }

                              String userId =
                                  FirebaseAuth.instance.currentUser!.uid;

                              final customItemQuery = await FirebaseFirestore
                                  .instance
                                  .collection('Custom Items')
                                  .where('ProductName', isEqualTo: productName)
                                  .where('userId', isEqualTo: userId)
                                  .get();

                              if (customItemQuery.docs.isNotEmpty) {
                                // Update existing item
                                String docId = customItemQuery.docs.first.id;
                                await FirebaseFirestore.instance
                                    .collection('Custom Items')
                                    .doc(docId)
                                    .update({
                                  'Height': heightController.text,
                                  'Width': widthController.text,
                                  'Space': spaceController.text,
                                });

                                SnackbarMessages.dimensionsUpdated();
                              } else {
                                // Add new custom item
                                await FirebaseFirestore.instance
                                    .collection('Custom Items')
                                    .add({
                                  'userId': userId,
                                  'ProductName': productName,
                                  'Description': description,
                                  'Image': image,
                                  'Price': price,
                                  'AddedAt': DateTime.now(),
                                  'Quantity': provider.quantity,
                                  'Height': heightController.text,
                                  'Width': widthController.text,
                                  'Space': spaceController.text,
                                  'Category': 'Custom',
                                });

                                print(
                                    "🟢 Custom item added for $productName with userId: $userId");
                                SnackbarMessages.customizationDone();
                              }

                              setState(() {
                                provider.customHeight = heightController.text;
                                provider.customWidth = widthController.text;
                                provider.customSpace = spaceController.text;
                              });

                              Navigator.pop(context);
                            },
                          ),
                          CustomButton(
                            buttonHeight: screenHeight * 0.045,
                            buttonWidth: screenWidth * 0.25,
                            buttonBorder: BorderSide(color: red),
                            buttonText: 'Cancel',
                            buttonColor: Colors.redAccent,
                            fonts: GoogleFonts.aDLaMDisplay(color: white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
