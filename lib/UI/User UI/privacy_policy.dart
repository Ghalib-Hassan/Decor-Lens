import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String privacyText = '''
At DecorLens, your privacy is our top priority. We collect only essential data to enhance your shopping experience.

1. We do not share your data with third-party vendors.
2. All payments are encrypted and secure.
3. You can request data deletion at any time.

For more info, contact support.
''';

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
              title: "Privacy Policy",
              showLeading: true,
              fontColor: isDarkMode ? white : black,
              leadingIconColor: isDarkMode ? white : black,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(privacyText,
            style: GoogleFonts.manrope(
                fontSize: 15, color: isDarkMode ? white : black)),
      ),
    );
  }
}
