import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Security Screen
class SecurityScreen extends StatefulWidget {
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool isLogout = false;
  String name = '';
  String email = '';

  initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['Name'] ?? 'No Name';
          email = userDoc['Email'] ?? 'No Email';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      // Handle error, maybe show a toast or snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Security",
              showLeading: true,
              fontColor: isDarkMode ? white : black,
              leadingIconColor: isDarkMode ? white : black,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Text(
                        'Name:',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? grey : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            color: isDarkMode ? white : black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Text(
                        'Email:',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? grey : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            color: isDarkMode ? white : black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Text(
                        'Password:',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? grey : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '********',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          color: isDarkMode ? white : black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? white : black,
                ),
              ),
              trailing: CupertinoSwitch(
                value: isDarkMode,
                onChanged: (value) {
                  darkModeService.toggleDarkMode(value);
                },
              ),
            ),
            Spacer(),
            CustomButton(
              buttonHeight: MediaQuery.of(context).size.height * 0.06,
              buttonWidth: MediaQuery.of(context).size.width * 0.92,
              buttonColor: isDarkMode ? white : appColor.withOpacity(.5),
              fonts: GoogleFonts.manrope(
                color: isDarkMode ? black : white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.020,
              ),
              isLoading: isLogout,
              buttonText: 'Logout',
              onPressed: () async {
                setState(() {
                  isLogout = true;
                });
                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    await FirebaseFirestore.instance
                        .collection('LoggedIn Users')
                        .doc(currentUser.uid)
                        .delete();
                  }

                  await FirebaseAuth.instance.signOut();
                  // Show the toast message only once
                  SnackbarMessages.logoutSuccess();

                  final darkModeService =
                      Provider.of<DarkModeService>(context, listen: false);
                  await darkModeService.clearDarkModePreference();

                  setState(() {
                    isLogout = false;
                  });

                  Get.offAll(
                    () => UserLogin(),
                    transition: Transition.circularReveal,
                    duration: const Duration(seconds: 2),
                  );
                } catch (e) {
                  debugPrint('Logout error: $e');
                  customSnackbar(
                    title: '❗Error',
                    message: 'Error logging out: ${e.toString()}',
                    titleColor: red,
                    messageColor: black,
                    icon: Icons.error_outline,
                    iconColor: red,
                  );

                  setState(() {
                    isLogout = false;
                  });
                }
              },
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}
