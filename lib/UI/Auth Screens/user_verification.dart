import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserEmailVerification extends StatelessWidget {
  final String email;
  const UserEmailVerification({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: MyAppbar(
            title: "Email Verification",
          ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mark_email_read_rounded, size: 64, color: green)
                        .animate()
                        .fadeIn(duration: 600.ms),
                    const SizedBox(height: 20),
                    const Text(
                      "Check Your Inbox 📩",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ).animate().slideY(begin: 0.4),
                    const SizedBox(height: 10),
                    Text(
                      "A verification link has been sent to:",
                      style: TextStyle(color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      buttonColor: green,
                      buttonHeight: 50,
                      buttonWidth: 280,
                      buttonBorder: BorderSide(color: green),
                      buttonText: '✔️ Continue',
                      onPressed: () async {
                        await auth.currentUser?.reload();
                        final user = auth.currentUser;
                        final prefs = await SharedPreferences.getInstance();
                        final isAwaiting =
                            prefs.getBool('isAwaitingVerification') ?? false;

                        if (user != null && user.emailVerified) {
                          // ✅ Email verified
                          if (isAwaiting) {
                            SnackbarMessages.signupSuccess();
                            await prefs.remove('isAwaitingVerification');
                          } else {
                            SnackbarMessages.emailVerified();
                          }
                          Get.offAll(() => const UserLogin());
                        } else {
                          // ❌ Email still not verified — delete user account
                          try {
                            // Delete user from Firestore
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(user?.uid)
                                .delete();
                            await user?.delete();
                            await prefs.remove('isAwaitingVerification');
                            Get.offAll(() => const UserLogin());
                          } catch (e) {
                            SnackbarMessages.emailNotVerified();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await auth.currentUser?.sendEmailVerification();
                          SnackbarMessages.resendVerification();
                        } catch (e) {
                          SnackbarMessages.notResendVerification();
                        }
                      },
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      label: const Text("Resend Verification Email"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
