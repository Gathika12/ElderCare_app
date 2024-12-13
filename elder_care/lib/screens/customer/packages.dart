import 'package:flutter/material.dart';
import 'package_details.dart';
import 'premium_package_detail.dart';
import 'gold_package_detail.dart';

class Package extends StatefulWidget {
  final String userId;

  Package({Key? key, required this.userId}) : super(key: key);

  @override
  State<Package> createState() => _PackageState();
}

class _PackageState extends State<Package> {
  final Map<String, Map<String, String>> packageDetails = {
    'Silver': {'title': '24/7 Service', 'description': 'Anywhere'},
    'Premium': {
      'title': 'Priority Support',
      'description': 'Faster service and exclusive offers'
    },
    'Gold': {
      'title': 'VIP Support',
      'description': 'Exclusive services, faster response times'
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ribbons (Top section with 1 image)
                _ribbonItem('assets/images/packages.png'),
                const SizedBox(height: 16),
                // Packages Title
                Text(
                  "Explore Our Packages",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800], // Title color
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Recommendations tailored for you",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Packages Section with Silver, Premium, and Gold
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: packageDetails.keys.length,
                  itemBuilder: (context, index) {
                    String packageName = packageDetails.keys.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the respective package detail page
                        switch (packageName) {
                          case 'Silver':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PackageDetails(
                                        packageName: packageName,
                                        userId: widget.userId,
                                      )),
                            );
                            break;
                          case 'Premium':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PackageDetails(
                                        packageName: packageName,
                                        userId: widget.userId,
                                      )),
                            );
                            break;
                          case 'Gold':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PackageDetails(
                                        packageName: packageName,
                                        userId: widget.userId,
                                      )),
                            );
                            break;
                        }
                      },
                      child: _packageCard(
                        packageName,
                        Icons.check_circle_outline,
                        _getPackageColor(packageName),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to return color based on package type
  Color _getPackageColor(String packageName) {
    switch (packageName) {
      case 'Silver':
        return Colors.blueGrey;
      case 'Premium':
        return const Color.fromARGB(255, 128, 0, 255);
      case 'Gold':
        return const Color.fromARGB(255, 255, 174, 0);
      default:
        return Colors.grey;
    }
  }

  // Widget for package cards
  Widget _packageCard(String title, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5, // Add elevation for shadow effect
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    packageDetails[title]!['description']!,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Widget for ribbon images at the top
  Widget _ribbonItem(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity, // Full width of the container
      height: 200, // Adjust the height according to the image aspect ratio
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Rounded corners
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover, // Adjust the fit as needed (cover or contain)
        ),
      ),
    );
  }
}
