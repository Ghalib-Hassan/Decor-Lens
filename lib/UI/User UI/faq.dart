import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqData = [
    {
      'question': 'How to track my order?',
      'answer': 'Go to Orders > Track Order for real-time updates.'
    },
    {
      'question': 'How to return an item?',
      'answer': 'Contact support within 7 days of delivery.'
    },
    {
      'question': 'How to leave a comment or review on a product?',
      'answer': 'Go to the product page and tap on review.'
    },
    {
      'question': 'How to toggle dark mode?',
      'answer':
          'Go to Profile > Security > Dark Mode switch to toggle between light and dark themes.'
    },
    {
      'question': 'How to customize a product?',
      'answer':
          'Tap on the Customize button on the product screen and enter your dimensions before adding to cart.'
    },
  ];

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
              title: "FAQs",
              showLeading: true,
              fontColor: isDarkMode ? white : black,
              leadingIconColor: isDarkMode ? white : black,
            ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqData[index]['question']!,
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? white : black)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faqData[index]['answer']!,
                    style:
                        GoogleFonts.manrope(color: isDarkMode ? white : black)),
              )
            ],
          );
        },
      ),
    );
  }
}
