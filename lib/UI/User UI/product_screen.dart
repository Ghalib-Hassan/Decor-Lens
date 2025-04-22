import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Main Product Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/chairs/chair1.jpg',
                  height: screenHeight * 0.5,
                  width: screenWidth * 0.8,
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(),

            SizedBox(height: screenHeight * 0.02),

            /// Thumbnail Images
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildThumbnail('assets/images/chairs/chair2.jpg', screenWidth),
                buildThumbnail('assets/images/chairs/chair3.jpg', screenWidth),
                buildThumbnail('assets/images/chairs/chair4.jpg', screenWidth),
              ],
            ).animate().fadeIn(duration: 600.ms).scale(),

            SizedBox(height: screenHeight * 0.03),

            /// Product Details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EkERO',
                          style: GoogleFonts.manrope(
                              color: black.withOpacity(.5),
                              fontSize: screenWidth * 0.045))
                      .animate()
                      .slideX(),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    '\$230.00',
                    style: GoogleFonts.manrope(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold),
                  ).animate().fade(duration: 500.ms),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Icon(Icons.star, color: amber, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.01),
                      Text('4.9 (256)',
                          style: GoogleFonts.manrope(
                              color: black.withOpacity(.5),
                              fontSize: screenWidth * 0.04)),
                    ],
                  ).animate().scale(),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'A minimalist chair with a reversible back cushion provides soft support for your back and has two sides to wear.',
                    style: GoogleFonts.manrope(
                        color: black.withOpacity(.5),
                        fontSize: screenWidth * 0.04),
                  ).animate().fadeIn(duration: 700.ms).slideX(),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Favorite Button
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: appColor),
              ),
              child: Icon(Icons.favorite_outline,
                  color: appColor, size: screenWidth * 0.06),
            ).animate().scale(),

            /// Add to Cart Button
            CustomButton(
                    buttonHeight: ScreenSize.screenHeight * 0.06,
                    buttonWidth: ScreenSize.screenWidth * 0.7,
                    fonts: GoogleFonts.manrope(
                        fontSize: ScreenSize.screenHeight * 0.025,
                        color: white,
                        fontWeight: FontWeight.bold),
                    buttonText: 'Add to Cart',
                    onPressed: () {})
                .animate()
                .fade(duration: 800.ms),
          ],
        ),
      ),
    );
  }

  /// Helper Widget for Thumbnails
  Widget buildThumbnail(String imagePath, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          width: screenWidth * 0.15,
          height: screenWidth * 0.15,
          fit: BoxFit.cover,
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(),
    );
  }
}
