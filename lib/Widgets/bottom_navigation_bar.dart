import 'package:audioplayers/audioplayers.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/User%20UI/account_screen.dart';
import 'package:decor_lens/UI/User%20UI/cart_screen.dart';
import 'package:decor_lens/UI/User%20UI/favourite_screen.dart';
import 'package:decor_lens/UI/User%20UI/home_screen.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int? selectedIndex;
  final AudioPlayer _audioPlayer = AudioPlayer(); // <-- Create instance

  Future<void> _playSwipeSound() async {
    await _audioPlayer.play(AssetSource('Sounds/swipe.mp3'));
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(BuildContext context, int index) async {
    if (index == widget.currentIndex) return;

    await _playSwipeSound(); // <-- Play sound before navigating

    setState(() {
      selectedIndex = index;
    });

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = HomeScreen();
        break;
      case 1:
        nextScreen = FavouriteScreen();
        break;
      case 2:
        nextScreen = Cart();
        break;
      case 3:
        nextScreen = MyAccount();
        break;
      default:
        return;
    }

    Get.offAll(() => nextScreen, transition: Transition.fadeIn);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // <-- Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? kOffBlack : white,
        boxShadow: [
          BoxShadow(
              color: isDarkMode ? white.withOpacity(.1) : black.withOpacity(.1),
              blurRadius: 8,
              spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (index) {
          bool isSelected = widget.currentIndex == index;
          return AnimatedScale(
            scale: isSelected ? 1.3 : 1.0, // Scale effect on selection
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              onTap: () => _onItemTapped(context, index),
              child: SvgPicture.asset(
                _getIconPath(index),
                height: 25,
                // width: 30,
                colorFilter: ColorFilter.mode(
                  isSelected ? blue : grey,
                  BlendMode.srcIn,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getIconPath(int index) {
    switch (index) {
      case 0:
        return 'assets/svg/home.svg';
      case 1:
        return 'assets/svg/favorite.svg';
      case 2:
        return 'assets/svg/cart.svg';
      case 3:
        return 'assets/svg/account.svg';
      default:
        return 'assets/svg/home.svg';
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'My Cart';
      case 2:
        return 'My Account';
      default:
        return 'Home';
    }
  }
}
