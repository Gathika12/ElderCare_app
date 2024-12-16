import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart'; // Import the QR code package

class UserProfile extends StatefulWidget {
  final String userId;

  UserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final RentApi apiService = RentApi();
  final _formKey = GlobalKey<FormState>();

  Map<String, TextEditingController> fieldControllers = {};
  List<String> fieldKeys = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse(
          '${apiService.mainurl()}/get_user.php?id=${widget.userId}'));

      print('Response body: ${response.body}'); // Log response for debugging

      if (response.statusCode == 200) {
        final data = response.body.trim();

        if (data.startsWith('{')) {
          final jsonData = json.decode(data);

          if (jsonData is Map) {
            setState(() {
              fieldKeys = jsonData.keys.map((key) => key.toString()).toList();
              for (String key in fieldKeys) {
                fieldControllers[key] = TextEditingController(
                    text: jsonData[key]?.toString() ?? '');
              }
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

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final Map<String, String> updatedData = {};
      for (String key in fieldKeys) {
        updatedData[key] = fieldControllers[key]?.text ?? '';
      }

      updatedData['user_id'] = widget.userId; // Ensure user_id is included

      print('Sending POST data: $updatedData'); // Debug POST data

      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/update_user.php'),
        body: updatedData,
      );

      print('Response body: ${response.body}'); // Debug response

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() {
            isEditing = false; // Exit edit mode
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Update failed')),
          );
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
                data:
                    'UserID: ${widget.userId}\nDetails: ${fieldControllers.map((key, value) => MapEntry(key, value.text))}',
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
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Dynamic Profile Fields
                  for (String key in fieldKeys)
                    ProfileField(
                      label: key.replaceAll('_', ' ').toUpperCase(),
                      controller: fieldControllers[key]!,
                      isEditing: isEditing,
                    ),
                  const SizedBox(height: 30.0),

                  // Edit/Save Button
                  ElevatedButton(
                    onPressed: isEditing
                        ? updateUserProfile
                        : () => setState(() {
                              isEditing = true; // Enter edit mode
                            }),
                    child: Text(isEditing ? 'Save Profile' : 'Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 15.0),
                      textStyle: const TextStyle(fontSize: 18.0),
                      backgroundColor: isEditing ? Colors.green : Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16.0,
            top: 10.0,
            child: IconButton(
              icon: Icon(Icons.qr_code, size: 45.0, color: Colors.blue),
              onPressed: _showQRCodeDialog,
              tooltip: 'Show QR Code',
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for editable Profile Fields
class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;

  ProfileField({
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
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
          TextFormField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label cannot be empty';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
