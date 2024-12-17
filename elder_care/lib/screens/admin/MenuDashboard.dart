import 'package:elder_care/screens/admin/AlertDialog.dart';
import 'package:flutter/material.dart';
import 'package:elder_care/screens/admin/ServiceProviderControlPage.dart';
import 'package:elder_care/screens/admin/ViewAdditionalService.dart';
import 'package:elder_care/screens/admin/bill.dart';
import 'package:elder_care/screens/admin/user_control.dart';
import 'package:elder_care/screens/login_page.dart'; // Replace with your login page import

import 'all_users.dart';

class MenuDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Dashboard'),
        backgroundColor: const Color(0xFF04C2C2), // Header color
        automaticallyImplyLeading: false, // Removes the backward arrow
        actions: [
          IconButton(
            icon: Icon(Icons.notification_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertDialogInterface(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Image
            ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                width: double.infinity,
                height: 180.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/menu.jpeg'), // Image path
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.0),

            // Page Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 20.0),

            // First Box: User Control
            CustomBox(
                title: 'User Control',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserControlPage()));
                }),

            // Second Box: Service Control
            CustomBox(
                title: 'Service Control',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServiceProviderControlPage()));
                }),

            // Third Box: Payment Control
            CustomBox(
              title: 'Payment Control',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BillTable()));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLogoutDialog(context); // Show the logout confirmation dialog
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }

  // Show Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(context); // Call the logout method
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Logout Logic
  void _logout(BuildContext context) {
    // Clear user session if necessary (not implemented in this example)
    // Navigate to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(
                role: '',
              )), // Replace with your login page
      (Route<dynamic> route) => false, // Remove all routes
    );
  }
}

// Widget for creating rectangular boxes
class CustomBox extends StatelessWidget {
  final String title;
  final VoidCallback onPressed; // Callback for the button

  CustomBox({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Container(
        height: 160.0,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF04C2C2), Color(0xFF03A1A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: onPressed, // Use the passed callback
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF04C2C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                'View More',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for curving the image
class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height - 60.0); // Curve height
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 60.0);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
