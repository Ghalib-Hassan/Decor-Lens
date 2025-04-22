import 'package:decor_lens/UI/Admin%20UI/admin.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_signup.dart';
import 'package:decor_lens/UI/User%20UI/home_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/email_text_field.dart';
import 'package:decor_lens/Widgets/password_text_field.dart';
import 'package:decor_lens/Widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  bool isLoading = false;
  List<String> _gestureSequence = [];

  void _checkAdminAccess() {
    const List<String> correctSequence = [
      'tap',
      'tap',
      'swipeLeft',
      'hold',
      'swipeRight'
    ];

    if (_gestureSequence.length == correctSequence.length) {
      if (ListEquality().equals(_gestureSequence, correctSequence)) {
        Get.to(() => Admin(), transition: Transition.fadeIn);
      }
      _gestureSequence.clear(); // Reset sequence after checking
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    bool isTablet = ScreenSize.screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [teal.withOpacity(0.1), white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_gestureSequence.length < 4) {
                print('2 tap done');
                _gestureSequence.add('tap');
                _checkAdminAccess();
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                print('swipeLeft done');
                _gestureSequence.add('swipeLeft');
              } else if (details.primaryVelocity! > 0) {
                print('swipeRight done');
                _gestureSequence.add('swipeRight');
              }
              _checkAdminAccess();
            },
            onLongPress: () {
              print('hold done');

              _gestureSequence.add('hold');
              _checkAdminAccess();
            },
            child: Container(
              color:
                  Colors.transparent, // Ensures gestures work over the screen
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.screenWidth * 0.08,
                vertical: ScreenSize.screenHeight * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Welcome Text
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.manrope(
                      fontSize: isTablet ? 34 : 28,
                      fontWeight: FontWeight.bold,
                      color: black.withOpacity(0.9),
                    ),
                  ).animate().fade(duration: 600.ms).slideX(),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    'Sign in to continue your journey with us.',
                    style: GoogleFonts.manrope(
                      fontSize: isTablet ? 18 : 16,
                      color: grey.withOpacity(0.8),
                    ),
                  ).animate().fade(duration: 700.ms).slideX(),

                  const SizedBox(height: 30),

                  // Email Field
                  EmailTextField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fade(duration: 700.ms).slideY(),
                  const SizedBox(height: 20),

                  // Password Field
                  PasswordTextField(
                    labelText: 'Password',
                    keyboardType: TextInputType.text,
                  ).animate().fade(duration: 700.ms).slideY(),

                  const SizedBox(height: 15),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.manrope(
                        fontSize: isTablet ? 16 : 14,
                        color: teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fade(duration: 800.ms).slideX(),

                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      buttonHeight: ScreenSize.screenHeight * 0.06,
                      buttonWidth: ScreenSize.screenWidth * 0.4,
                      buttonText: 'Log In',
                      isLoading: isLoading,
                      fonts: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: white,
                        fontSize: ScreenSize.screenHeight * 0.022,
                      ),
                      onPressed: () {
                        Get.offAll(() => HomeScreen(),
                            transition: Transition.circularReveal,
                            duration: const Duration(seconds: 2));
                      },
                    ).animate().fade(duration: 900.ms).slideY(),
                  ),

                  const SizedBox(height: 30),

                  // OR Divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Divider(color: grey.withOpacity(.4))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR',
                            style: GoogleFonts.manrope(
                              color: grey.withOpacity(.7),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      Expanded(child: Divider(color: grey.withOpacity(.4))),
                    ],
                  ).animate().fade(duration: 1000.ms).slideY(),

                  const SizedBox(height: 25),

                  // Social Login Buttons
                  SocialButton(
                    imagePath: 'assets/svg/google.svg',
                    text: 'Continue with Google',
                    onPressed: () {},
                  ).animate().fadeIn(duration: 1100.ms).slideY(),
                  const SizedBox(height: 20),
                  SocialButton(
                    icon: Icons.facebook,
                    iconColor: Colors.blueAccent,
                    text: 'Continue with Facebook',
                    onPressed: () {},
                  ).animate().fadeIn(duration: 1100.ms).slideY(),

                  const SizedBox(height: 30),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New here? ",
                        style: GoogleFonts.manrope(
                          color: black.withOpacity(0.8),
                          fontSize: isTablet ? 16 : 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => UserSignUp(),
                              transition: Transition.downToUp);
                        },
                        child: Text(
                          'Create an account',
                          style: GoogleFonts.manrope(
                            color: teal,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 15,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 1100.ms).slideY(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
