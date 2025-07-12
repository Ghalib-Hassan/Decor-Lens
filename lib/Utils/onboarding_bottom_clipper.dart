// 🎨 Custom Clipper for Bottom Curve

import 'package:flutter/material.dart';

class BottomRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50); // Start from bottom left, slightly up
    path.quadraticBezierTo(size.width / 2, size.height, size.width,
        size.height - 50); // Smooth arc
    path.lineTo(size.width, 0); // Connect to top right
    path.close(); // Complete path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
