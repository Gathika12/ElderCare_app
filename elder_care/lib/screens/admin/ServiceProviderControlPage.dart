import 'package:elder_care/screens/admin/ViewAdditionalService.dart';
import 'package:flutter/material.dart';

class ServiceProviderControlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Control'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First card with icon and onTap functionality
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Handle onTap action for the first card
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewServiceProviderPage()),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.people,
                          size: 100, // Adjust size as needed
                          color: Colors.teal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'New Service Providers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0), // Space between the two cards
            // Second card with icon and onTap functionality
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Handle onTap action for the second card
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAdditionalService()),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.medical_services,
                          size: 100, // Adjust size as needed
                          color: Colors.teal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Additional Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy pages for navigation
class NewServiceProviderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Service Providers'),
      ),
      body: Center(
        child: Text('Details for New Service Providers'),
      ),
    );
  }
}

class AdditionalServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Services'),
      ),
      body: Center(
        child: Text('Details for Additional Services'),
      ),
    );
  }
}
