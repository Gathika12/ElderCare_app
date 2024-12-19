import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceProviderRegisterPage extends StatefulWidget {
  @override
  _ServiceProviderRegisterPageState createState() =>
      _ServiceProviderRegisterPageState();
}

class _ServiceProviderRegisterPageState
    extends State<ServiceProviderRegisterPage> {
  final RentApi apiService = RentApi();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final List<String> _categories = ['Doctor', 'Service Provider'];
  final List<String> _areaSuggestions = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya'
  ];

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _areaNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerServiceProvider() async {
    final String apiUrl = '${apiService.mainurl()}/serviceprovider.php';

    final Map<String, dynamic> data = {
      'full_name': _fullNameController.text,
      'nic': _nicController.text,
      'email': _emailController.text,
      'contact_number': _contactNumberController.text,
      'company_name': _companyNameController.text,
      'area': _areaNameController.text,
      'position': _positionController.text,
      'category': _selectedCategory,
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service Provider registered successfully')),
        );
        Navigator.pop(context, true);

        _fullNameController.clear();
        _nicController.clear();
        _emailController.clear();
        _contactNumberController.clear();
        _companyNameController.clear();
        _positionController.clear();
        _passwordController.clear();
        setState(() {
          _selectedCategory = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register. Please try again.')),
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
        title: const Text('Service Provider Registration'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildValidatedTextField(
                controller: _fullNameController,
                label: 'Full Name',
                placeholder: 'Enter your full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full Name is required';
                  }
                  return null;
                },
              ),
              _buildValidatedTextField(
                controller: _nicController,
                label: 'NIC',
                placeholder: 'Enter your NIC',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIC is required';
                  }
                  return null;
                },
              ),
              _buildValidatedTextField(
                controller: _emailController,
                label: 'Email',
                placeholder: 'Enter your email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              _buildValidatedTextField(
                controller: _contactNumberController,
                label: 'Contact Number',
                placeholder: 'Enter your contact number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact Number is required';
                  }
                  return null;
                },
              ),
              _buildValidatedTextField(
                controller: _companyNameController,
                label: 'Company Name',
                placeholder: 'Enter your company name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Company Name is required';
                  }
                  return null;
                },
              ),
              _buildAreaAutocompleteField(),
              _buildValidatedTextField(
                controller: _positionController,
                label: 'Position',
                placeholder: 'Enter your position',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Position is required';
                  }
                  return null;
                },
              ),
              _buildValidatedTextField(
                controller: _passwordController,
                label: 'Password',
                placeholder: 'Enter your password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerServiceProvider();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all fields correctly')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Providing Area',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _areaSuggestions.where((String area) {
              return area
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _areaNameController.text = selection;
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            _areaNameController.addListener(() {
              textEditingController.text = _areaNameController.text;
            });
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your Service Providing Area',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Service Providing Area is required';
                }
                return null;
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: placeholder,
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
