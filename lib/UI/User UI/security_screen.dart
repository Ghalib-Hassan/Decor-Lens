import 'package:decor_lens/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Security Screen
class SecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Security",
              showLeading: true,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: Ghalib Hassan',
                style: GoogleFonts.nunitoSans(fontSize: 18)),
            Text('Email: ghalibthassan@gmail.com',
                style: GoogleFonts.nunitoSans(fontSize: 18)),
            Text('Password: ********',
                style: GoogleFonts.nunitoSans(fontSize: 18)),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: false,
              onChanged: (value) {},
            ),
            ExpansionTile(
              title: Text('FAQ'),
              children: [
                ListTile(title: Text('How to change password?')),
                ListTile(title: Text('How to enable 2FA?')),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}
