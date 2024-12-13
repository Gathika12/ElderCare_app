import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PremiumPackageDetail extends StatefulWidget {
  final String packageName;

  const PremiumPackageDetail({Key? key, required this.packageName})
      : super(key: key);

  @override
  _PremiumPackageDetailState createState() => _PremiumPackageDetailState();
}

class _PremiumPackageDetailState extends State<PremiumPackageDetail> {
  Map<String, dynamic>? packageData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackageDetails();
  }

  Future<void> _fetchPackageDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2/eldercare/packages.php?package_name=${widget.packageName}'));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Print the raw response body

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
              ? Column(
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
                                  : AssetImage('assets/images/pink1.png')
                                      as ImageProvider<
                                          Object>, // Local image path with cast
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
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Package Name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          packageData!['package_name'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Package Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: Text(
                          'Price: \$${packageData!['price']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    // Purchase Package Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Container(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle purchase logic here
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Package purchased successfully!"),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(
                                  double.infinity, 50), // Full width button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Purchase Package',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(packageData!['error'] ?? 'Error fetching data.'),
                ),
    );
  }
}
