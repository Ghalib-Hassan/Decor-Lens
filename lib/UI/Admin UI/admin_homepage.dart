import 'package:decor_lens/UI/Admin%20UI/add_customizable.dart';
import 'package:decor_lens/UI/Admin%20UI/add_item.dart';
import 'package:decor_lens/UI/Admin%20UI/admin_profile.dart';
import 'package:decor_lens/UI/Admin%20UI/business_card.dart';
import 'package:decor_lens/UI/Admin%20UI/city_deliveries.dart';
import 'package:decor_lens/UI/Admin%20UI/notification.dart';
import 'package:decor_lens/UI/Admin%20UI/statistics.dart';
import 'package:decor_lens/UI/Admin%20UI/view_items.dart';
import 'package:decor_lens/UI/Admin%20UI/view_orders.dart';
import 'package:decor_lens/UI/Admin%20UI/view_users.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AdminOption> options = [
      AdminOption(
          "Add New Item", Icons.add_box_outlined, blue, AddItemScreen()),
      AdminOption("Add Customizable", Icons.tune_outlined, Colors.purple,
          AddCustomizableItem()),
      AdminOption("View Items", Icons.view_list_rounded, Colors.indigo,
          AdminViewItems()),
      AdminOption(
          "View Users", Icons.people_alt_outlined, teal, AdminViewUsers()),
      AdminOption("View Orders", Icons.shopping_bag_outlined, Colors.orange,
          AdminOrdersScreen()),
      AdminOption("Statistics", Icons.bar_chart_rounded, green, Statistics()),
      AdminOption("Add Business Card", Icons.credit_card_outlined, Colors.brown,
          AddBusinessCard()),
      AdminOption("City Deliveries", Icons.location_city_rounded,
          Colors.deepOrange, CityDeliveries()),
      AdminOption("Notifications", Icons.notifications_active_outlined, amber,
          AdminNotificationScreen()),
      AdminOption("Admin Profile", Icons.person_outline, deepPurple,
          AdminProfileScreen()),
      AdminOption("Logout", Icons.logout, Colors.redAccent, null,
          isLogout: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) => AdminCard(option: options[index]),
      ),
    );
  }
}

class AdminOption {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? screen;
  final bool isLogout;

  AdminOption(this.title, this.icon, this.color, this.screen,
      {this.isLogout = false});
}

class AdminCard extends StatelessWidget {
  final AdminOption option;

  const AdminCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (option.isLogout) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          if (user != null && user.email != null) {
            String? password;
            await Get.defaultDialog(
              title: "Confirm Logout",
              content: Column(
                children: [
                  const Text("Enter your password to logout & delete."),
                  const SizedBox(height: 10),
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    obscureText: true,
                    onChanged: (value) => password = value,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              textCancel: "Cancel",
              textConfirm: "Confirm",
              confirmTextColor: white,
              buttonColor: appColor,
              onConfirm: () async {
                Get.back();
                if (password == null || password!.isEmpty) {
                  customSnackbar(
                    title: "Password Required",
                    message:
                        "You must enter a password to delete your account.",
                    titleColor: red,
                    iconColor: red,
                    icon: Icons.error_outline,
                  );
                  return;
                }
                try {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password!,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.delete();
                  customSnackbar(
                    title: "Success",
                    message: "Logged out successfully.",
                    titleColor: green,
                    iconColor: green,
                    icon: Icons.check_circle_outline,
                  );
                  Get.offAll(() => const UserLogin());
                } catch (_) {
                  customSnackbar(
                    title: "Failed",
                    message: "Incorrect password or network error.",
                    titleColor: red,
                    iconColor: red,
                    icon: Icons.error_outline,
                  );
                }
              },
            );
          }
        } else {
          Get.to(() => option.screen!, transition: Transition.rightToLeft);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: option.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: option.color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: option.color.withOpacity(0.15),
              child: Icon(option.icon, color: option.color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              option.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}
