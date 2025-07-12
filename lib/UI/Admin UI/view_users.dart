import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminViewUsers extends StatefulWidget {
  const AdminViewUsers({super.key});

  @override
  State<AdminViewUsers> createState() => _AdminViewUsersState();
}

class _AdminViewUsersState extends State<AdminViewUsers> {
  TextEditingController searchController = TextEditingController();

  void toggleBlockUser(String userId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .update({'is_blocked': !currentStatus});
  }

  // Future<int> getDeliveredOrdersCount(String userId) async {
  //   final ordersQuery = await FirebaseFirestore.instance
  //       .collection('Orders')
  //       .where('User', isEqualTo: userId)
  //       .where('admin_response', isEqualTo: 'Delivered')
  //       .get();
  //
  //   return ordersQuery.docs.length; // Count of delivered orders
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: adminBack,
        appBar: AppBar(
          backgroundColor: adminAppbar,
          elevation: 4,
          shadowColor: Colors.black45,
          title: Text(
            'View Users',
            style: GoogleFonts.poppins(
              fontSize: screenHeight * 0.028,
              color: white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() {}),
                    style: GoogleFonts.poppins(
                      color: black,
                      fontSize: screenHeight * 0.02,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: grey),
                      hintText: 'Search by Name...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                    ),
                  )),
            ),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .orderBy('Name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.aBeeZee(
                          color: black,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No Users found',
                        style: GoogleFonts.aBeeZee(
                          color: black,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                    );
                  }

                  var users = snapshot.data!.docs.where((doc) {
                    String name = doc['Name'].toString().toLowerCase();
                    return name.contains(searchController.text.toLowerCase());
                  }).toList();

                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching users found',
                        style: GoogleFonts.aBeeZee(
                          color: black,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color: white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: user['Profile_picture'] != null
                                    ? NetworkImage(user['Profile_picture'])
                                    : AssetImage("assets/images/default.png")
                                        as ImageProvider,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['Name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: screenHeight * 0.02,
                                        fontWeight: FontWeight.w600,
                                        color: black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user['Email'],
                                      style: GoogleFonts.poppins(
                                        fontSize: screenHeight * 0.015,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // FutureBuilder<int>(
                                    //   future: getDeliveredOrdersCount(user.id),
                                    //   builder: (context, orderSnapshot) {
                                    //     if (orderSnapshot.connectionState == ConnectionState.waiting) {
                                    //       return CustomRichText(label: 'Purchases', value: 'Loading...');
                                    //     }
                                    //     if (orderSnapshot.hasError) {
                                    //       return CustomRichText(label: 'Purchases', value: 'Error');
                                    //     }
                                    //     return RichText(
                                    //       text: TextSpan(
                                    //         text: 'Purchases: ',
                                    //         style: GoogleFonts.mPlusRounded1c(
                                    //           fontWeight: FontWeight.normal,
                                    //           color: black,
                                    //           fontSize: screenHeight * 0.017,
                                    //         ),
                                    //         children: [
                                    //           TextSpan(
                                    //             text: '${orderSnapshot.data}',
                                    //             style: GoogleFonts.mPlusCodeLatin(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: black,
                                    //               fontSize: screenHeight * 0.017,
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                  ],
                                ),
                              ),
                              CustomButton(
                                buttonHeight: screenHeight * 0.045,
                                buttonWidth: screenWidth * 0.22,
                                buttonBorder: BorderSide(
                                  color: user['is_blocked'] ? green : red,
                                ),
                                buttonColor: user['is_blocked'] ? green : red,
                                textColor: user['is_blocked'] ? white : black,
                                buttonText:
                                    user['is_blocked'] ? "Unblock" : "Block",
                                onPressed: () {
                                  toggleBlockUser(user.id, user['is_blocked']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
