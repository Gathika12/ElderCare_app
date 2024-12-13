// ignore_for_file: avoid_print, prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, unused_element

import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class SignupPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _healthIssuesController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _mobileNoController.dispose();
    _healthIssuesController.dispose();
    super.dispose();
  }

  void _submitSignupForm() {
    if (_formKey.currentState!.validate()) {
      // Process the signup form data here
      print("First Name: ${_firstNameController.text}");
      print("Last Name: ${_lastNameController.text}");
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");
      print("Age: ${_ageController.text}");
      print("Gender: $_selectedGender");
      print("Mobile No: ${_mobileNoController.text}");
      print("Blood Group: $_selectedBloodGroup");
      print("Health Issues: ${_healthIssuesController.text}");
    }
  }

  void _goBack() {
    Navigator.pop(context); // Navigate back to the previous screen
  }

  Widget buildTextFieldWithLabel(String label, TextEditingController controller,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text,
      String? placeholder,
      String? Function(String?)? validator}) {
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
              height: 40, // Adjust height for creative appearance
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  fillColor: Colors.white, // Set the background color to white
                  filled: true, // Enable filling with the given color
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 15), // Adjust padding
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Rounded corners for a modern look
                  ),
                  hintText: placeholder, // Placeholder text
                ),
                obscureText: isPassword,
                keyboardType: keyboardType,
                style: TextStyle(fontSize: 16), // Adjust text size
                validator: validator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Signup Page',
          style: TextStyle(fontSize: 35), // Set title font size to 25
        ),
        backgroundColor: Colors.white, // Set AppBar background color
      ),
      body: Container(
        color: Colors.white, // Set the background color
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTextFieldWithLabel(
                    'First Name',
                    _firstNameController,
                    placeholder: 'Enter your first name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  buildTextFieldWithLabel(
                    'Last Name',
                    _lastNameController,
                    placeholder: 'Enter your last name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  buildTextFieldWithLabel(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                    placeholder: 'Enter your email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  buildTextFieldWithLabel(
                    'Password',
                    _passwordController,
                    isPassword: true,
                    placeholder: 'Enter your password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  buildTextFieldWithLabel(
                    'Age',
                    _ageController,
                    keyboardType: TextInputType.number,
                    placeholder: 'Enter your age',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      return null;
                    },
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
                            height:
                                40, // Adjust the height to match the text fields
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                fillColor: Colors.white, // Set to white
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15), // Padding
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
                                ),
                                hintText: 'Select your gender', // Placeholder
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a gender';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildTextFieldWithLabel(
                    'Mobile No',
                    _mobileNoController,
                    keyboardType: TextInputType.phone,
                    placeholder: 'Enter your mobile number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
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
                            height:
                                40, // Adjust the height to match the text fields
                            child: DropdownButtonFormField<String>(
                              value: _selectedBloodGroup,
                              decoration: InputDecoration(
                                fillColor: Colors.white, // Set to white
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15), // Padding
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
                                ),
                                hintText:
                                    'Select your blood group', // Placeholder
                              ),
                              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+']
                                  .map((String bloodGroup) {
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a blood group';
                                }
                                return null;
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
                    placeholder: 'Mention any health issues',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please mention any health issues';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitSignupForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Rounded button
                          ),
                          backgroundColor:
                              Colors.white, // Creative button color
                          elevation: 4 // Add shadow for a 3D effect
                          ),
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
