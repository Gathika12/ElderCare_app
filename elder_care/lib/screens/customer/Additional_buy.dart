import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class AdditionalBuy extends StatefulWidget {
  final int serviceId;
  final String userId;
  final String packageName;
  final String packagePrice;
  final String packageType;

  AdditionalBuy({
    required this.serviceId,
    required this.userId,
    required this.packageName,
    required this.packagePrice,
    required this.packageType,
  });

  @override
  _AdditionalBuyState createState() => _AdditionalBuyState();
}

class _AdditionalBuyState extends State<AdditionalBuy> {
  final RentApi apiService = RentApi();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController payeeNameController = TextEditingController();
  final TextEditingController packageNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String fullName = '';
  dynamic packageData;
  bool isLoading = true;
  File? slipImage; // For storing the selected image
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    packageNameController.text = widget.packageName;
    priceController.text = widget.packagePrice;
    fetchUserProfile();
    fetchPackageDetails();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse(
          '${apiService.mainurl()}/get_user1.php?id=${widget.userId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body.trim());
        setState(() {
          userIdController.text = widget.userId;
          userNameController.text = data['full_name'] ?? '';
          payeeNameController.text =
              data['full_name'] ?? ''; // Example payee name
          fullName = data['full_name'] ?? '';
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchPackageDetails() async {
    try {
      // Log the API URL being called
      print(
          'Fetching package details from: ${apiService.mainurl()}/get_additional.php?id=${widget.serviceId}');

      final response = await http.get(Uri.parse(
          '${apiService.mainurl()}/get_additional.php?id=${widget.serviceId}'));

      // Log the HTTP status code
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Log the response body for debugging
        print('Response body: ${response.body}');

        setState(() {
          packageData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Log error if the status code is not 200
        print(
            'Error: Failed to load package. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        setState(() {
          isLoading = false;
          packageData = {'error': 'Failed to load package'};
        });
      }
    } catch (e) {
      // Log the network or other exceptions
      print('Network error: $e');

      setState(() {
        isLoading = false;
        packageData = {'error': 'Network error: $e'};
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        slipImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Package Purchase'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (packageData != null && packageData.containsKey('error'))
                Center(
                  child: Text(
                    packageData['error'],
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              else
                Column(
                  children: [
                    _buildTextField('User ID', userIdController),
                    SizedBox(height: 16),
                    _buildTextField('User Name', userNameController),
                    SizedBox(height: 16),
                    _buildTextField('Package Name', packageNameController),
                    SizedBox(height: 16),
                    _buildTextField('Package Price', priceController),
                    SizedBox(height: 16),
                    _buildTextField('Payee Name', payeeNameController),
                    SizedBox(height: 16),
                    Text(
                      'Upload Slip Image',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: slipImage == null
                            ? Center(
                                child: Text(
                                  'Tap to upload image',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 16),
                                ),
                              )
                            : Image.file(
                                slipImage!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: Colors.teal[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.teal[800],
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Payment Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[800],
                                  ),
                                ),
                              ],
                            ),
                            Divider(thickness: 1, color: Colors.teal[200]),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Account Name:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Eldercare System',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.teal[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Account Number:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '1234567890',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.teal[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment Method:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Bank Transfer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.teal[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Instructions:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'After completing the transfer, please upload the payment receipt here or send it to our WhatsApp number for verification.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.chat,
                                    color: Colors.teal[700], size: 24),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // Replace the number below with the actual WhatsApp number
                                    final whatsappNumber = '+1234567890';
                                    final whatsappUrl =
                                        'https://wa.me/$whatsappNumber?text=Hello,%20I%20would%20like%20to%20send%20my%20payment%20receipt.';
                                    // Open the WhatsApp URL
                                    launchUrl(Uri.parse(whatsappUrl));
                                  },
                                  child: Text(
                                    '+123 456 7890',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[700],
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _onPay,
                      child: Text(
                        'Pay',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          readOnly: true,
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Check if file is an image or PDF
      if (file.path.endsWith('.pdf') ||
          file.path.endsWith('.jpg') ||
          file.path.endsWith('.png')) {
        setState(() {
          slipImage = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Only PDF or Image files are allowed.')),
        );
      }
    }
  }

  Future<void> _onPay() async {
    var uri = Uri.parse('${apiService.mainurl()}/bill.php');
    var request = http.MultipartRequest('POST', uri);

    // Add form fields
    request.fields['elder_id'] = userIdController.text;
    request.fields['payment_type'] = widget.packageType;
    request.fields['service'] = packageNameController.text;
    request.fields['amount'] = widget.packagePrice;
    request.fields['paidby'] = payeeNameController.text;

    // Attach the file only if provided
    if (slipImage != null) {
      String fileName = slipImage!.path.split('/').last;
      request.files.add(await http.MultipartFile.fromPath(
        'slip',
        slipImage!.path,
        filename: fileName,
      ));
    }

    try {
      var response = await request.send();

      // Print status code and response for debugging
      print('Status Code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');

      final jsonResponse = json.decode(responseBody);

      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment successful: ${jsonResponse['message']}')),
        );
      } else if (jsonResponse['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${jsonResponse['message']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response: $responseBody')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }
}
