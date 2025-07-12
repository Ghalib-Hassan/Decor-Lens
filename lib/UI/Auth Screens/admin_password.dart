import 'package:decor_lens/UI/Admin%20UI/admin_homepage.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/password_text_field.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPassword extends StatefulWidget {
  final email;
  final password;
  const AdminPassword({super.key, required this.email, required this.password});

  @override
  State<AdminPassword> createState() => _AdminPasswordState();
}

class _AdminPasswordState extends State<AdminPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                      "Enter your admin password",
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
              PasswordTextField(
                labelText: 'Password',
                keyboardType: TextInputType.text,
                myController: passwordController,
              ),
              SizedBox(height: screenHeight * 0.04),

              PasswordTextField(
                labelText: 'Confirm Password',
                keyboardType: TextInputType.text,
                myController: confirmPasswordController,
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
                  buttonText: 'Log In',
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (passwordController.text.trim().isEmpty ||
                        confirmPasswordController.text.trim().isEmpty) {
                      customSnackbar(
                        title: 'Incomplete Information',
                        message: 'Please fill both the fields',
                        titleColor: red,
                        icon: Icons.warning_amber_rounded,
                        iconColor: red,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    } else if (passwordController.text.trim() !=
                        confirmPasswordController.text.trim()) {
                      customSnackbar(
                        title: 'Password Mismatch',
                        message: 'Please check your password',
                        titleColor: red,
                        icon: Icons.warning_amber_rounded,
                        iconColor: red,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    } else if (passwordController.text.trim() !=
                            widget.password &&
                        confirmPasswordController.text.trim() !=
                            widget.password) {
                      customSnackbar(
                        title: 'Incorrect Password',
                        message: 'Please check your password',
                        titleColor: red,
                        icon: Icons.warning_amber_rounded,
                        iconColor: red,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    } else if (passwordController.text.trim() ==
                            widget.password &&
                        confirmPasswordController.text.trim() ==
                            widget.password) {
                      try {
                        await auth.signInWithEmailAndPassword(
                            email: widget.email,
                            password: passwordController.text.trim());
                        await auth.currentUser?.updateDisplayName("Admin");

                        customSnackbar(
                          title: 'Login Successfully',
                          message: 'Welcome back, Admin!',
                          titleColor: green,
                          icon: Icons.check_circle_outline,
                          iconColor: green,
                        );
                        setState(() {
                          isLoading = false;
                        });
                        // Navigate to the admin home screen
                        Get.off(AdminHomePage(), transition: Transition.zoom);
                      } catch (e) {
                        customSnackbar(
                          title: 'Login Failed',
                          message: e.toString(),
                          titleColor: red,
                          icon: Icons.error_outline,
                          iconColor: red,
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  }),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
