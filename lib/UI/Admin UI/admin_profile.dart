import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supportNumberController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Admin Credentials')
          .doc('admin_id')
          .get();

      if (doc.exists) {
        final data = doc.data();
        nameController.text = data?['name'] ?? '';
        emailController.text = data?['email'] ?? '';
        passwordController.text = data?['password'] ?? '';
        supportNumberController.text = data?['supportNumber'] ?? '';
      } else {
        customSnackbar(
          title: "Error",
          message: "Admin profile not found.",
          titleColor: red,
          iconColor: red,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      customSnackbar(
        title: "Error",
        message: "Failed to load profile: $e",
        titleColor: red,
        iconColor: red,
        icon: Icons.error_outline,
      );
    }
  }

  void saveProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('Admin Credentials')
          .doc('admin_id')
          .update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'supportNumber': supportNumberController.text.trim(),
      });

      setState(() {
        isLoading = false;
      });

      customSnackbar(
        title: "Profile Update",
        message: "Your profile has been updated successfully.",
        titleColor: green,
        iconColor: green,
        icon: Icons.check_circle_outline,
      );
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.currentUser?.delete();

      Get.offAll(() => UserLogin(), transition: Transition.zoom);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      customSnackbar(
        title: "Error",
        message: "Failed to update profile: $e",
        titleColor: red,
        iconColor: red,
        icon: Icons.error_outline,
      );
    }
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
          title: Text(
            'Admin Profile',
            style: GoogleFonts.poppins(
              fontSize: screenHeight * 0.025,
              color: white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ZoomIn(
            duration: const Duration(milliseconds: 500),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          AssetImage("assets/images/admin_avatar.jpg"),
                      backgroundColor: grey.withOpacity(.3),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                buildTextField("Full Name", nameController),
                const SizedBox(height: 12),
                buildTextField("Email", emailController),
                const SizedBox(height: 12),
                buildTextField("Password", passwordController,
                    isPassword: true),
                const SizedBox(height: 12),
                buildTextField("Support Number", supportNumberController),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
        floatingActionButton: CustomButton(
            buttonWidth: screenWidth * 0.91,
            buttonHeight: screenHeight * 0.065,
            fonts: GoogleFonts.poppins(
              fontSize: screenHeight * 0.022,
              color: white,
            ),
            isLoading: isLoading,
            buttonText: "Save Changes",
            onPressed: saveProfile),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType:
          label == "Support Number" ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(
          label == "Email"
              ? Icons.email
              : label == "Password"
                  ? Icons.lock
                  : label == "Support Number"
                      ? Icons.phone
                      : Icons.person,
          color: deepPurple,
        ),
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: deepPurple),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: deepPurple, width: 2),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      style: GoogleFonts.poppins(),
    );
  }
}
