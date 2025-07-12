import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/UI/User%20UI/home_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/email_text_field.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    try {
      if (name.isEmpty ||
          email.isEmpty ||
          phoneNumber.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        customSnackbar(
          title: 'Incomplete Information',
          message: 'Please ensure all required fields are filled out.',
          titleColor: red,
          icon: Icons.warning_amber_rounded,
          iconColor: red,
        );
        onError();
        return;
      }

      if (password.length < 6) {
        customSnackbar(
          title: 'Weak Password',
          message: 'Password must be at least 6 characters long.',
          titleColor: red,
          icon: Icons.lock_outline,
          iconColor: red,
        );

        onError();
        return;
      }

      if (password != confirmPassword) {
        customSnackbar(
          title: 'Password Mismatch',
          message: 'The entered passwords do not match. Please try again.',
          titleColor: red,
          icon: Icons.sync_problem_rounded,
          iconColor: red,
        );

        onError();
        return;
      }

      if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber) ||
          phoneNumber.length != 10) {
        customSnackbar(
          title: 'Invalid Phone Number',
          message: 'Please enter a valid 10-digit phone number.',
          titleColor: red,
          icon: Icons.phone_android_outlined,
          iconColor: red,
        );

        onError();
        return;
      }

      QuerySnapshot querySnapshot =
          await _db.collection('Users').where('Email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        customSnackbar(
          title: 'Email Already Registered',
          message:
              'The provided email address is already associated with an existing account.',
          titleColor: red,
          icon: Icons.email_outlined,
          iconColor: red,
        );

        onError();
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user
          ?.reload(); // optional but ensures latest user info

      String? uid = userCredential.user?.uid;

      if (uid != null) {
        await _db.collection('Users').doc(uid).set({
          'Name': name,
          'Email': email,
          'Password': password,
          'Phone_number': '+92$phoneNumber',
          'User_id': uid,
          'Profile_picture': null,
          'is_blocked': false,
        });

        debugPrint('phone number $phoneNumber');

        customSnackbar(
          title: 'Account Created',
          message: 'Your account has been registered successfully.',
          titleColor: green,
          icon: Icons.check_circle_outline,
          iconColor: green,
        );

        // Get.offAll(
        //   EmailVerification(phoneNumber: phoneNumber),
        //   transition: Transition.fade,
        //   duration: const Duration(milliseconds: 600),
        // );
        onSuccess();
      }
    } catch (e) {
      String errorMessage = 'An error occurred';
      if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'The password is too weak';
      }
      customSnackbar(
          title: 'Error',
          titleColor: red,
          message: errorMessage,
          icon: Icons.error_outline,
          iconColor: red);

      onError();
      return;
    }
  }

  Future<void> signInUser({
    required String email,
    required String password,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        customSnackbar(
          title: 'Incomplete Information',
          message: 'Please enter both email and password.',
          titleColor: red,
          icon: Icons.warning_amber_rounded,
          iconColor: red,
        );
        onError();
        return;
      }

      // 🔍 Query Firestore for user document with matching email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: email.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        customSnackbar(
          title: 'No User Found',
          message: 'No user found with this email.',
          titleColor: red,
          icon: Icons.warning_amber_rounded,
          iconColor: red,
        );
        onError();
        return;
      }

      // 🔑 Extract user data
      var userDoc = querySnapshot.docs.first;
      String storedPassword = userDoc['Password'];
      String userUid = userDoc.id;
      String userName = userDoc['Name'];
      String userEmail = userDoc['Email'];
      bool isBlocked = userDoc['is_blocked'] ?? false;

      // ❌ Blocked user check (BEFORE password check)
      if (isBlocked) {
        customSnackbar(
          title: 'Account Blocked',
          message: 'Your account has been blocked.',
          titleColor: red,
          icon: Icons.block,
          iconColor: red,
        );
        onError();
        return;
      }

      // 🔍 Compare entered password with stored password
      if (storedPassword != password.trim()) {
        customSnackbar(
          title: 'Incorrect Password',
          message: 'The password you entered is incorrect.',
          titleColor: red,
          icon: Icons.lock_outline,
          iconColor: red,
        );
        onError();
        return;
      }

      // 🔑 Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Fetch the FCM token
      // String? fcmToken = await FirebaseMessaging.instance.getToken();

      // 🔥 Store user data in "LoggedIn Users" collection
      await FirebaseFirestore.instance
          .collection('LoggedIn Users')
          .doc(userUid)
          .set({
        'User_id': userUid,
        'name': userName,
        'email': userEmail,
        // 'fcmToken': fcmToken,
        'logged_in_at': FieldValue.serverTimestamp(),
        'logged_in_with': 'Email',
      });

      if (userCredential.user != null) {
        customSnackbar(
          title: 'Login Successful',
          message: 'You have successfully signed in.',
          titleColor: green,
          icon: Icons.check_circle_outline,
          iconColor: green,
        );
        Get.offAll(() => HomeScreen(),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 2));
        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign-in.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address format.';
      }

      customSnackbar(
        title: 'Login Failed',
        message: errorMessage,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
      onError();
      return;
    } catch (e) {
      customSnackbar(
        title: 'Login Failed',
        message: 'Something went wrong. Please try again.',
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
      onError();
      return;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        customSnackbar(
          title: 'Sign-In Cancelled',
          message: 'Google sign-in was cancelled.',
          titleColor: red,
          icon: Icons.cancel,
          iconColor: red,
        );
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection('Users').doc(user.uid);
        final docSnapshot = await userDocRef.get();

        // Check if user is blocked
        if (docSnapshot.exists) {
          bool isBlocked = docSnapshot['is_blocked'] ?? false;

          if (isBlocked) {
            customSnackbar(
              title: 'Blocked Account',
              message: 'Your account has been blocked.',
              titleColor: red,
              icon: Icons.block,
              iconColor: red,
            );
            await FirebaseAuth.instance.signOut();

            return;
          }
        } else {
          // If the user doesn't exist, save their details in Firestore
          final userData = {
            "Name": user.displayName ?? "No Name",
            "Email": user.email,
            "User_id": user.uid,
            "is_blocked": false, // Default to not blocked
            'Profile_picture': null
          };
          await userDocRef.set(userData);
          debugPrint("User details added to Firestore.");
        }

        // Get FCM Token
        // String fcmToken = await NotificationService().getDeviceToken();

        // Store user data in "LoggedIn Users" collection
        await FirebaseFirestore.instance
            .collection('LoggedIn Users')
            .doc(user.uid)
            .set({
          'name': user.displayName ?? "No Name",
          'email': user.email,
          // 'fcm_token': fcmToken,
          'logged_in_at': FieldValue.serverTimestamp(), // Timestamp of login
          'User_id': user.uid,
          'logged_in_with': 'Google',
        });

        // Navigation (optional)
        customSnackbar(
          title: 'Login Successful',
          message: 'You have successfully signed in with Google.',
          titleColor: green,
          icon: Icons.check_circle_outline,
          iconColor: green,
        );
        await FirebaseMessaging.instance.subscribeToTopic('all_users');

        Get.offAll(
          () => HomeScreen(),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint("Error in loginWithGoogle: ${e.toString()}");

      customSnackbar(
        title: 'Login Failed',
        message: 'Something went wrong. Please try again.',
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
      return;
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        customSnackbar(
          title: 'Sign-In Cancelled',
          message: 'Facebook sign-in was cancelled.',
          titleColor: red,
          icon: Icons.cancel,
          iconColor: red,
        );
        return;
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      final User? user = userCredential.user;

      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection('Users').doc(user.uid);
        final docSnapshot = await userDocRef.get();

        // Check if user is blocked
        if (docSnapshot.exists) {
          bool isBlocked = docSnapshot['is_blocked'] ?? false;

          if (isBlocked) {
            customSnackbar(
              title: 'Blocked Account',
              message: 'Your account has been blocked.',
              titleColor: red,
              icon: Icons.block,
              iconColor: red,
            );
            await FirebaseAuth.instance.signOut();
            return;
          }
        } else {
          // If new user, add to Firestore
          final userData = {
            "Name": user.displayName ?? "No Name",
            "Email": user.email ?? "No Email",
            "User_id": user.uid,
            "is_blocked": false,
            'Profile_picture': user.photoURL,
          };
          await userDocRef.set(userData);
          debugPrint("Facebook user details added to Firestore.");
        }

        // Get FCM Token
        // String fcmToken = await NotificationService().getDeviceToken();

        // Save to LoggedIn Users
        await FirebaseFirestore.instance
            .collection('LoggedIn Users')
            .doc(user.uid)
            .set({
          'name': user.displayName ?? "No Name",
          'email': user.email ?? "No Email",
          'User_id': user.uid,
          // 'fcm_token': fcmToken,
          'logged_in_at': FieldValue.serverTimestamp(),
          'logged_in_with': 'Facebook',
        });

        // Subscribe to topic (optional)
        await FirebaseMessaging.instance.subscribeToTopic('all_users');

        // Navigate
        customSnackbar(
          title: 'Login Successful',
          message: 'You have successfully signed in with Facebook.',
          titleColor: green,
          icon: Icons.check_circle_outline,
          iconColor: green,
        );

        Get.offAll(
          () => HomeScreen(),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 2),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException in loginWithFacebook: ${e.code}");

      if (e.code == 'account-exists-with-different-credential') {
        String email = e.email!;
        List<String> methods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        String methodMessage = 'a different login option';
        if (methods.contains('google.com')) {
          methodMessage = 'your Google account';
        } else if (methods.contains('password')) {
          methodMessage = 'Email & Password';
        }

        customSnackbar(
          title: 'Account Exists',
          message:
              'This email is already registered using $methodMessage. Please sign in using that method.',
          titleColor: red,
          icon: Icons.warning_amber_rounded,
          iconColor: red,
        );
      } else {
        customSnackbar(
          title: 'Login Failed',
          message: 'Something went wrong: ${e.message}',
          titleColor: red,
          icon: Icons.error_outline,
          iconColor: red,
        );
      }
    } catch (e) {
      debugPrint("Error in loginWithFacebook: ${e.toString()}");

      customSnackbar(
        title: 'Login Failed',
        message: 'Something went wrong. Please try again.',
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
      );
    }
  }

  void showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    bool isLoading = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Center(
                      child: Text(
                        'Forgot Password',
                        style: GoogleFonts.manrope(
                          color: black.withOpacity(0.85),
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enter your email to receive a password reset link:",
                          style: GoogleFonts.poppins(
                            color: black.withOpacity(0.7),
                            fontSize:
                                MediaQuery.of(context).size.height * 0.016,
                          ),
                        ),
                        const SizedBox(height: 10),
                        EmailTextField(
                          myController: emailController,
                          labelText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              buttonColor: red,
                              buttonText: 'Cancel',
                              buttonBorder: BorderSide(color: red),
                              onPressed: () => Navigator.pop(context),
                              buttonHeight:
                                  MediaQuery.of(context).size.height * 0.04,
                              buttonWidth:
                                  MediaQuery.of(context).size.width * 0.3,
                              isLoading: false,
                            ),
                            CustomButton(
                              buttonColor: appColor,
                              buttonText: 'Send',
                              buttonBorder: BorderSide(color: appColor),
                              buttonHeight:
                                  MediaQuery.of(context).size.height * 0.04,
                              buttonWidth:
                                  MediaQuery.of(context).size.width * 0.3,
                              isLoading: isLoading,
                              loadingSize: 25,
                              onPressed: () async {
                                final String email =
                                    emailController.text.trim();

                                if (email.isEmpty) {
                                  customSnackbar(
                                    title: "Missing Email",
                                    message: "Please enter your email.",
                                    titleColor: red,
                                    icon: Icons.email_outlined,
                                    iconColor: red,
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                try {
                                  final querySnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('Users')
                                      .where('Email', isEqualTo: email)
                                      .get();

                                  if (querySnapshot.docs.isEmpty) {
                                    setState(() => isLoading = false);
                                    customSnackbar(
                                      title: "No Account Found",
                                      message:
                                          "No user registered with this email.",
                                      titleColor: red,
                                      icon: Icons.warning_amber_rounded,
                                      iconColor: red,
                                    );
                                    return;
                                  }

                                  await _auth.sendPasswordResetEmail(
                                      email: email);
                                  customSnackbar(
                                    title: "Success",
                                    message:
                                        "Reset link sent! Check your inbox.",
                                    titleColor: green,
                                    icon: Icons.mark_email_read_outlined,
                                    iconColor: green,
                                  );
                                  setState(() => isLoading = false);

                                  Navigator.pop(context);
                                } catch (e) {
                                  customSnackbar(
                                    title: "Error",
                                    message:
                                        "Failed to send reset link. Try again.",
                                    titleColor: red,
                                    icon: Icons.error_outline,
                                    iconColor: red,
                                  );
                                  setState(() => isLoading = false);
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
