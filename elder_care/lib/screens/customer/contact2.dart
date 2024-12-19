import 'package:flutter/material.dart';

class HelpContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the backward arrow
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(label: 'First Name'),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTextField(label: 'Last Name'),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildTextField(label: 'Email'),
        SizedBox(height: 16),
        _buildTextField(label: 'Comments', maxLines: 4),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00A79B),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
