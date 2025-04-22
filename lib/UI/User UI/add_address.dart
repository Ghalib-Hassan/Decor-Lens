import 'package:decor_lens/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Add Address Screen
class AddAddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Add Address",
              showLeading: true,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Address')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text('Save Address'))
                .animate()
                .scale(duration: 300.ms),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }
}
