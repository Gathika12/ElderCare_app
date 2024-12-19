import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/login_page.dart';
import 'package:elder_care/screens/merchant/serviceprovider_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart'; // Import the QR code package

class ServiceProvideProfile extends StatefulWidget {
  final String serviceProviderId;

  ServiceProvideProfile({Key? key, required this.serviceProviderId})
      : super(key: key);

  @override
  _ServiceProvideProfileState createState() => _ServiceProvideProfileState();
}

class _ServiceProvideProfileState extends State<ServiceProvideProfile> {
  final RentApi apiService = RentApi();
  String fullName = '';
  String nic = '';
  String email = '';
  String companyName = '';
  String area = '';

  TextEditingController fullNameController = TextEditingController();
  TextEditingController nicController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${apiService.mainurl()}/get_serviceprovider.php?id=${widget.serviceProviderId}'),
      );

      if (response.statusCode == 200) {
        final data = response.body.trim();

        if (data.startsWith('{')) {
          final jsonData = json.decode(data);

          if (jsonData is Map && jsonData.containsKey('full_name')) {
            setState(() {
              fullName = jsonData['full_name'] ?? '';
              nic = jsonData['nic']?.toString() ?? '';
              email = jsonData['email']?.toString() ?? '';
              companyName = jsonData['company_name'] ?? '';
              area = jsonData['area'] ?? '';

              // Initialize text controllers with current profile data
              fullNameController.text = fullName;
              nicController.text = nic;
              emailController.text = email;
              companyNameController.text = companyName;
              areaController.text = area;
            });
          } else {
            print('Error: Invalid JSON structure');
          }
        } else {
          print('Error: Response does not start with "{"');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ServiceproviderLogin()),
    );
  }

  Future<void> _saveProfile() async {
    try {
      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/update_serviceprovider.php'),
        body: {
          'id': widget.serviceProviderId,
          'full_name': fullNameController.text,
          'nic': nicController.text,
          'email': emailController.text,
          'company_name': companyNameController.text,
          'area': areaController.text,
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          fullName = fullNameController.text;
          nic = nicController.text;
          email = emailController.text;
          companyName = companyNameController.text;
          area = areaController.text;
          isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile")),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Service Provider Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),

            // Profile Fields
            ProfileField(
                label: 'Name',
                controller: fullNameController,
                isEditing: isEditing),
            ProfileField(
                label: 'NIC', controller: nicController, isEditing: isEditing),
            ProfileField(
                label: 'Email',
                controller: emailController,
                isEditing: isEditing),
            ProfileField(
                label: 'Company Name',
                controller: companyNameController,
                isEditing: isEditing),
            ProfileField(
                label: 'Area',
                controller: areaController,
                isEditing: isEditing),

            const SizedBox(height: 30.0),

            // Save/Edit Button
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isEditing ? Colors.green : Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                isEditing ? 'Save Profile' : 'Edit Profile',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 20.0),

            // Logout Button
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for Profile Fields
class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;

  ProfileField(
      {required this.label, required this.controller, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 5.0),
          TextField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditing ? Colors.white : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
