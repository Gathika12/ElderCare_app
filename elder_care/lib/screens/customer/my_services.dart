import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyServices extends StatefulWidget {
  final String userId;

  MyServices({required this.userId});

  @override
  _MyServicesState createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  final RentApi apiService = RentApi();
  late Future<List<dynamic>> _additionalServices;

  @override
  void initState() {
    super.initState();
    _additionalServices = fetchAdditionalServices();
  }

  Future<List<dynamic>> fetchAdditionalServices() async {
    final apiUrl = Uri.parse(
        '${apiService.mainurl()}/user_additional.php?elder_id=${widget.userId}');

    try {
      print(widget.userId);
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'No services found.');
        }
      } else {
        throw Exception(
            'Failed to load additional services. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Services'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _additionalServices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No additional services found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final services = snapshot.data!;
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['packageName'] ?? 'Unknown Package',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          service['description'] ?? 'No description available',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price: \$${service['price'] ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[700],
                              ),
                            ),
                            Text(
                              'Approval: ${service['approvestatus'] == 1 ? 'Approved' : 'Pending'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: service['approvestatus'] == 1
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
