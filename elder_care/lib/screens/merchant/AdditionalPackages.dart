import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdditionalPackages extends StatefulWidget {
  final String serviceProviderId; // Added to accept serviceProviderId directly
  final String serviceProviderName; // Optionally added if needed

  const AdditionalPackages({
    Key? key,
    required this.serviceProviderId,
    required this.serviceProviderName, // Optional parameter
  }) : super(key: key);

  @override
  _AdditionalPackagesState createState() => _AdditionalPackagesState();
}

class _AdditionalPackagesState extends State<AdditionalPackages> {
  final TextEditingController _serviceProviderIdController =
      TextEditingController();
  final TextEditingController _serviceProviderNameController =
      TextEditingController();
  final TextEditingController _payeeNameController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<Map<String, dynamic>> packages = [];

  @override
  void initState() {
    super.initState();
    _initializeServiceProviderDetails();
  }

  void _initializeServiceProviderDetails() {
    // Set the passed values to controllers or variables
    _serviceProviderIdController.text = widget.serviceProviderId;
    _serviceProviderNameController.text = widget.serviceProviderName;
  }

  Future<void> _addPackage() async {
    final String payeeName = _payeeNameController.text;
    final String packageName = _packageNameController.text;
    final String description = _descriptionController.text;
    final String price = _priceController.text;

    if (widget.serviceProviderId.isEmpty ||
        payeeName.isEmpty ||
        packageName.isEmpty ||
        description.isEmpty ||
        price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'serviceProviderId': widget.serviceProviderId,
      'serviceProviderName': widget.serviceProviderName,
      'payeeName': payeeName,
      'packageName': packageName,
      'description': description,
      'price': price,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('http://10.0.2.2/eldercare/insert_package.php'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Package added successfully!')),
        );
        _payeeNameController.clear();
        _packageNameController.clear();
        _descriptionController.clear();
        _priceController.clear();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Packages'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _serviceProviderIdController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Service Provider ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _serviceProviderNameController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Service Provider Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _payeeNameController,
              decoration: InputDecoration(
                labelText: 'Payee Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _packageNameController,
              decoration: InputDecoration(
                labelText: 'Package Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPackage,
              child: Text('Add Package'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            SizedBox(height: 20),
            Text(
              'Added Packages:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return PackageCard(packageData: packages[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  final Map<String, dynamic> packageData;

  const PackageCard({
    Key? key,
    required this.packageData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Provider ID: ${packageData['serviceProviderId']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Service Provider Name: ${packageData['serviceProviderName']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Payee Name: ${packageData['payeeName']}'),
            Text('Package Name: ${packageData['packageName']}'),
            Text('Description: ${packageData['description']}'),
            Text('Price: ${packageData['price']}'),
          ],
        ),
      ),
    );
  }
}
