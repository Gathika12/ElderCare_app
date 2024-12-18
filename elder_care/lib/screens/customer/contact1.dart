import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HelpContactPage1 extends StatefulWidget {
  final String userId;

  HelpContactPage1({Key? key, required this.userId}) : super(key: key);
  @override
  _HelpContactPage1State createState() => _HelpContactPage1State();
}

class _HelpContactPage1State extends State<HelpContactPage1> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  // Form key to manage form state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Replace with your actual PHP endpoint URL
  final String apiUrl = 'http://10.0.2.2/eldercare/contact.php';

  // Method to send data to the PHP backend
  Future<void> _submitContactForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, String> requestBody = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'comments': _commentsController.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: requestBody,
        );

        if (response.statusCode == 200) {
          // Assuming the backend returns a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form submitted successfully!')),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit form. Try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Method to clear the form fields
  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Color(0xFF044D54),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 54),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return Column(
                          children: [
                            _contactInfo(
                              icon: Icons.location_on,
                              title: 'ADDRESS',
                              details:
                                  'Weather Group Consulting\nBoulder, CO 80301\nNorthern Division Office\nArlington, VA 20598',
                            ),
                            SizedBox(height: 16),
                            _contactInfo(
                              icon: Icons.phone,
                              title: 'PHONE',
                              details:
                                  'Main: 303.527.7667\nEmergency Calls:\n303.527.7667 x101',
                            ),
                            SizedBox(height: 16),
                            _contactInfo(
                              icon: Icons.email,
                              title: 'EMAIL',
                              details:
                                  'Request for Proposal\ninfo@weatherconsulting.com\nEmployment Opportunities\njobs@weatherconsulting.com',
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _contactInfo(
                              icon: Icons.location_on,
                              title: 'ADDRESS',
                              details:
                                  'Weather Group Consulting\nBoulder, CO 80301\nNorthern Division Office\nArlington, VA 20598',
                            ),
                            _contactInfo(
                              icon: Icons.phone,
                              title: 'PHONE',
                              details:
                                  'Main: 303.527.7667\nEmergency Calls:\n303.527.7667 x101',
                            ),
                            _contactInfo(
                              icon: Icons.email,
                              title: 'EMAIL',
                              details:
                                  'Request for Proposal\ninfo@weatherconsulting.com\nEmployment Opportunities\njobs@weatherconsulting.com',
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message Us',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF044D54),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'If you are interested in employment or would like more information about our services, please fill out the form below and we will contact you shortly.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 24),
                  _buildContactForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactInfo(
      {required IconData icon,
      required String title,
      required String details}) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.white),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          details,
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _commentsController,
            label: 'Comments',
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Comments are required';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitContactForm,
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00A79B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator,
    );
  }
}
