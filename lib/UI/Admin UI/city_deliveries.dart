import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CityDeliveries extends StatefulWidget {
  const CityDeliveries({super.key});

  @override
  State<CityDeliveries> createState() => _CityDeliveriesState();
}

class _CityDeliveriesState extends State<CityDeliveries> {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController deliveryAmountController =
      TextEditingController();
  String? selectedProvince;
  bool isLoading = false;

  List<String> provinces = [
    "Khyber Pakhtunkhwa",
    "Punjab",
    "Sindh",
    "Balochistan",
    "Gilgit-Baltistan",
  ];

  void openCityDialog(
      {String? docId, String? province, String? city, String? amount}) {
    if (province != null) selectedProvince = province;
    if (city != null) cityController.text = city;
    if (amount != null) deliveryAmountController.text = amount;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    docId == null ? "Add City Delivery" : "Edit City Delivery",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedProvince,
                    items: provinces.map((province) {
                      return DropdownMenuItem(
                        value: province,
                        child: Text(province),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedProvince = value),
                    decoration: InputDecoration(
                      labelText: "Select Province",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: "Enter City Name",
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: deliveryAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter Delivery Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        buttonBorder: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        buttonColor: Colors.grey.shade300,
                        buttonText: 'Cancel',
                        textColor: black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        buttonHeight: 40,
                        buttonWidth: 100,
                      ),
                      CustomButton(
                        buttonColor: appColor,
                        buttonText: docId == null ? "Save" : "Update",
                        onPressed: () => saveOrUpdateCityDelivery(docId),
                        buttonHeight: 40,
                        buttonWidth: 100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> saveOrUpdateCityDelivery(String? docId) async {
    if (selectedProvince == null ||
        cityController.text.isEmpty ||
        deliveryAmountController.text.isEmpty) {
      customSnackbar(
        title: 'Error',
        message: 'Please fill all the fields!',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = {
        "province": selectedProvince,
        "city": cityController.text.trim(),
        "delivery_amount": double.parse(deliveryAmountController.text.trim()),
        "timestamp": FieldValue.serverTimestamp(),
      };

      if (docId == null) {
        await FirebaseFirestore.instance
            .collection("City Deliveries")
            .add(data);
        customSnackbar(
          title: 'Added',
          message: 'City Delivery added successfully!',
          messageColor: black,
          titleColor: green,
          icon: Icons.check,
          iconColor: green,
          backgroundColor: white,
        );
      } else {
        await FirebaseFirestore.instance
            .collection("City Deliveries")
            .doc(docId)
            .update(data);
        customSnackbar(
          title: 'Updated',
          message: 'City Delivery updated successfully!',
          messageColor: black,
          titleColor: green,
          icon: Icons.check,
          iconColor: green,
          backgroundColor: white,
        );
      }

      Navigator.pop(context);
      cityController.clear();
      deliveryAmountController.clear();
    } catch (e) {
      customSnackbar(
        title: 'Error',
        message: '$e',
        messageColor: black,
        titleColor: red,
        icon: Icons.error_outline,
        iconColor: red,
        backgroundColor: white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: adminBack,
      appBar: AppBar(
        backgroundColor: adminAppbar,
        title: Text(
          'Manage City Deliveries',
          style: GoogleFonts.poppins(
            fontSize: screenHeight * 0.025,
            color: white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appColor,
        onPressed: () => openCityDialog(),
        child: Icon(Icons.add, color: white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("CityDeliveries")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No City Deliveries Added Yet!",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    title: Text(
                      "${data['province']} - ${data['city']}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Delivery Amount: Rs. ${data['delivery_amount']}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => openCityDialog(
                            docId: data.id,
                            province: data['province'],
                            city: data['city'],
                            amount: data['delivery_amount'].toString(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("CityDeliveries")
                                .doc(data.id)
                                .delete();
                            customSnackbar(
                              title: 'Deleted',
                              message: 'City Delivery deleted successfully!',
                              messageColor: black,
                              titleColor: red,
                              icon: Icons.delete_outline,
                              iconColor: red,
                              backgroundColor: white,
                            );
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
    );
  }
}
