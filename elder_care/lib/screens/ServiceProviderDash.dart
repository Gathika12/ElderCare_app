import 'package:flutter/material.dart';

class ServiceProviderDashboard extends StatelessWidget {
  const ServiceProviderDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of button names and corresponding icons
    final List<Map<String, dynamic>> buttons = [
      {'name': 'Payment', 'icon': Icons.payment},
      {'name': 'Dashboard', 'icon': Icons.dashboard},
      {'name': 'Gathika', 'icon': Icons.person},
      {'name': 'Ashen', 'icon': Icons.person},
      {'name': 'Nuwan', 'icon': Icons.person},
      {'name': 'Sachini', 'icon': Icons.person},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/packages1.jpg', // Ensure this path is correct
              fit: BoxFit.cover, // Adjust how the image fits the box
              color: Colors.black
                  .withOpacity(0.3), // Add a slight overlay for readability
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Grid View for Buttons

          Center(
            child: GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two buttons per row
                crossAxisSpacing: 16.0, // Space between columns
                mainAxisSpacing: 16.0, // Space between rows
                childAspectRatio: 1.0, // Square buttons
              ),
              itemCount: buttons.length, // Total buttons based on the list
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Add actions for buttons here if needed
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF04C2C2),
                          Color(0xFF0380A7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(0, 4), // Shadow position
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        // Handle button tap
                      },
                      splashColor: Colors.white24, // Add splash color on press
                      highlightColor: Colors.black12, // Highlight effect
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            buttons[index]['icon'], // Custom icon per button
                            color: Colors.white,
                            size: 40.0,
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            buttons[index]
                                ['name'], // Use button names from the list
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black45,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
