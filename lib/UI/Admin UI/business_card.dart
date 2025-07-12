import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AddBusinessCard extends StatefulWidget {
  const AddBusinessCard({super.key});

  @override
  State<AddBusinessCard> createState() => _AddBusinessCardState();
}

class _AddBusinessCardState extends State<AddBusinessCard> {
  File? frontImage;
  File? backImage;
  String? frontImageUrl;
  String? backImageUrl;
  String? documentId;
  final picker = ImagePicker();
  bool edit = false;
  bool delete = false;

  @override
  void initState() {
    super.initState();
    fetchBusinessCard();
  }

  Future<void> fetchBusinessCard() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('BusinessCard').get();
    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      setState(() {
        documentId = doc.id;
        frontImageUrl = doc['frontImageUrl'];
        backImageUrl = doc['backImageUrl'];
      });
    }
  }

  Future<void> pickImage(bool isFront) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile, isFront);
    }
  }

  Future<void> uploadImage(File image, bool isFront) async {
    try {
      var uploadUri = Uri.parse(
          "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/image/upload");

      var request = http.MultipartRequest('POST', uploadUri);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      request.fields['upload_preset'] = 'admin_upload_preset';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        String imageUrl = jsonResponse['secure_url'];

        setState(() {
          if (isFront) {
            frontImageUrl = imageUrl;
          } else {
            backImageUrl = imageUrl;
          }
        });

        if (documentId != null) {
          await FirebaseFirestore.instance
              .collection('BusinessCard')
              .doc(documentId)
              .update({
            isFront ? 'frontImageUrl' : 'backImageUrl': imageUrl,
          });
        }
      } else {
        customSnackbar(
          title: 'Uploading Failed',
          message: 'Cloudinary upload failed',
          messageColor: black,
          titleColor: red,
          icon: Icons.error_outline,
          iconColor: red,
          backgroundColor: white,
        );
      }
    } catch (e) {
      customSnackbar(
        title: 'Uploading Failed',
        message: 'Image upload failed',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    }
  }

  Future<void> saveCard() async {
    setState(() => edit = true);
    if (frontImageUrl == null || backImageUrl == null) {
      customSnackbar(
        title: 'Incomplete Card',
        message: 'Please add both front and back images',
        messageColor: black,
        titleColor: red,
        icon: Icons.warning_amber_outlined,
        iconColor: red,
        backgroundColor: white,
      );

      setState(() => edit = false);
      return;
    }

    if (documentId != null) {
      await FirebaseFirestore.instance
          .collection('BusinessCard')
          .doc(documentId)
          .update({
        'frontImageUrl': frontImageUrl,
        'backImageUrl': backImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      customSnackbar(
        title: 'Card Updated',
        message: 'Card updated successfully',
        messageColor: black,
        titleColor: green,
        icon: Icons.check,
        iconColor: green,
        backgroundColor: white,
      );
    } else {
      var docRef =
          await FirebaseFirestore.instance.collection('BusinessCard').add({
        'frontImageUrl': frontImageUrl,
        'backImageUrl': backImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() => documentId = docRef.id);

      customSnackbar(
        title: 'Card Added',
        message: 'Card added successfully',
        messageColor: black,
        titleColor: green,
        icon: Icons.check,
        iconColor: green,
        backgroundColor: white,
      );
    }
    setState(() => edit = false);
  }

  Future<void> deleteCard() async {
    setState(() => delete = true);
    if (documentId != null) {
      await FirebaseFirestore.instance
          .collection('BusinessCard')
          .doc(documentId)
          .delete();
      setState(() {
        frontImageUrl = null;
        backImageUrl = null;
        documentId = null;
      });
    }

    customSnackbar(
      title: 'Card Deleted',
      message: 'Card deleted successfully',
      messageColor: black,
      titleColor: red,
      icon: Icons.delete_outline,
      iconColor: red,
      backgroundColor: white,
    );
    setState(() => delete = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        backgroundColor: adminBack,
        appBar: AppBar(
          backgroundColor: adminAppbar,
          elevation: 0,
          title: Text(
            'Add Business Card',
            style: GoogleFonts.poppins(
              fontSize: screenHeight * 0.03,
              color: white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: white),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildCardContainer(
                    screenWidth, screenHeight, frontImageUrl, 'Front Side'),
                const SizedBox(height: 20),
                buildCardContainer(
                    screenWidth, screenHeight, backImageUrl, 'Back Side'),
                const SizedBox(height: 40),
                CustomButton(
                  isLoading: edit,
                  buttonText: documentId == null ? 'Add Cards' : 'Update Cards',
                  onPressed: saveCard,
                  buttonHeight: screenHeight * 0.055,
                  buttonWidth: screenWidth * 0.6,
                  fonts: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500, color: white),
                ),
                const SizedBox(height: 16),
                if (documentId != null)
                  CustomButton(
                    isLoading: delete,
                    buttonBorder: BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                    buttonColor: Colors.redAccent,
                    buttonText: 'Delete Cards',
                    onPressed: deleteCard,
                    buttonHeight: screenHeight * 0.055,
                    buttonWidth: screenWidth * 0.6,
                    fonts: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCardContainer(
      double width, double height, String? imageUrl, String label) {
    return GestureDetector(
      onTap: () => pickImage(label == 'Front Side'),
      child: Container(
        width: width * 0.85,
        height: height * 0.25,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black26, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: imageUrl == null
            ? Center(
                child: Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: height * 0.02,
                        color: black.withOpacity(0.8))),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
