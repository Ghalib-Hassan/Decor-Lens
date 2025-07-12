import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/UI/Auth%20Screens/admin_verification.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/email_text_field.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminEmailScreen extends StatefulWidget {
  const AdminEmailScreen({super.key});

  @override
  _AdminEmailScreenState createState() => _AdminEmailScreenState();
}

class _AdminEmailScreenState extends State<AdminEmailScreen> {
  final TextEditingController adminLoginEmailController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    adminLoginEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.04,
                    horizontal: screenWidth * 0.05,
                  ),
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello!',
                        style: GoogleFonts.merriweather(
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ADMIN',
                        style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.w800,
                          color: black,
                          fontSize: screenHeight * 0.035,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Enter your admin email to begin verification",
                        style: GoogleFonts.nunitoSans(
                          color: Colors.grey.shade700,
                          fontSize: screenHeight * 0.018,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.08),

                // Email Field
                EmailTextField(
                  myController: adminLoginEmailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'Email Address',
                ),

                SizedBox(height: screenHeight * 0.06),

                // Button
                CustomButton(
                  buttonWidth: screenWidth * 0.85,
                  buttonHeight: screenHeight * 0.058,
                  buttonColor: appColor,
                  fonts: GoogleFonts.nunitoSans(
                    color: white,
                    fontSize: screenHeight * 0.019,
                    fontWeight: FontWeight.w600,
                  ),
                  isLoading: isLoading,
                  buttonText: 'Email Verification',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      await Future.delayed(const Duration(seconds: 1));

                      DocumentSnapshot snapshot =
                          await FirebaseFirestore.instance
                              .collection('Admin Credentials')
                              .doc('admin_id') // or your specific document ID
                              .get();
                      String firestoreEmail = snapshot['email'];
                      String firestorePassword = snapshot['password'];
                      if (adminLoginEmailController.text.trim() ==
                          firestoreEmail) {
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: firestoreEmail,
                            password: firestorePassword,
                          );

                          Get.off(
                              AdminEmailVerification(
                                email: adminLoginEmailController.text.trim(),
                                password: firestorePassword,
                              ),
                              transition: Transition.zoom);
                        } catch (e) {
                          customSnackbar(
                            title: 'Authentication Error',
                            message: 'User already exists',
                            titleColor: red,
                            icon: Icons.error,
                            iconColor: red,
                          );
                        }
                      } else {
                        customSnackbar(
                          title: 'Login Failed',
                          message: 'Email is incorrect',
                          titleColor: red,
                          icon: Icons.warning_amber_rounded,
                          iconColor: red,
                        );
                      }
                      setState(() => isLoading = false);
                    }
                  },
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
