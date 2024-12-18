import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BuyersPage extends StatefulWidget {
  final String serviceName;

  BuyersPage({required this.serviceName});

  @override
  _BuyersPageState createState() => _BuyersPageState();
}

class _BuyersPageState extends State<BuyersPage> {
  final RentApi apiService = RentApi();
  late Future<List<dynamic>> _buyers;

  @override
  void initState() {
    super.initState();
    _buyers = fetchBuyers();
  }

  Future<List<dynamic>> fetchBuyers() async {
    final apiUrl = Uri.parse(
        '${apiService.mainurl()}/additional_buyers.php?service=${widget.serviceName}');

    try {
      // Log the API call URL
      print('Fetching buyers from API: $apiUrl');

      final response = await http.get(apiUrl);

      // Log the HTTP status code
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Log the response body for debugging
        print('Response body: ${response.body}');

        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          if (data['data'] == null) {
            return []; // Return an empty list if no data
          } else if (data['data'] is List) {
            // Reverse the list for Last Come, First Out
            return data['data'].reversed.toList();
          } else if (data['data'] is Map) {
            return [data['data']]; // Wrap single object in a list
          } else {
            throw Exception('Unexpected data format in API response.');
          }
        } else {
          print('API Error: ${data['message']}');
          throw Exception(data['message'] ?? 'No buyers found.');
        }
      } else {
        print(
            'HTTP Error: Failed to load buyers. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to load buyers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Network/Unexpected Error: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyers of ${widget.serviceName}'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _buyers,
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
                'No buyers found for this service.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final buyers = snapshot.data!;
            return ListView.builder(
              itemCount: buyers.length,
              itemBuilder: (context, index) {
                final buyer = buyers[index];
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
                          buyer['full_name'] ?? 'Unknown Buyer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: ${buyer['email'] ?? 'N/A'}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mobile: ${buyer['mobile_no'] ?? 'N/A'}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'City: ${buyer['city'] ?? 'N/A'}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 8),
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
