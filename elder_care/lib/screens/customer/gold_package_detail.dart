import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoldPackageDetail extends StatefulWidget {
  final String packageName;

  const GoldPackageDetail({Key? key, required this.packageName})
      : super(key: key);

  @override
  _GoldPackageDetailState createState() => _GoldPackageDetailState();
}

class _GoldPackageDetailState extends State<GoldPackageDetail> {
  final RentApi apiService = RentApi();
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
          '${apiService.mainurl()}/packages.php?package_name=${widget.packageName}'));

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
          : Padding(
              padding: const EdgeInsets.all(
                  0.0), // Remove padding for full-width image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Package Image
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: (packageData!['image'] != null &&
                                    packageData!['image'] != '0' &&
                                    packageData!['image'].isNotEmpty)
                                ? NetworkImage(packageData!['image'])
                                : AssetImage('assets/images/gold1.png')
                                    as ImageProvider<
                                        Object>, // Local image fallback
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Backward Arrow
                      Positioned(
                        top: 40,
                        left: 16,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Package Name
                  Center(
                    child: Text(
                      packageData!['package_name'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Package Description
                  Center(
                    child: Text(
                      packageData!['description'] != '0'
                          ? packageData!['description']
                          : 'No description available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Package Price
                  Center(
                    child: Text(
                      'Price: \$${packageData!['price']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Purchase Button
                  Center(
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
                            minimumSize:
                                Size(double.infinity, 50), // Full width button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Purchase Package',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
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
