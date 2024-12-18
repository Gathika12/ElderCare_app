import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/PackageBuy.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PackageDetails extends StatefulWidget {
  final String packageName;
  final String userId;

  const PackageDetails({
    Key? key,
    required this.packageName,
    required this.userId,
  }) : super(key: key);

  @override
  _PackageDetailsState createState() => _PackageDetailsState();
}

class _PackageDetailsState extends State<PackageDetails> {
  final RentApi apiService = RentApi();
  Map<String, dynamic>? packageData;
  bool isLoading = true;
  String packageType = 'package';

  @override
  void initState() {
    super.initState();
    _fetchPackageDetails();
  }

  Future<void> _fetchPackageDetails() async {
    try {
      final response = await http.get(Uri.parse(
          '${apiService.mainurl()}/packages.php?package_name=${widget.packageName}'));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final parsedData = json.decode(response.body);
          setState(() {
            packageData = parsedData;
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
            packageData = {'error': 'Failed to parse response data: $e'};
          });
          print('Failed to parse response data: $e');
        }
      } else {
        setState(() {
          isLoading = false;
          packageData = {
            'error':
                'Failed to load package. Status code: ${response.statusCode}'
          };
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        packageData = {'error': 'Network error: $e'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : packageData != null && !packageData!.containsKey('error')
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Back Button and Image Container
                      Stack(
                        children: [
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: (packageData!['image'] != null &&
                                        packageData!['image'] != '0' &&
                                        packageData!['image'].isNotEmpty)
                                    ? NetworkImage(packageData!['image'])
                                    : AssetImage(
                                        widget.packageName.toLowerCase() ==
                                                'silver'
                                            ? 'assets/images/silver.png'
                                            : widget.packageName
                                                        .toLowerCase() ==
                                                    'premium'
                                                ? 'assets/images/pink1.png'
                                                : widget.packageName
                                                            .toLowerCase() ==
                                                        'gold'
                                                    ? 'assets/images/gold1.png'
                                                    : 'assets/images/default.jpg',
                                      ) as ImageProvider<Object>,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            left: 16,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: IconButton(
                                icon:
                                    Icon(Icons.arrow_back, color: Colors.black),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Package Name and Price
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              packageData!['package_name'].toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: widget.packageName.toLowerCase() ==
                                        'silver'
                                    ? Colors.grey
                                    : widget.packageName.toLowerCase() ==
                                            'premium'
                                        ? Colors.pink
                                        : widget.packageName.toLowerCase() ==
                                                'gold'
                                            ? Colors.amber
                                            : Colors
                                                .black87, // Default color if none match
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Price: \$${packageData!['price']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal[700],
                              ),
                            ),
                          ],
                        )),
                      ),
                      SizedBox(height: 2),
                      // Package Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: Text(
                            packageData!['description'] != '0'
                                ? packageData!['description']
                                : 'No description available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Services List
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Included Services",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 12),
                            // Dynamic List of Services with Card
                            _buildServiceItem(
                                "Health Check", packageData!['health_check']),
                            _buildServiceItem("Meal Planning & Nutrition",
                                packageData!['meal_planning']),
                            _buildServiceItem("Social Engagement Activities",
                                packageData!['social_engagement']),
                            _buildServiceItem("Health Monitoring",
                                packageData!['health_monitoring']),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Purchase Package Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PackageBuy(
                                    userId: widget.userId,
                                    packageName: widget.packageName,
                                    packagePrice:
                                        packageData!['price'].toString(),
                                    packageType:
                                        packageType, // Convert the price to a String
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Purchase Package',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(packageData!['error'] ?? 'Error fetching data.'),
                ),
    );
  }

// Enhanced _buildServiceItem with Card UI
  Widget _buildServiceItem(String serviceName, dynamic isAvailable) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 3,
      color: isAvailable == 1 ? Colors.white : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              isAvailable == 1 ? Icons.check_circle : Icons.cancel,
              color: isAvailable == 1 ? Colors.teal : Colors.grey,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                serviceName,
                style: TextStyle(
                  fontSize: 18,
                  color: isAvailable == 1 ? Colors.black87 : Colors.grey,
                  fontWeight:
                      isAvailable == 1 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
