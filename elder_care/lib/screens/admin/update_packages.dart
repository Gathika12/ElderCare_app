import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPackagePage extends StatefulWidget {
  @override
  _EditPackagePageState createState() => _EditPackagePageState();
}

class _EditPackagePageState extends State<EditPackagePage> {
  final RentApi apiService = RentApi();
  List<String> _packageNames = [];
  Package? _selectedPackage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPackageNames();
  }

  // Fetch all package names
  Future<void> _fetchPackageNames() async {
    final response = await http.get(
      Uri.parse('${apiService.mainurl()}/get_packages.php'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        _packageNames = data.map((e) => e as String).toList();
      });
    }
  }

  // Fetch details for a specific package name
  Future<void> _fetchPackageDetails(String packageName) async {
    final response = await http.get(
      Uri.parse(
          '${apiService.mainurl()}/get_packages.php?package_name=$packageName'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final package = Package.fromJson(data);

      setState(() {
        _selectedPackage = package;
        _updateFormFields(package);
      });
    }
  }

  // Update form fields with package details
  void _updateFormFields(Package package) {
    _packageNameController.text = package.packageName;
    _descriptionController.text = package.description;
    _priceController.text = package.price.toString();
  }

  // Update package details
  Future<void> _updatePackage() async {
    if (_formKey.currentState!.validate() && _selectedPackage != null) {
      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/update_packages.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': _selectedPackage!.id,
          'package_name': _packageNameController.text,
          'description': _descriptionController.text,
          'price': int.parse(_priceController.text),
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Package updated successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update package')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Package')),
      body: _packageNames.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DropdownButton<String>(
                  hint: Text('Select a Package'),
                  value: _selectedPackage?.packageName,
                  items: _packageNames.map((packageName) {
                    return DropdownMenuItem<String>(
                      value: packageName,
                      child: Text(packageName),
                    );
                  }).toList(),
                  onChanged: (String? newPackageName) {
                    if (newPackageName != null) {
                      _fetchPackageDetails(newPackageName);
                    }
                  },
                ),
                if (_selectedPackage != null)
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _packageNameController,
                            decoration:
                                InputDecoration(labelText: 'Package Name'),
                            validator: (value) => value!.isEmpty
                                ? 'This field is required'
                                : null,
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                InputDecoration(labelText: 'Description'),
                            validator: (value) => value!.isEmpty
                                ? 'This field is required'
                                : null,
                          ),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(labelText: 'Price'),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty
                                ? 'This field is required'
                                : null,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updatePackage,
                            child: Text('Update Package'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// Model class for Package
class Package {
  final int id;
  final String packageName;
  final String image;
  final String description;
  final int price;

  Package({
    required this.id,
    required this.packageName,
    required this.image,
    required this.description,
    required this.price,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      packageName: json['package_name'],
      image: json['image'],
      description: json['description'],
      price: json['price'],
    );
  }
}
