import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart'; // Import the QR code package

class UserProfile extends StatefulWidget {
  final String email;

  UserProfile({Key? key, required this.email}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String fullName = '';
  String nic = '';
  String birthday = '';
  String age = '';
  String gender = '';
  String mobileNo = '';
  String bloodGroup = '';
  String healthIssues = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/eldercare/get_user.php?email=${widget.email}'));

      if (response.statusCode == 200) {
        final data = response.body.trim();

        if (data.startsWith('{')) {
          final jsonData = json.decode(data);

          if (jsonData is Map && jsonData.containsKey('full_name')) {
            setState(() {
              fullName = jsonData['full_name'] ?? '';
              nic = jsonData['nic']?.toString() ?? '';
              age = jsonData['age']?.toString() ?? '';
              bloodGroup = jsonData['blood_group'] ?? '';
              healthIssues = jsonData['health_issues'] ?? '';
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

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Scan Your QR Code')),
          content: SizedBox(
            width: 200.0,
            height: 200.0,
            child: Center(
              child: QrImageView(
                data: 'NIC: $nic\nFull Name: $fullName\nEmail: ${widget.email}',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content of the page
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Center(
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                ),
                SizedBox(height: 20.0),

                // User Profile Title
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 20.0),

                // Profile Fields
                ProfileField(label: 'Name', value: fullName),
                SizedBox(height: 10.0),
                ProfileField(label: 'NIC', value: nic),
                SizedBox(height: 10.0),
                ProfileField(label: 'Age', value: age),
                SizedBox(height: 10.0),
                ProfileField(label: 'Email', value: widget.email),
                SizedBox(height: 10.0),
                ProfileField(label: 'Blood Group', value: bloodGroup),
                SizedBox(height: 10.0),
                ProfileField(label: 'Health Issues', value: healthIssues),
                SizedBox(height: 30.0),

                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    // Edit action
                  },
                  child: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                    textStyle: TextStyle(fontSize: 18.0),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16.0,
            top: 10.0,
            child: IconButton(
              icon: Icon(Icons.qr_code, size: 40.0, color: Colors.blue),
              onPressed: () {
                _showQRCodeDialog();
              },
              tooltip: 'Show QR Code',
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for Profile Fields
class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0), // Space between fields
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
          SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.all(12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, // Change to white for contrast
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
