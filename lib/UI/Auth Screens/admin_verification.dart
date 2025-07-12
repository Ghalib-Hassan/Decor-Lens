import 'dart:async';
import 'package:decor_lens/UI/Auth%20Screens/admin_password.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminEmailVerification extends StatefulWidget {
  final String email;
  final String password;
  const AdminEmailVerification(
      {super.key, required this.email, required this.password});

  @override
  State<AdminEmailVerification> createState() => _AdminEmailVerificationState();
}

class _AdminEmailVerificationState extends State<AdminEmailVerification> {
  bool isSending = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await auth.currentUser?.reload();
      if (auth.currentUser?.emailVerified == true) {
        timer.cancel();
        Get.offAll(
          AdminPassword(
            email: widget.email,
            password: widget.password,
          ),
          transition: Transition.zoom,
          duration: const Duration(milliseconds: 600),
        );
      }
    });
  }

  Future<void> sendVerificationEmail() async {
    setState(() => isSending = true);

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      final user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
        await user.reload();

        if (user.emailVerified) {
          customSnackbar(
            title: 'Already Verified',
            message: 'This email is already verified.',
            titleColor: red,
            icon: Icons.verified,
            iconColor: red,
          );
        } else {
          customSnackbar(
            title: 'Verification Sent',
            message: 'A verification link has been sent to your email.',
            titleColor: green,
            icon: Icons.check_circle_outline,
            iconColor: green,
          );
        }
      }
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: e.toString(),
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.19),
              Container(
                decoration: BoxDecoration(
                  color: appColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(30),
                child: Icon(
                  Icons.mark_email_read_rounded,
                  size: screenHeight * 0.1,
                  color: appColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Hello Admin!',
                style: GoogleFonts.merriweather(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                'Click below to send a verification link to your email. Don’t forget to check the spam folder too!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: screenHeight * 0.018,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.06),
              CustomButton(
                buttonColor: appColor,
                buttonWidth: double.infinity,
                buttonHeight: screenHeight * 0.055,
                fonts: GoogleFonts.nunitoSans(
                  color: white,
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w600,
                ),
                isLoading: isSending,
                buttonText: 'Send Verification Link',
                onPressed: isSending ? () {} : sendVerificationEmail,
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
