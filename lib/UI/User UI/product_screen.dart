import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Provider/product_screen_provider.dart';
import 'package:decor_lens/UI/User%20UI/cart_screen.dart';
import 'package:decor_lens/UI/User%20UI/user_comments.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/admin_product_dimensions.dart';
import 'package:decor_lens/Widgets/capitalize_first_letter.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

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

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
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
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final thumbnailImages =
        widget.image.where((img) => img != provider.mainImage).toList();

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: provider.isModelSelected &&
                          widget.model != null &&
                          widget.model!.isNotEmpty
                      ? Container(
                          height: screenHeight * 0.5,
                          width: screenWidth * 0.85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                          ),
                          child: ModelViewer(
                            src: widget.model.toString(),
                            iosSrc: widget.model.toString(),
                            alt: "3D Model",
                            ar: true,
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                          ),
                        )
                      : Image.network(
                          provider.mainImage,
                          height: screenHeight * 0.5,
                          width: screenWidth * 0.85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(),

              SizedBox(height: screenHeight * 0.02),

              /// Thumbnails
              if (thumbnailImages.isNotEmpty ||
                  (widget.model != null && widget.model!.isNotEmpty))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...thumbnailImages.map((img) {
                      return GestureDetector(
                        onTap: () => provider.switchImage(img),
                        child: buildThumbnail(img, screenWidth),
                      );
                    }),
                    if (widget.model != null && widget.model!.isNotEmpty)
                      GestureDetector(
                        onTap: provider.switchTo3DModel,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01),
                          child: Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: black
                                      .withOpacity(0.08), // subtle outer shadow
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color:
                                      white.withOpacity(0.6), // inner-like glow
                                  blurRadius: 8,
                                  spreadRadius: -6,
                                  offset: const Offset(-4, -4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: provider.isModelSelected
                                    ? appColor
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              color: Colors.grey.shade200,
                            ),
                            child: const Center(
                              child: Icon(Icons.threed_rotation, size: 28),
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(),
                      ),
                  ],
                ).animate().fadeIn(duration: 600.ms).scale(),

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
                    // GestureDetector(
                    //   onTap: () {
                    //     Get.to(
                    //         () => UserComments(
                    //               price: widget.price,
                    //               image: widget.image[0],
                    //               name: widget.name,
                    //             ),
                    //         transition: Transition.rightToLeft);
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.star,
                    //           color: amber, size: screenWidth * 0.05),
                    //       SizedBox(width: screenWidth * 0.01),
                    //       Text('4.9 (256)',
                    //           style: GoogleFonts.manrope(
                    //               color: black.withOpacity(.5),
                    //               fontSize: screenWidth * 0.04)),
                    //     ],
                    //   ).animate().scale(),
                    // ),

                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Reviews and Ratings')
                            .doc(widget.name)
                            .collection('reviews')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final reviews = snapshot.data?.docs ?? [];
                          final totalReviews = reviews.length;

                          double averageRating = 0.0;
                          if (totalReviews > 0) {
                            averageRating = reviews
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
                                    fontSize: screenWidth * 0.05),
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
                                      transition: Transition.rightToLeft);
                                },
                                child: Text(
                                  '($totalReviews review${totalReviews > 1 ? 's' : ''})',
                                  style: GoogleFonts.nunitoSans(
                                      color: grey,
                                      fontSize: screenWidth * 0.045),
                                ),
                              ),
                            ],
                          );
                        }),
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
                      print(customItemQuery.docs);

                      if (customItemQuery.docs.isEmpty) {
                        customSnackbar(
                            title: 'Customize the product first',
                            message: 'Please customize the product first',
                            titleColor: red,
                            icon: Icons.warning_amber,
                            iconColor: red);
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
                        customSnackbar(
                            title: 'Customize the product first',
                            message: 'Please customize the product first',
                            titleColor: red,
                            icon: Icons.warning_amber,
                            iconColor: red);
                        return;
                      }

                      await Get.to(
                        () => Cart(
                            initialTabIndex:
                                1), // Navigate to the second tab (index starts from 0)
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
                      // child: Consumer<ProductScreenProvider>(
                      //   builder: (context, provider, child) {
                      //     return Icon(
                      //       Icons.shopping_bag_outlined,
                      //       color: black,
                      //       size: screenWidth * 0.08,
                      //     );
                      //   },
                      // ),
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
                    isLoading: provider.isLoading,
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
                  // GestureDetector(
                  //   onTap: () {
                  //     toggleBookmark(
                  //       widget.name,
                  //       widget.description,
                  //       widget.price,
                  //       widget.image[0],
                  //       widget.height,
                  //       widget.width,
                  //       widget.space,
                  //       widget.category,
                  //     );
                  //   },
                  //   child: Container(
                  //     height: 60,
                  //     width: 60,
                  //     decoration: BoxDecoration(
                  //       color: kChristmasSilver,
                  //       borderRadius: BorderRadius.circular(16),
                  //     ),
                  //     child: Consumer<ProductScreenProvider>(
                  //       builder: (context, provider, child) {
                  //         return Icon(
                  //           provider.iconSelected
                  //               ? Icons.bookmark
                  //               : Icons.bookmark_outline,
                  //           color: black,
                  //           size: screenWidth * 0.08,
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: screenWidth * 0.05),

                  CustomButton(
                    buttonColor: isDarkMode ? white : appColor,
                    buttonRadius: 6,
                    buttonHeight: ScreenSize.screenHeight * 0.06,
                    buttonWidth: ScreenSize.screenWidth * 0.83,
                    buttonText: 'Add to cart',
                    isLoading: provider.isLoading,
                    fonts: GoogleFonts.manrope(
                        fontSize: ScreenSize.screenHeight * 0.025,
                        color: isDarkMode ? black : white,
                        fontWeight: FontWeight.bold),
                    onPressed: () {
                      provider.addToCart(
                        capitalizeFirstLetter(widget.name),
                        widget.description,
                        widget.image[0],
                        widget.price,
                        widget.height,
                        widget.width,
                        widget.space,
                        widget.category,
                      );
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
                            fonts: GoogleFonts.aDLaMDisplay(color: white),
                            onPressed: () async {
                              if (heightController.text.trim().isEmpty ||
                                  widthController.text.trim().isEmpty ||
                                  spaceController.text.trim().isEmpty) {
                                customSnackbar(
                                  title: 'Fields required',
                                  message: 'Please enter all dimensions.',
                                  titleColor: red,
                                  icon: Icons.warning_amber,
                                  iconColor: red,
                                );
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

                                customSnackbar(
                                    title: 'Dimensions Updated',
                                    message: 'Dimensions updated successfully.',
                                    titleColor: green,
                                    icon: Icons.check,
                                    iconColor: green);
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
                                  'Quantity': quantity,
                                  'Height': heightController.text,
                                  'Width': widthController.text,
                                  'Space': spaceController.text,
                                  'Category': 'Custom',
                                });

                                print(
                                    "🟢 Custom item added for $productName with userId: $userId");
                                customSnackbar(
                                    title: 'Customization Done',
                                    message: 'Customization done successfully',
                                    titleColor: green,
                                    icon: Icons.check,
                                    iconColor: green);
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
