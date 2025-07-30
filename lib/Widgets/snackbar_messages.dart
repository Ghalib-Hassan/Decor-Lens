import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';

class SnackbarMessages {
  // 🔐 Auth Related
  static void loginSuccess() => customSnackbar(
        title: '🎉 Welcome!',
        message: 'You have successfully logged in.',
        titleColor: Colors.green,
      );

  static void googleLoginSuccess() => customSnackbar(
        title: '🎉 Welcome!',
        message: 'You have successfully logged in with Google.',
        titleColor: Colors.green,
      );

  static void facebookLoginSuccess() => customSnackbar(
        title: '🎉 Welcome!',
        message: 'You have successfully logged in with Facebook.',
        titleColor: Colors.green,
      );

  static void signupSuccess() => customSnackbar(
        title: '🙌 Account Created!',
        message: 'Your account has been successfully created.',
        titleColor: Colors.teal,
      );

  static void logoutSuccess() => customSnackbar(
        title: '👋 Logged Out',
        message: 'You have been successfully logged out.',
        titleColor: Colors.blueGrey,
      );

  static void incompleteInfo() => customSnackbar(
        title: '⚠️ Incomplete Information',
        message: 'Please enter both email and password.',
        titleColor: Colors.red,
      );

  static void noUserFound() => customSnackbar(
        title: '🔍 No User Found',
        message: 'No user found with this email.',
        titleColor: Colors.red,
      );

  static void incorrectPassword() => customSnackbar(
        title: '🔒 Incorrect Password',
        message: 'The password you entered is incorrect.',
        titleColor: Colors.red,
      );

  static void accountBlocked() => customSnackbar(
        title: '🚫 Account Blocked',
        message: 'Your account has been blocked.',
        titleColor: Colors.red,
      );

  static void loginFailed() => customSnackbar(
        title: '😞 Login Failed',
        message: 'Oops! Something went wrong. Please try again.',
        titleColor: Colors.red,
      );

  static void emailAlreadyRegistered() => customSnackbar(
        title: '📧 Email Already Registered',
        message:
            'The provided email address is already associated with an existing account.',
        titleColor: Colors.red,
      );

  static void missingEmail() => customSnackbar(
        title: '📧 Missing Email',
        message: 'Please enter your email.',
        titleColor: Colors.red,
      );

  static void noAccountFoundEmail() => customSnackbar(
        title: '🚫 No Account Found',
        message: 'No user registered with this email.',
        titleColor: Colors.red,
      );

  static void googleSignInCancelled() => customSnackbar(
        title: '🚫 Sign-In Cancelled',
        message: 'Google sign-in was cancelled.',
        titleColor: Colors.red,
      );

  static void facebookSignInCancelled() => customSnackbar(
        title: '🚫 Sign-In Cancelled',
        message: 'Facebook sign-in was cancelled.',
        titleColor: Colors.red,
      );

  static void resetLinkSuccess() => customSnackbar(
        title: '📩 Success',
        message: 'Reset link sent! Check your inbox.',
        titleColor: Colors.green,
      );

  static void resetLinkFailed() => customSnackbar(
        title: '❗ Error',
        message: 'Failed to send reset link. Try again.',
        titleColor: Colors.red,
      );

  static void invalidPhoneNumber() => customSnackbar(
        title: '📱 Invalid Phone Number',
        message: 'Please enter a valid 10-digit phone number.',
        titleColor: Colors.red,
      );

  static void passwordMismatch() => customSnackbar(
        title: '🔁 Password Mismatch',
        message: 'The entered passwords do not match. Please try again.',
        titleColor: Colors.red,
      );

  static void weakPassword() => customSnackbar(
        title: '🔒 Weak Password',
        message: 'Password must be at least 6 characters long.',
        titleColor: Colors.red,
      );

  // 🛒 Cart & Favourites
  static void addToCart() => customSnackbar(
        title: '🛒 Added to Cart',
        message: 'Product has been added to your cart.',
        titleColor: Colors.orange,
      );

  static void alreadyInCart() => customSnackbar(
        title: '🛒 In Cart',
        message: 'Product is already in the cart!',
        titleColor: Colors.orangeAccent,
      );

  static void cartEmpty() => customSnackbar(
        title: '🛒 Cart Empty',
        message: 'Your cart is empty!',
        titleColor: red,
      );

  static void removeFromCart() => customSnackbar(
        title: '❌ Removed',
        message: 'Product removed from your cart.',
        titleColor: Colors.redAccent,
      );

  static void favouriteAdded(String itemName) => customSnackbar(
        title: "💖 Added to Favourites",
        message: "$itemName added to favorites.",
        titleColor: Colors.pink,
      );

