import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DarkModeService with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  DarkModeService() {
    _initializeDarkMode();
  }

  // Initialize dark mode based on the current user
  Future<void> _initializeDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String userKey = 'darkMode_${user.uid}'; // Unique key per user
      if (!prefs.containsKey(userKey)) {
        // New user, set default to false
        await prefs.setBool(userKey, false);
      }
      _isDarkMode = prefs.getBool(userKey) ?? false;
    } else {
      _isDarkMode = false; // Default if user is not logged in
    }

    notifyListeners();
  }

  // Toggle dark mode for the current user
  Future<void> toggleDarkMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String userKey = 'darkMode_${user.uid}';
      await prefs.setBool(userKey, value);
    }

    _isDarkMode = value;
    notifyListeners();
  }

  // Clear dark mode preference on logout
  Future<void> clearDarkModePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String userKey = 'darkMode_${user.uid}';
      await prefs.remove(userKey); // Remove the preference for the current user
    }

    _isDarkMode = false; // Reset dark mode setting
    notifyListeners();
  }
}
