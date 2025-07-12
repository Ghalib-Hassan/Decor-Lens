import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Services/admin_services.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/admin_product_details.dart';
import 'package:decor_lens/Widgets/admin_product_dimensions.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  TextEditingController itemDescription = TextEditingController();
  TextEditingController itemPrice = TextEditingController();
  TextEditingController itemDeliveryPrice = TextEditingController();
  TextEditingController itemName = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController spaceController = TextEditingController();

  String? categorySelection;
  bool isLoading = false;
  File? glbFile;
  List<File?> images = [null, null, null, null, null]; // To store images

  @override
  void dispose() {
    categorySelection = null;
    super.dispose();
  }

  void dropDownChange(String? newCategory) {
    setState(() {
      categorySelection = newCategory;
    });
  }

  // Function to pick 2D images (maximum 5)
  void pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Allow multiple selection of images
    );

    if (result != null && result.files.isNotEmpty) {
      // Ensure at least 1 image is selected and at most 5 images
      if (result.files.length > 5) {
        customSnackbar(
            title: 'Error',
            message: 'You can only select up to 5 images',
            messageColor: black,
            titleColor: red,
            icon: Icons.warning_amber_outlined,
            iconColor: red,
            backgroundColor: white);
      } else {
        setState(() {
          images = List.generate(
              5,
              (index) => index < result.files.length
                  ? File(result.files[index].path!)
                  : null);
        });
      }
    }
  }

  // Function to pick 3D model file
  void pick3DFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Allow any file type
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null &&
          (filePath.endsWith('.glb') || filePath.endsWith('.gltf'))) {
        File pickedFile = File(filePath);

        setState(() {
          glbFile = pickedFile;
        });
      } else {
        customSnackbar(
          title: 'Error',
          message: 'Please select a valid .glb or .gltf file',
          messageColor: black,
          titleColor: red,
          icon: Icons.warning_amber_outlined,
          iconColor: red,
          backgroundColor: white,
        );
      }
    }
  }

  // Function to handle adding the item
  void addItem() async {
    String height = heightController.text;
    String width = widthController.text;
    String space = spaceController.text;
    String name = itemName.text.trim();

    if (name.isEmpty ||
        itemDeliveryPrice.text.isEmpty ||
        itemDescription.text.isEmpty ||
        itemPrice.text.isEmpty ||
        categorySelection == null ||
        images[0] == null ||
        height.isEmpty ||
        width.isEmpty ||
        space.isEmpty) {
      customSnackbar(
        title: 'Error',
        message: 'Please fill all the fields',
        messageColor: black,
        titleColor: red,
        icon: Icons.warning_amber_outlined,
        iconColor: red,
        backgroundColor: white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final existing = await FirebaseFirestore.instance
          .collection('Items')
          .where('ItemName', isEqualTo: name)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() => isLoading = false);

        customSnackbar(
          title: 'Name Exists',
          message: 'A product with this name already exists',
          messageColor: black,
          titleColor: red,
          icon: Icons.warning_amber_rounded,
          iconColor: red,
          backgroundColor: white,
        );
        return;
      }

      // No duplicate, proceed to add
      await AdminItemService().addItem(
        itemName: name,
        category: categorySelection!,
        itemDescription: itemDescription.text.trim(),
        itemPrice: itemPrice.text.trim(),
        deliveryPrice: itemDeliveryPrice.text.trim(),
        images: images,
        glbFile: glbFile,
        height: height,
        width: width,
        space: space,
        context: context,
      );
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: 'Something went wrong. Try again.',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    }

    setState(() => isLoading = false);
  }

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
          elevation: 4,
          title: Text(
            'Add New Item',
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image Picker
                  sectionTitle("Product Images", screenHeight),
                  GestureDetector(
                    onTap: () => pickImages(),
                    child: AnimatedContainer(
                      duration: 500.ms,
                      width: double.infinity,
                      height: screenHeight * 0.35,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: white,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: images[0] != null
                            ? (images.length == 1
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(images[0]!,
                                        fit: BoxFit.cover))
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    itemBuilder: (context, index) {
                                      return images[index] != null
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  images[index]!,
                                                  width: screenWidth * 0.5,
                                                  height: screenHeight * 0.3,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : const SizedBox();
                                    },
                                  ))
                            : buildUploadHint(
                                icon: Icons.upload_outlined,
                                text: 'Upload Product Images',
                                height: screenHeight),
                      ),
                    ),
                  ),

                  // 3D Model Picker
                  sectionTitle("3D Model (Optional)", screenHeight),
                  GestureDetector(
                    onTap: () => pick3DFile(),
                    child: glbFile != null
                        ? AnimatedContainer(
                            duration: 500.ms,
                            width: double.infinity,
                            height: screenHeight * 0.28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: ModelViewer(
                              src: "file://${glbFile!.path}",
                              iosSrc: "file://${glbFile!.path}",
                              alt: "3D Model",
                              ar: true,
                              autoRotate: true,
                              cameraControls: true,
                              backgroundColor: Colors.transparent,
                            ),
                          ).animate().slideY(duration: 600.ms)
                        : buildUploadHint(
                            icon: Icons.threed_rotation,
                            text: 'Upload 3D Model (if any)',
                            height: screenHeight),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Dimension Fields
                  sectionTitle("Model Dimensions (cm)", screenHeight),
                  buildDimensionField(context, "Height (Y-Axis)",
                      "Enter height", heightController),
                  buildDimensionField(context, "Width (X-Axis)", "Enter width",
                      widthController),
                  buildDimensionField(context, "Space (Z-Axis)", "Enter space",
                      spaceController),

                  SizedBox(height: screenHeight * 0.04),

                  // Dropdown & Details
                  sectionTitle("Item Information", screenHeight),
                  buildCategoryDropdown(screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  buildTextField(itemName, 'Item Name', screenHeight,
                      maxLength: 20),
                  buildTextField(
                      itemDescription, 'Item Description', screenHeight,
                      maxLines: 3),
                  buildPriceField(itemPrice, 'Item Price', screenHeight),
                  buildPriceField(
                      itemDeliveryPrice, 'Delivery Price', screenHeight),

                  SizedBox(height: screenHeight * 0.05),

                  // Add Item Button
                  CustomButton(
                    buttonText: 'Add Item',
                    buttonWidth: screenWidth * 0.85,
                    buttonHeight: screenHeight * 0.065,
                    isLoading: isLoading,
                    fonts: GoogleFonts.poppins(
                      fontSize: screenHeight * 0.022,
                      color: white,
                    ),
                    onPressed: addItem,
                  ).animate().fadeIn(duration: 500.ms),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget sectionTitle(String title, double height) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: height * 0.022,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget buildCategoryDropdown(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: black.withOpacity(0.4)),
          color: white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: categorySelection,
            hint: Text(
              'Select Category',
              style: GoogleFonts.poppins(
                color: black,
                fontSize: screenHeight * 0.02,
              ),
            ),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_outlined, color: black),
            style: GoogleFonts.poppins(
              color: black,
              fontSize: screenHeight * 0.02,
            ),
            items: [
              'Bed',
              'Chair',
              'Sofa',
              'Stool',
              'Table',
              'Wardrobe',
            ]
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: dropDownChange,
          ),
        ),
      ),
    );
  }
}
