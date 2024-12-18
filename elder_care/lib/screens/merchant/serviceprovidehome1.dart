import 'dart:convert';

import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/merchant/AdditionalPackages.dart';
import 'package:elder_care/screens/merchant/MedicalViews.dart';
import 'package:elder_care/screens/merchant/ServiceProvideProfile.dart';
import 'package:elder_care/screens/merchant/ServiceProviderNotification.dart';
import 'package:elder_care/screens/merchant/scan_qr.dart';
import 'package:elder_care/screens/merchant/schedules.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ServiceprovidehomeOld extends StatefulWidget {
  final String serviceProviderId;
  final String serviceProviderName;

  ServiceprovidehomeOld({
    required this.serviceProviderId,
    required this.serviceProviderName,
  });

  @override
  _ServiceprovidehomeOldState createState() => _ServiceprovidehomeOldState();
}

class _ServiceprovidehomeOldState extends State<ServiceprovidehomeOld> {
  final RentApi apiService = RentApi();
  Map<String, dynamic>? merchantDetails;

  Future<void> fetchMerchantDetails() async {
    if (merchantDetails != null) return; // Prevent multiple API calls

    final String apiUrl =
        '${apiService.mainurl()}/merchant_details.php?id=${widget.serviceProviderId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted && merchantDetails != data) {
          setState(() {
            merchantDetails = data;
          });
        }
      } else {
        print(
            "Error: Failed to load merchant details. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching merchant details: $error");
    }
  }

  @override
  void initState() {
    super.initState();
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceProviderNotification(),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: Color(0xFF0FADAD),
            child: Icon(
              Icons.notifications_none,
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
                ),
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
    return Container(
      color: Colors.red.withOpacity(0.1), // Debug background color
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.start,
        children: [
          _shortcutCard(Icons.schedule, "Appointment", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicalViews(
                  serviceProviderId: widget.serviceProviderId,
                ),
              ),
            );
          }),
          _shortcutCard(Icons.qr_code, "QR Scanner", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRScanPage()),
            );
          }),
          _shortcutCard(Icons.more_horiz, "Additional Services", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdditionalPackages(
                  serviceProviderId: widget.serviceProviderId,
                  serviceProviderName: widget.serviceProviderName,
                ),
              ),
            );
          }),
          _shortcutCard(Icons.pending_outlined, "Upcoming Appointments", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentsPage(
                  doctorId: widget.serviceProviderId,
                ),
              ),
            );
          }),
        ],
      ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent unbounded height
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
    );
  }
}