  static void favoriteRemoved(String itemName) => customSnackbar(
        title: "💔 Favorite Removed",
        message: "$itemName removed from favorites.",
        titleColor: red,
      );

  static void failedToAddFavorite() => customSnackbar(
        title: '❗ Error',
        message: 'Failed to add to favorites.',
        titleColor: red,
      );

  // 💳 Payment
  static void paymentSuccess() => customSnackbar(
        title: '✅ Paid Successfully',
        message: 'Your order has been paid successfully.',
        titleColor: green,
      );

  static void paymentCancelled() => customSnackbar(
        title: '❌ Payment Cancelled',
        message: 'Your payment was cancelled.',
        titleColor: red,
      );

  static void paymentFailed() => customSnackbar(
        title: '💳 Payment Failed',
        message: 'Unexpected error occurred while processing payment.',
        titleColor: red,
      );

  // 🛠️ Customization
  static void customizeFirst() => customSnackbar(
        title: '⚠️ Customize First',
        message: 'Please customize the product first.',
        titleColor: red,
      );

  static void enterAllDimensions() => customSnackbar(
        title: '📏 Fields Required',
        message: 'Please enter all dimensions.',
        titleColor: red,
      );

  static void dimensionsUpdated() => customSnackbar(
        title: '✅ Dimensions Updated',
        message: 'Dimensions updated successfully.',
        titleColor: green,
      );

  static void customizationDone() => customSnackbar(
        title: '🎉 Customization Done',
        message: 'Customization done successfully.',
        titleColor: green,
      );

  // ✏️ Profile / Comments
  static void profileUpdated() => customSnackbar(
        title: '👤 Profile Updated',
        message: 'Your profile has been updated successfully.',
        titleColor: deepPurple,
      );

  static void commentPosted() => customSnackbar(
        title: '✅ Review Submitted',
        message:
            'Your review has been submitted and is under admin review. It will be visible once approved.',
        titleColor: green,
      );

  static void failedToPostComment() => customSnackbar(
        title: '❗ Error',
        message: 'Failed to post review',
        titleColor: red,
      );

  // 📦 Order
  static void orderFailed() => customSnackbar(
        title: '❌ Failed 😞',
        message: 'Failed to place order. Please try again.',
        titleColor: red,
      );

  // 🧾 Field Validations
  static void emptyFieldsError() => customSnackbar(
        title: '❌ Error',
        message: 'Fields should not be empty.',
        titleColor: red,
      );

  static void requiredFieldsError() => customSnackbar(
        title: '⚠️ Error',
        message: 'Please fill in all the required fields!',
        titleColor: red,
      );

  static void fillAllFieldsError() => customSnackbar(
        title: '⚠️ Please fill all fields',
        message: 'Make sure to select a location and fill in all the details.',
        titleColor: red,
      );

  // 📷 Upload
  static void noFileSelected() => customSnackbar(
        title: '📁 Error',
        message: 'No file selected',
        titleColor: Colors.red,
      );

  static void imageUploadError() => customSnackbar(
        title: '❌ Error',
        message: 'Error uploading image',
        titleColor: Colors.red,
      );

  static void noSecureUrl() => customSnackbar(
        title: '🔒 Error',
        message: 'No secure URL returned',
        titleColor: Colors.red,
      );

  static void imageUploadSuccess() => customSnackbar(
        title: '✅ Success',
        message: 'Image uploaded successfully',
        titleColor: Colors.green,
      );

  // 📞 WhatsApp
  static void whatsappError() => customSnackbar(
        title: '📵 WhatsApp Error',
        message: 'Could not open WhatsApp.',
        titleColor: red,
      );

  //Email Verification
  static void emailVerified() => customSnackbar(
        title: '✅ Verified',
        message: 'Your email is verified. You can now log in.',
        titleColor: green,
      );
  static void emailNotVerified() => customSnackbar(
        title: 'Not Verified ❌',
        message: 'Please verify your email before continuing.',
        titleColor: red,
      );
  static void resendVerification() => customSnackbar(
        title: '📨 Sent Again',
        message: 'Verification email has been resent.',
        titleColor: green,
      );
  static void notResendVerification() => customSnackbar(
        title: '⚠️ Error',
        message: 'Could not resend verification email.',
        titleColor: red,
      );
  static void accountNotVerified() => customSnackbar(
        title: '❌ Account Not Verified',
        message: 'Please create an account and verify your email.',
        titleColor: red,
      );

  static void unauthorizedReviewAttempt() => customSnackbar(
        title: '🚫 Unauthorized',
        message:
            'You are not allowed to write a review for this product. Please purchase and receive it first.',
        titleColor: Colors.redAccent,
      );
}
