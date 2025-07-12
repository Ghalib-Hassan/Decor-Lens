import 'dart:math';
import 'package:flutter/material.dart';

// List of colors
final List<Color> productColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.yellow,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.cyan,
  Colors.brown,
  Colors.deepOrange,
  Colors.lime,
  Colors.amber,
  Colors.deepPurple,
];

// Function to get a random color from the list
Color getRandomColor() {
  final Random random = Random();
  return productColors[random.nextInt(productColors.length)];
}
