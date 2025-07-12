import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageDetailScreen(
      {super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Theme(
      data: ThemeData.light(), // Force light mode on this screen
      child: Scaffold(
        backgroundColor: adminBack,
        appBar: AppBar(
          backgroundColor: adminAppbar,
          title: Text(
            'Image Detail',
            style: GoogleFonts.poppins(
              fontSize: screenHeight * 0.03,
              color: white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Hero(
            tag: heroTag,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
