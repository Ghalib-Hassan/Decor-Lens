import 'dart:convert';
import 'dart:io';
import 'package:decor_lens/Services/admin_services.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class EditCustomizableItem extends StatefulWidget {
  final QueryDocumentSnapshot item;

  const EditCustomizableItem({super.key, required this.item});

  @override
  _EditCustomizableItemState createState() => _EditCustomizableItemState();
}

class _EditCustomizableItemState extends State<EditCustomizableItem> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();

  File? imageFile;
  XFile? image;
  bool isLoading = false;
  File? glbFile; // Store the 3D model file
  String glbFileUrl = ''; // URL for the 3D model
  // Assuming you have a list of image URLs or file paths for 2D images
  List<File?> images = []; // List to store 2D image files
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    itemNameController.text = widget.item['ItemName'];
    itemDescriptionController.text = widget.item['ItemDescription'];
    itemPriceController.text = widget.item['ItemPrice'];
    glbFileUrl = widget.item['Model'] ?? ''; // Initialize 3D model URL

    List<dynamic> imageUrlsDynamic = widget.item['Images'] ?? [];
    imageUrls = imageUrlsDynamic.map((item) => item.toString()).toList();
  }

  // Function to pick an image and upload it to Firebase Storage
  Future<void> pickAndReplaceImage(int index) async {
    final picker = ImagePicker();
    XFile? newImage = await picker.pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // 1. Upload new image to Cloudinary
        var uploadUri = Uri.parse(
            "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/image/upload");
        var request = http.MultipartRequest('POST', uploadUri);
        request.files
            .add(await http.MultipartFile.fromPath('file', newImage.path));
        request.fields['upload_preset'] = "admin_upload_preset";

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode != 200) {
          throw Exception('Failed to upload new image');
        }

        var jsonResponse = jsonDecode(responseBody);
        String newImageUrl = jsonResponse['secure_url'];

        // 2. Replace in local list
        imageUrls[index] = newImageUrl;

        // 3. Update Firestore document
        await FirebaseFirestore.instance
            .collection('Items')
            .doc(widget.item.id)
            .update({'Images': imageUrls});

        customSnackbar(
            title: 'Success',
            message: 'Image updated successfully!',
            backgroundColor: white,
            titleColor: green,
            icon: Icons.check_circle,
            iconColor: green);
      } catch (e) {
        customSnackbar(
            title: 'Error',
            message: 'Failed to replace image: $e',
            backgroundColor: white,
            titleColor: red,
            icon: Icons.error,
            iconColor: red);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Pick a single image (before updating)
  Future<void> pickSingleImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (imageUrls.length >= 5) {
        customSnackbar(
          title: 'Limit Exceeded',
          message: 'You cannot select more than 5 images.',
          messageColor: black,
          titleColor: red,
          icon: Icons.warning_amber_rounded,
          iconColor: red,
          backgroundColor: white,
        );
        return;
      }

      try {
        final uri = Uri.parse(
          "https://api.cloudinary.com/v1_1/${dotenv.env['CLOUDINARY_CLOUD_NAME']}/image/upload",
        );
        final request = http.MultipartRequest('POST', uri)
          ..files
              .add(await http.MultipartFile.fromPath('file', pickedImage.path))
          ..fields['upload_preset'] = "admin_upload_preset";

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final newImageUrl = jsonDecode(responseBody)['secure_url'];
          setState(() => imageUrls.add(newImageUrl));
        } else {
          throw Exception("Failed to upload image.");
        }
      } catch (e) {
        customSnackbar(
          title: 'Upload Error',
          message: 'Image upload failed: $e',
          messageColor: black,
          titleColor: red,
          icon: Icons.error_outline,
          iconColor: red,
          backgroundColor: white,
        );
      }
    }
  }

  Future<void> deleteImage(int index) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 2. Remove from local list
      imageUrls.removeAt(index);

      // 3. Update Firestore
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(widget.item.id)
          .update({'Images': imageUrls});

      // 4. Show success snackbar
      customSnackbar(
        title: 'Deleted',
        message: 'Image deleted successfully!',
        messageColor: black,
        titleColor: green,
        icon: Icons.delete_outline,
        iconColor: green,
        backgroundColor: white,
      );
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Failed to delete image: $e',
        messageColor: black,
        titleColor: red,
        icon: Icons.error,
        iconColor: red,
        backgroundColor: white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Pick 3D model file (glb)
  void pick3DModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Allow any file type
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null &&
          (filePath.endsWith('.glb') || filePath.endsWith('.gltf'))) {
        setState(() {
          glbFile = File(filePath);
          glbFileUrl = Uri.file(filePath).toString();
        });
      } else {
        customSnackbar(
          title: 'Error',
          message: 'Please select a valid .glb or .gltf file',
          messageColor: black,
          titleColor: red,
          icon: Icons.error_outline,
          iconColor: red,
          backgroundColor: white,
        );
      }
    }
  }

  Future<void> delete3DModel() async {
    if (glbFileUrl.isEmpty) {
      customSnackbar(
        title: 'No 3D Model',
        message: 'No 3D model to delete!',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Remove the model URL from Firestore
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(widget.item.id)
          .update({'Model': null});

      setState(() {
        glbFileUrl = ''; // Clear from UI
      });

      customSnackbar(
        title: 'Model Deleted',
        message: '3D Model deleted successfully!',
        messageColor: black,
        titleColor: green,
        icon: Icons.delete_outline,
        iconColor: green,
        backgroundColor: white,
      );
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Failed to delete 3D Model: $e',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle the update button press
  Future<void> updateItem() async {
    if (imageUrls.length > 5) {
      customSnackbar(
        title: 'Error',
        message: 'Please select no more than 5 images.',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
      return;
    }

    setState(() => isLoading = true);

    await AdminItemService.updateCustomItem(
      context: context,
      itemId: widget.item.id,
      name: itemNameController.text,
      description: itemDescriptionController.text,
      price: itemPriceController.text,
      imageUrls: imageUrls,
      glbFileUrl: glbFileUrl,
    );

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, 'updated');
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: adminBack,
        appBar: AppBar(
          backgroundColor: adminAppbar,
          elevation: 0,
          title: Text('Edit Customizable Item',
              style: GoogleFonts.poppins(
                fontSize: screenHeight * 0.03,
                color: white,
                fontWeight: FontWeight.w600,
              )),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTextField(
                    controller: itemNameController,
                    hint: 'Item Name',
                    screenHeight: screenHeight,
                    maxLength: 30,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: itemDescriptionController,
                      hint: 'Item Description',
                      screenHeight: screenHeight,
                      maxLines: 5),
                  const SizedBox(height: 16),
                  _buildPriceField(screenHeight),
                  const SizedBox(height: 24),
                  CustomButton(
                    buttonText: 'Pick an Image',
                    onPressed: pickSingleImage,
                    buttonWidth: screenWidth * 0.75,
                    buttonHeight: screenHeight * 0.05,
                    buttonFontSize: screenHeight * 0.02,
                    buttonBorder: BorderSide(color: appColor),
                  ),
                  const SizedBox(height: 24),
                  _buildImageList(screenWidth, screenHeight),
                  const SizedBox(height: 16),
                  _build3DModelPreview(screenWidth, screenHeight),
                  const SizedBox(height: 12),
                  CustomButton(
                    buttonText: 'Pick 3D Model',
                    buttonWidth: screenWidth * 0.75,
                    buttonHeight: screenHeight * 0.05,
                    buttonFontSize: screenHeight * 0.02,
                    buttonBorder: BorderSide(
                      color: appColor,
                    ),
                    onPressed: pick3DModel,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    buttonText: 'Delete 3D Model',
                    buttonColor: red,
                    buttonWidth: screenWidth * 0.75,
                    buttonHeight: screenHeight * 0.05,
                    buttonFontSize: screenHeight * 0.02,
                    buttonBorder: BorderSide(
                      color: red,
                    ),
                    onPressed: delete3DModel,
                  ),
                  const SizedBox(height: 44),
                  Divider(
                    color: black.withOpacity(0.2),
                    thickness: 1,
                  ),
                  CustomButton(
                    buttonText: 'Update Item',
                    buttonWidth: screenWidth * 0.8,
                    buttonHeight: screenHeight * 0.06,
                    buttonFontSize: screenHeight * 0.022,
                    isLoading: isLoading,
                    onPressed: updateItem,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double screenHeight,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.poppins(color: black, fontSize: screenHeight * 0.02),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontSize: screenHeight * 0.02,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: black),
        ),
      ),
    );
  }

  Widget _buildPriceField(double screenHeight) {
    return TextField(
      controller: itemPriceController,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: black, fontSize: screenHeight * 0.02),
      decoration: InputDecoration(
        hintText: 'Item Price',
        suffix: Text('In Rs'),
        hintStyle: GoogleFonts.poppins(
          color: black.withOpacity(0.8),
          fontSize: screenHeight * 0.02,
        ),
      ),
    );
  }

  Widget _buildImageList(double screenWidth, double screenHeight) {
    return Column(
      children: imageUrls.asMap().entries.map((entry) {
        int index = entry.key;
        String url = entry.value;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  url,
                  height: screenHeight * 0.35,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      buttonText: 'Replace',
                      onPressed: () => pickAndReplaceImage(index),
                      buttonWidth: screenWidth * 0.35,
                      buttonHeight: screenHeight * 0.045,
                      buttonFontSize: screenHeight * 0.018,
                    ),
                    CustomButton(
                      buttonText: 'Delete',
                      buttonBorder: BorderSide(color: red),
                      onPressed: () => deleteImage(index),
                      buttonColor: red,
                      buttonWidth: screenWidth * 0.35,
                      buttonHeight: screenHeight * 0.045,
                      buttonFontSize: screenHeight * 0.018,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _build3DModelPreview(double width, double height) {
    return glbFileUrl.isNotEmpty
        ? SizedBox(
            height: height * 0.45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ModelViewer(
                src: glbFileUrl,
                alt: '3D Model Preview',
                autoRotate: true,
                cameraControls: true,
                ar: true,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No 3D model selected',
              style: GoogleFonts.poppins(
                fontSize: height * 0.018,
                color: grey,
              ),
            ),
          );
  }
}
