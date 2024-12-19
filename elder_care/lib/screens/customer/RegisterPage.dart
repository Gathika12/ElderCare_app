import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class CustomerSignupPage extends StatefulWidget {
  @override
  _CustomerSignupPageState createState() => _CustomerSignupPageState();
}

class _CustomerSignupPageState extends State<CustomerSignupPage> {
  final RentApi apiService = RentApi();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final MaskedTextController _nicController = MaskedTextController(
      mask: '00000000000V'); // Example for NICs ending with 'V'

  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _healthIssuesController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final List<String> _citySuggestions = [
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

  String? _selectedGender;
  String? _selectedBloodGroup;

  Widget buildCityAutocompleteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'City',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 40,
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _citySuggestions.where((String city) {
                    return city
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _cityController.text = selection; // Save selected city
                  print('Selected City: $selection'); // Debug output
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Enter your city',
                    ),
                    onChanged: (value) {
                      _cityController.text = value; // Update text controller
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _nicController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _mobileNoController.dispose();
    _healthIssuesController.dispose();
    super.dispose();
  }

  void _submitSignupForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'full_name': _firstNameController.text,
        'nic': _nicController.text.trim(),
        'birthday': _birthdayController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'mobile_no': _mobileNoController.text,
        'blood_group': _selectedBloodGroup,
        'health_issues': _healthIssuesController.text,
        'city': _cityController.text, // Include city in the API data
      };

      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/register.php'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        print('Failed to signup: ${response.statusCode}');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Signup Successful'),
          content: Text('You have signed up successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/user-login');
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _goBack() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(
                role: '',
              )),
    );
  }

  Widget buildTextFieldWithLabel(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? placeholder,
    Function()? onTap,
    String? Function(String?)? validator, // Add validator parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 40,
              child: GestureDetector(
                onTap: onTap,
                child: AbsorbPointer(
                  absorbing: onTap != null,
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: placeholder,
                    ),
                    obscureText: isPassword,
                    keyboardType: keyboardType,
                    style: TextStyle(fontSize: 16),
                    validator: validator, // Use the validator parameter
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Signup Page', style: TextStyle(fontSize: 35)),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTextFieldWithLabel(
                    'Full Name',
                    _firstNameController,
                    placeholder: 'Enter your full name',
                  ),
                  buildTextFieldWithLabel(
                    'NIC',
                    _nicController,
                    placeholder: 'Enter your NIC',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NIC is required';
                      }
                      if (value.length != 12) {
                        return 'NIC must be 12 characters';
                      }
                      // Add regex validation for specific NIC formats if needed
                      return null;
                    },
                  ),
                  buildTextFieldWithLabel(
                    'Birthday',
                    _birthdayController,
                    placeholder: 'Enter your birthday',
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        // Format date as YYYY-MM-DD
                        String formattedDate =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        _birthdayController.text = formattedDate;
                      }
                    },
                    keyboardType: TextInputType.datetime,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 40,
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: 'Enter your email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    final emailRegex =
                                        RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Password',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 40,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: 'Enter your password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Re-enter Password',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 40,
                                child: TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    hintText: 'Re-enter your password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Re-enter password is required';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  buildTextFieldWithLabel(
                    'Age',
                    _ageController,
                    keyboardType: TextInputType.number,
                    placeholder: 'Enter your age',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Gender',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 40,
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Select your gender',
                              ),
                              items: ['Male', 'Female', 'Other']
                                  .map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildCityAutocompleteField(),
                  buildTextFieldWithLabel(
                    'Mobile No',
                    _mobileNoController,
                    keyboardType: TextInputType.phone,
                    placeholder: 'Enter your mobile number',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Blood Group',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 40,
                            child: DropdownButtonFormField<String>(
                              value: _selectedBloodGroup,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Select your blood group',
                              ),
                              items: [
                                'A+',
                                'A-',
                                'B+',
                                'B-',
                                'O+',
                                'O-',
                                'AB+',
                                'AB-'
                              ].map((String bloodGroup) {
                                return DropdownMenuItem<String>(
                                  value: bloodGroup,
                                  child: Text(bloodGroup),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBloodGroup = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildTextFieldWithLabel(
                    'Health Issues',
                    _healthIssuesController,
                    placeholder: 'Enter your health issues (if any)',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _submitSignupForm,
                        child: Text('Sign Up',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.teal),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _goBack,
                    child: Text(
                      'Already have an account? Login here',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
