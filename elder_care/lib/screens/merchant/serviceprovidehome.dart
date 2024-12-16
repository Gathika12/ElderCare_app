import 'dart:convert';

import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/merchant/AdditionalPackages.dart';
import 'package:elder_care/screens/merchant/MedicalViews.dart';
import 'package:elder_care/screens/merchant/ServiceProvideProfile.dart';
import 'package:elder_care/screens/merchant/scan_qr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ServiceProvidePage extends StatefulWidget {
  final String serviceProviderId;
  final String serviceProviderName;

  ServiceProvidePage({
    required this.serviceProviderId,
    required this.serviceProviderName,
  });

  @override
  _ServiceProvidePageState createState() => _ServiceProvidePageState();
}

class _ServiceProvidePageState extends State<ServiceProvidePage> {
  final RentApi apiService = RentApi();
  Map<String, dynamic>? merchantDetails;

  Future<void> fetchMerchantDetails() async {
    // Build the URL dynamically using the API service
    final String apiUrl =
        '${apiService.mainurl()}/merchant_details.php?id=${widget.serviceProviderId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          merchantDetails = json.decode(response.body);
        });
      } else {
        print(
            "Error: Failed to load merchant details. Status code: ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      print("Error fetching merchant details: $error");
      print("Stack trace: $stackTrace");
    }
  }

  @override
  void initState() {
    super.initState();
    print("Service Provider ID: ${widget.serviceProviderId}");
    fetchMerchantDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                _buildDetailsCard(),
                SizedBox(height: 20),
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                _buildShortcutGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              merchantDetails?["full_name"] != null
                  ? "Hi ${merchantDetails!["full_name"]}"
                  : "Welcome!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            print(
                "Navigating to profile with Service Provider ID: ${widget.serviceProviderId}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceProvideProfile(
                  serviceProviderId: widget.serviceProviderId,
                ),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: Color(0xFF0FADAD),
            child: Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Color(0xFF0FADAD),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print(
                        "Navigating to profile with Service Provider ID: ${widget.serviceProviderId}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProvideProfile(
                          serviceProviderId: widget.serviceProviderId,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                    backgroundColor: Colors.white,
                    radius: 30,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantDetails?["full_name"] ?? "Loading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      merchantDetails?["category"] ?? "Loading...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  print(
                      "Navigating to profile with Service Provider ID: ${widget.serviceProviderId}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProvideProfile(
                        serviceProviderId: widget.serviceProviderId,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Color(0xFF0FADAD),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 3 / 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _shortcutCard(Icons.medical_services, "Packages", () {
          print(
              "Navigating to Medical Views with Service Provider ID: ${widget.serviceProviderId}");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicalViews()),
          );
        }),
        _shortcutCard(Icons.qr_code, "QR Scanner", () {
          print(
              "Navigating to QR Scanner with Service Provider ID: ${widget.serviceProviderId}");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScanPage()),
          );
        }),
        _shortcutCard(Icons.more_horiz, "Additional Services", () {
          print(
              "Navigating to Additional Packages with Service Provider ID: ${widget.serviceProviderId}");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdditionalPackages(
                      serviceProviderId: widget.serviceProviderId,
                      serviceProviderName: widget.serviceProviderName,
                    )),
          );
        }),
        _shortcutCard(Icons.payment, "Payments", () {
          print(
              "Navigating to Payments with Service Provider ID: ${widget.serviceProviderId}");
          // Add navigation to payments page here
        }),
      ],
    );
  }

  Widget _shortcutCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Color(0xFF0FADAD),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
