import 'dart:convert';

import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/merchant/ViewproviderAdditional.dart';
import 'package:elder_care/screens/merchant/approveAdditional.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdditionalPackages extends StatefulWidget {
  final String serviceProviderId;
  final String serviceProviderName;

  const AdditionalPackages({
    Key? key,
    required this.serviceProviderId,
    required this.serviceProviderName,
  }) : super(key: key);

  @override
  _AdditionalPackagesState createState() => _AdditionalPackagesState();
}

class _AdditionalPackagesState extends State<AdditionalPackages> {
  final RentApi apiService = RentApi();
  final TextEditingController _payeeNameController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool isSubmitting = false;

  Future<void> _addPackage() async {
    final String payeeName = _payeeNameController.text.trim();
    final String packageName = _packageNameController.text.trim();
    final String description = _descriptionController.text.trim();
    final String price = _priceController.text.trim();

    if (payeeName.isEmpty ||
        packageName.isEmpty ||
        description.isEmpty ||
        price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final Map<String, dynamic> data = {
      'pid': widget.serviceProviderId,
      'Providername': widget.serviceProviderName,
      'payeename': payeeName,
      'packageName': packageName,
      'description': description,
      'price': price,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('${apiService.mainurl()}/insert_package.php'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        _payeeNameController.clear();
        _packageNameController.clear();
        _descriptionController.clear();
        _priceController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add package: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Packages'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service Provider ID (Read-only)
            _buildReadOnlyField(
              label: 'Service Provider ID',
              value: widget.serviceProviderId,
            ),
            const SizedBox(height: 10),

            // Service Provider Name (Read-only)
            _buildReadOnlyField(
              label: 'Service Provider Name',
              value: widget.serviceProviderName,
            ),
            const SizedBox(height: 10),

            // Payee Name
            _buildTextField(
              controller: _payeeNameController,
              label: 'Payee Name',
            ),
            const SizedBox(height: 10),

            // Package Name
            _buildTextField(
              controller: _packageNameController,
              label: 'Package Name',
            ),
            const SizedBox(height: 10),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
            ),
            const SizedBox(height: 10),

            // Price
            _buildTextField(
              controller: _priceController,
              label: 'Price',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Add Package Button
            isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addPackage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Add Package'),
                  ),
            const SizedBox(height: 20),

            // View All Packages Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewproviderAdditional(
                      serviceProviderId: widget.serviceProviderId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 150, 0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('View All Packages'),
            ),
            const SizedBox(height: 10),

            // Approve Packages Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApproveAdditional(
                      serviceProviderId: widget.serviceProviderId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 150, 0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Approve Packages'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }
}
