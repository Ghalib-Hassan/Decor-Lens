import 'package:decor_lens/Services/auth_services.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Utils/screen_size.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/email_text_field.dart';
import 'package:decor_lens/Widgets/password_text_field.dart';
import 'package:decor_lens/Widgets/phone_number_text_field.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({super.key});

  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  bool isLoading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  signUp() async {
    if (firstNameController.text.isEmpty) {
      customSnackbar(
        title: 'First Name is required',
        message: 'Please enter your first name.',
        titleColor: red,
        messageColor: red,
        icon: Icons.warning_amber_rounded,
        iconColor: red,
      );
      return;
    }
    setState(() => isLoading = true);

    await AuthService().signUpUser(
      name:
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      onSuccess: () {
        setState(() => isLoading = false);
        Get.to(() => UserLogin(), transition: Transition.fadeIn);
      },
      onError: () {
        setState(() => isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    bool isTablet = ScreenSize.screenWidth > 600;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [teal.withOpacity(0.1), white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.screenWidth * 0.08,
                vertical: ScreenSize.screenHeight * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Create Account',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: black.withOpacity(0.9),
                      fontSize: isTablet ? 34 : 28,
                    ),
                  ).animate().fade(duration: 600.ms).slideX(),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in your details below to get started.',
                    style: GoogleFonts.manrope(
                      color: grey.withOpacity(0.8),
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ).animate().fade(duration: 700.ms).slideX(),
                  const SizedBox(height: 30),
                  buildTextField('First Name', Icons.person_outline,
                      controller: firstNameController),
                  buildTextField('Last Name', Icons.person_outline,
                      controller: lastNameController),
                  PhoneNumberTextField(controller: phoneController),
                  EmailTextField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    myController: emailController,
                  ),
                  const SizedBox(height: 20),
                  PasswordTextField(
                    labelText: 'Password',
                    keyboardType: TextInputType.text,
                    myController: passwordController,
                  ),
                  const SizedBox(height: 20),
                  PasswordTextField(
                    labelText: 'Confirm Password',
                    keyboardType: TextInputType.text,
                    myController: confirmPasswordController,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'By signing up, you agree to our Terms and Privacy Policy.',
                    style: GoogleFonts.manrope(
                      color: grey.withOpacity(0.8),
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ).animate().fade(duration: 800.ms).slideX(),
                  const SizedBox(height: 30),
                  CustomButton(
                          buttonColor: appColor,
                          buttonWidth: double.infinity,
                          buttonHeight: ScreenSize.screenHeight * 0.06,
                          fonts: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: white,
                            fontSize: ScreenSize.screenHeight * 0.022,
                          ),
                          buttonText: 'Create Account',
                          isLoading: isLoading,
                          onPressed: () => signUp())
                      .animate()
                      .fade(duration: 900.ms)
                      .slideY(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Back again? ",
                        style: GoogleFonts.manrope(
                          color: black.withOpacity(0.8),
                          fontSize: isTablet ? 16 : 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => UserLogin(),
                              transition: Transition.downToUp);
                        },
                        child: Text(
                          'Log in to continue.',
                          style: GoogleFonts.manrope(
                            color: teal,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 15,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 1000.ms).slideY(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text,
      TextEditingController? controller}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          style: GoogleFonts.poppins(color: black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(color: black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(icon, color: grey),
          ),
        ));
  }
}
