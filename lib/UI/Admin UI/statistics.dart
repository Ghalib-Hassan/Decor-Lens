import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  Stream<Map<String, double>> getOrderStatistics() {
    return FirebaseFirestore.instance
        .collection('Orders')
        .snapshots()
        .map((snapshot) {
      int processing = snapshot.docs
          .where((doc) => doc['admin_response'] == 'Processing')
          .length;
      int accepted = snapshot.docs
          .where((doc) => doc['admin_response'] == 'Accepted')
          .length;
      int rejected = snapshot.docs
          .where((doc) => doc['admin_response'] == 'Rejected')
          .length;

      return {
        "Processing": processing.toDouble(),
        "Accepted": accepted.toDouble(),
        "Rejected": rejected.toDouble(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: adminAppbar,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Statistics',
          style: GoogleFonts.poppins(
            fontSize: height * 0.025,
            fontWeight: FontWeight.w600,
            color: white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.06, vertical: height * 0.04),
          child: Column(
            children: [
              Text(
                "Live Order Overview",
                style: GoogleFonts.poppins(
                  fontSize: height * 0.022,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: height * 0.03),
              StreamBuilder<Map<String, double>>(
                stream: getOrderStatistics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: adminAppbar));
                  }

                  if (snapshot.hasError) {
                    return Text("Error loading statistics",
                        style: TextStyle(color: Colors.red));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.values.every((v) => v == 0)) {
                    return Text(
                      "No orders available",
                      style: GoogleFonts.poppins(
                        fontSize: height * 0.02,
                        color: Colors.grey,
                      ),
                    );
                  }

                  Map<String, double> orderData = snapshot.data!;

                  return PieChart(
                    dataMap: orderData,
                    chartRadius: width * 0.5,
                    animationDuration: Duration(milliseconds: 1200),
                    chartType: ChartType.ring,
                    ringStrokeWidth: 30,
                    colorList: [Colors.orange, green, red],
                    legendOptions: LegendOptions(
                      legendPosition: LegendPosition.bottom,
                      legendTextStyle: GoogleFonts.merriweather(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      showChartValues: true,
                      decimalPlaces: 0,
                      chartValueStyle: GoogleFonts.poppins(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
