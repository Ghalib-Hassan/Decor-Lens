import 'package:decor_lens/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Orders Screen
class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) {
            return MyAppbar(
              title: "Orders",
              showLeading: true,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Order #$index'),
            subtitle: Text('Delivered on 12 Mar 2025'),
          ).animate().fadeIn(duration: 500.ms).slideX();
        },
      ),
    );
  }
}
