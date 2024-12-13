//import 'package:elder_care/screens/RegisterPage.dart'; // Make sure this path is correct for SignupPage
import 'package:elder_care/screens/customer/RegisterPage.dart';

import 'package:elder_care/screens/login_page.dart'; // Assuming this is the path to your LoginPage.
import 'package:elder_care/screens/merchant/ServiceProviderRegisterPage.dart';
import 'package:flutter/material.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Role'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add the image above the buttons
              Image.asset(
                'assets/images/select.jpg', // Ensure the image path is correct
                height: 250, // Adjust height as needed
                fit: BoxFit.cover, // Adjusts the image to cover the box
              ),
              const SizedBox(height: 100), // Space between image and buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage(role: 'Admin')),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings, size: 40),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(
                        width: 20), // Adjust the width as needed for spacing
                    Text(
                      'Admin',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                      60), // Ensures all buttons are the same height
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ServiceProviderRegisterPage()), // Fixed missing closing parenthesis
                  );
                },
                icon: const Icon(Icons.business_center, size: 40),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(
                        width: 20), // Adjust the width as needed for spacing
                    Text(
                      'Service Provider',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                      60), // Ensures all buttons are the same height
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CustomerSignupPage()), // Fixed missing closing parenthesis
                  );
                },
                icon: const Icon(Icons.person, size: 40),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(
                        width: 20), // Adjust the width as needed for spacing
                    Text(
                      'Member',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                      60), // Ensures all buttons are the same height
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
