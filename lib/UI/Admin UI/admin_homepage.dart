import 'package:decor_lens/UI/Admin%20UI/add_customizable.dart';
import 'package:decor_lens/UI/Admin%20UI/add_item.dart';
import 'package:decor_lens/UI/Admin%20UI/admin_profile.dart';
import 'package:decor_lens/UI/Admin%20UI/business_card.dart';
import 'package:decor_lens/UI/Admin%20UI/city_deliveries.dart';
import 'package:decor_lens/UI/Admin%20UI/view_items.dart';
import 'package:decor_lens/UI/Admin%20UI/view_users.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    final List<adminOption> options = [
      adminOption("Add New Item", Icons.add_box_outlined, Colors.blue),
      adminOption("Add Customizable", Icons.tune_outlined, Colors.purple),
      adminOption("View Items", Icons.view_list_rounded, Colors.indigo),
      adminOption("View Users", Icons.people_alt_outlined, Colors.teal),
      adminOption("View Orders", Icons.shopping_bag_outlined, Colors.orange),
      adminOption("Statistics", Icons.bar_chart_rounded, Colors.green),
      adminOption(
          "Add Business Card", Icons.credit_card_outlined, Colors.brown),
      adminOption(
          "City Deliveries", Icons.location_city_rounded, Colors.deepOrange),
      adminOption(
          "Notifications", Icons.notifications_active_outlined, Colors.amber),
      adminOption("Admin Profile", Icons.person_outline, Colors.deepPurple),
      adminOption("Logout", Icons.logout, Colors.redAccent, isLogout: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        elevation: 0,
        backgroundColor: Color(0xFFF9F9F9),
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.merriweather(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(20),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return adminOptionCard(option: option);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class adminOption {
  final String title;
  final IconData icon;
  final Color color;
  final bool isLogout;

  adminOption(this.title, this.icon, this.color, {this.isLogout = false});
}

class adminOptionCard extends StatelessWidget {
  final adminOption option;

  const adminOptionCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Add onTap navigation logic here
        if (option.isLogout || option.title == "Logout") {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          if (user != null && user.email != null) {
            String? password;

            // 🔐 Ask for password before deleting
            await Get.defaultDialog(
              title: "Confirm Logout",
              titleStyle: TextStyle(color: black),
              content: Column(
                children: [
                  Text(
                    "Please enter your password to confirm logout & delete.",
                    style: TextStyle(color: black),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(color: black),
                      obscureText: true,
                      onChanged: (value) => password = value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: white,
              textCancel: "Cancel",
              textConfirm: "Confirm",
              confirmTextColor: white,
              buttonColor: appColor,
              cancelTextColor: red,
              onConfirm: () async {
                Get.back(); // close dialog

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
                  // ✅ Re-authenticate
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password!,
                  );

                  await user.reauthenticateWithCredential(credential);

                  // ✅ Now delete the account
                  await user.delete();

                  customSnackbar(
                    title: "Success",
                    message: "Logged out successfully.",
                    titleColor: green,
                    iconColor: green,
                    icon: Icons.check_circle_outline,
                  );

                  Get.offAll(() => UserLogin(), transition: Transition.zoom);
                } catch (e) {
                  print("Account deletion failed: $e");

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
        } else if (option.title == "Add New Item") {
          Get.to(AddItemScreen(), transition: Transition.rightToLeft);
        } else if (option.title == "Add Customizable") {
          Get.to(AddCustomizableItem(), transition: Transition.rightToLeft);
        } else if (option.title == "View Items") {
          Get.to(AdminViewItems(), transition: Transition.rightToLeft);
        } else if (option.title == "View Users") {
          Get.to(AdminViewUsers(), transition: Transition.rightToLeft);
        } else if (option.title == "Add Business Card") {
          Get.to(AddBusinessCard(), transition: Transition.rightToLeft);
        } else if (option.title == "City Deliveries") {
          Get.to(CityDeliveries(), transition: Transition.rightToLeft);
        } else if (option.title == "Admin Profile") {
          Get.to(AdminProfileScreen(), transition: Transition.rightToLeft);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: option.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: option.color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(option.icon, size: 30, color: option.color),
            const SizedBox(width: 20),
            Text(
              option.title,
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: option.color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 18, color: option.color),
          ],
        ),
      ),
    );
  }
}
