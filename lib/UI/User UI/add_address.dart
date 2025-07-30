import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Provider/dark_mode_provider.dart';
import 'package:decor_lens/UI/Auth%20Screens/user_login.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/Widgets/appbar.dart';
import 'package:decor_lens/Widgets/custom_button.dart';
import 'package:decor_lens/Widgets/snackbar_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  Completer<GoogleMapController> controller = Completer();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  String setAddress = '';
  String city = '';
  bool isLoading = false;
  LatLng? selectedPosition;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(30.3749, 69.3494),
    zoom: 5.0,
  );

  final List<Marker> _markers = [];

  Future<void> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition();

      selectedPosition = LatLng(position.latitude, position.longitude);

      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: selectedPosition!,
        ),
      );

      final GoogleMapController mapController = await controller.future;
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedPosition!, zoom: 14),
      ));

      // ✅ Call getAddressFromLatLng right after position is set
      await getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {});
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          setAddress = address;
          city = place.locality ?? 'Unknown City';
        });

        print("Resolved Address: $setAddress");
        print("City: $city");
      } else {
        print("No address found.");
        setState(() {
          setAddress = "Address not found.";
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        setAddress = "Error fetching address.";
      });
    }
  }

  Future<void> fetchPhoneNumber() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        final phone = data['Phone_number'];
        final name = data['Name'];

        // Handle phone number
        if (phone != null && phone.toString().isNotEmpty) {
          String formattedPhone = phone.toString();
          if (formattedPhone.startsWith('+92')) {
            formattedPhone = formattedPhone.replaceFirst('+92', '');
          }
          phoneController.text = formattedPhone;
        } else {
          phoneController.text =
              ''; // 👈 Initially blank — we handle prefix in the field widget
        }

        // Handle name
        nameController.text = name?.toString() ?? '';
      } else {
        phoneController.text = '';
        nameController.text = '';
      }
    } catch (e) {
      print("Error fetching phone number: $e");
      phoneController.text = '';
      nameController.text = '';
    }
  }

  Future<void> saveAddress() async {
    setState(() {
      isLoading = true;
    });
    if (selectedPosition == null ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        zipCodeController.text.isEmpty) {
      SnackbarMessages.fillAllFieldsError();

      setState(() {
        isLoading = false;
      });
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final addressData = {
      'Name': nameController.text.trim(),
      'Address': setAddress,
      'City': city,
      'Phone_number': '+92${phoneController.text.trim()}',
      'Zip_code': zipCodeController.text.trim(),
      'lat': selectedPosition!.latitude,
      'lng': selectedPosition!.longitude,
      'Timestamp': Timestamp.now(),
    };

    final docRef = FirebaseFirestore.instance.collection('Users').doc(uid);

    await docRef.set({
      'addresses': FieldValue.arrayUnion([addressData])
    }, SetOptions(merge: true));

    setState(() {
      isLoading = false;
    });

    // ✅ Go back to the previous screen
    Get.back(
      result: 'address_saved',
      closeOverlays: true,
    );
  }

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation();
    fetchPhoneNumber();
    checkUserBlockedStatus();
  }

  Future<void> checkUserBlockedStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('uid $userId');

    if (userId == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('User_id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        bool isBlocked = userDoc['is_blocked'] ?? false;

        if (isBlocked) {
          SnackbarMessages.accountBlocked();
          FirebaseAuth.instance.signOut();

          final darkModeService =
              Provider.of<DarkModeService>(context, listen: false);
          await darkModeService.clearDarkModePreference();

          Get.offAll(
            () => UserLogin(),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking blocked status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeService = Provider.of<DarkModeService>(context);
    final isDarkMode = darkModeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? kOffBlack : white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MyAppbar(
          title: "Add Address",
          showLeading: true,
          fontColor: isDarkMode ? white : black,
          leadingIconColor: isDarkMode ? white : black,
        ).animate().fade(duration: 500.ms).slideY(begin: -0.3, end: 0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialPosition,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        markers: Set<Marker>.of(_markers),
                        onTap: (LatLng pos) async {
                          selectedPosition = pos;
                          _markers.clear();
                          _markers.add(
                            Marker(
                              markerId: MarkerId('selected'),
                              position: pos,
                            ),
                          );

                          setState(() {
                            setAddress = "Fetching address...";
                          });

                          // 🔁 Convert selected lat/lng to address
                          await getAddressFromLatLng(
                              pos.latitude, pos.longitude);
                        },
                        onMapCreated: (GoogleMapController mapController) {
                          controller.complete(mapController);
                        },
                      ),
                      if (selectedPosition != null && setAddress.isNotEmpty)
                        Positioned(
                          top: 350,
                          right: 10,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            width: 260,
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_pin,
                                        color: red, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      "Selected Location",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                  height: 16,
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.my_location,
                                        size: 16, color: Colors.grey.shade700),
                                    SizedBox(width: 6),
                                    Text(
                                      "Lat: ${selectedPosition!.latitude.toStringAsFixed(5)}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.my_location_outlined,
                                        size: 16, color: Colors.grey.shade700),
                                    SizedBox(width: 6),
                                    Text(
                                      "Lng: ${selectedPosition!.longitude.toStringAsFixed(5)}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.grey.shade300),
                                SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.place, color: green, size: 18),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                          setAddress.isNotEmpty
                                              ? setAddress
                                              : "Fetching address...",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: black,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: isDarkMode ? white : black,
                        ),
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? white.withOpacity(.5)
                                : black.withOpacity(.5),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        maxLength: 10,
                        controller: phoneController,
                        style: TextStyle(
                          color: isDarkMode ? white : black,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixText: "+92 ",
                          prefixStyle:
                              GoogleFonts.poppins(color: grey.withOpacity(.6)),
                          prefixIcon:
                              Icon(Icons.phone, color: grey.withOpacity(.6)),
                          counterText: '',
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? white.withOpacity(.5)
                                : black.withOpacity(.5),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: zipCodeController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDarkMode ? white : black,
                        ),
                        decoration: InputDecoration(
                          labelText: "Zip Code",
                          labelStyle: TextStyle(
                            color: isDarkMode
                                ? white.withOpacity(.5)
                                : black.withOpacity(.5),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomButton(
                          buttonBorder: BorderSide(color: appColor),
                          buttonHeight: 50,
                          buttonWidth: double.infinity,
                          buttonColor: isDarkMode ? white : appColor,
                          isLoading: isLoading,
                          fonts: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? black : white),
                          buttonText: 'Save Address',
                          onPressed: saveAddress)
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 330,
              left: 16,
              child: FloatingActionButton(
                onPressed: getUserCurrentLocation,
                backgroundColor: isDarkMode ? white : appColor,
                child: Icon(
                  Icons.my_location,
                  color: isDarkMode ? black : white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
