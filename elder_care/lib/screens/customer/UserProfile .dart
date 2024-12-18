import 'dart:ui';

import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart'; // Import the QR code package
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

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
  DateTime? _selectedBirthday; // To store the selected birthday

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

              // Initialize the selected birthday
              if (jsonData.containsKey('birthday') &&
                  jsonData['birthday'].isNotEmpty) {
                _selectedBirthday = DateTime.tryParse(jsonData['birthday']);
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

      // Add formatted birthday to updated data
      if (_selectedBirthday != null) {
        updatedData['birthday'] =
            "${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}";
      }

      updatedData['id'] = widget.userId; // Ensure 'id' is included

      print('Sending JSON POST data: ${json.encode(updatedData)}');

      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/update_user.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      print('Response body: ${response.body}');

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

  Future<void> _generateQRCodePDF() async {
    final pdf = pw.Document();

    // Convert QR code data to an image
    final qrCode = await QrPainter(
      data:
          'UserID: ${widget.userId}\nDetails: ${fieldControllers.map((key, value) => MapEntry(key, value.text))}',
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
    ).toImage(200);

    final qrBytes = await qrCode.toByteData(format: ImageByteFormat.png);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Image(
            pw.MemoryImage(qrBytes!.buffer.asUint8List()),
          ),
        ),
      ),
    );

    // Trigger PDF download
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'qr_code.pdf',
    );
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
            TextButton(
              onPressed: _generateQRCodePDF,
              child: Text('Download PDF'),
            ),
          ],
        );
      },
    );
  }

  void _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        fieldControllers['birthday']?.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
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
                    if (key == 'birthday')
                      GestureDetector(
                        onTap: isEditing
                            ? () => _selectBirthday(context)
                            : null, // Allow selecting only in edit mode
                        child: ProfileField(
                          label: 'BIRTHDAY',
                          controller: fieldControllers[key]!,
                          isEditing: false, // Prevent direct editing
                        ),
                      )
                    else
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

          // QR Code Icon Button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.qr_code,
                color: Colors.teal,
                size: 40,
              ),
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
