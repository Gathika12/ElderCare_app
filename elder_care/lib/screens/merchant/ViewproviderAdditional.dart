import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewproviderAdditional extends StatefulWidget {
  const ViewproviderAdditional({Key? key}) : super(key: key);

  @override
  _ViewproviderAdditionalState createState() => _ViewproviderAdditionalState();
}

class _ViewproviderAdditionalState extends State<ViewproviderAdditional> {
  List<dynamic> services = []; // To hold the fetched services
  bool isLoading = true; // To track loading state
  String errorMessage = ''; // To display error messages

  @override
  void initState() {
    super.initState();
    fetchServices(); // Fetch services when the widget is initialized
  }

  Future<void> fetchServices() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/eldercare/viewpackagedetails.php'));

      if (response.statusCode == 200) {
        // Clean the response by removing the invalid "Connected" text
        String cleanedResponse = response.body.replaceFirst('Connected', '');

        print(
            'Cleaned Response body: $cleanedResponse'); // Log the cleaned response

        final jsonResponse =
            json.decode(cleanedResponse); // Decode cleaned response

        if (jsonResponse is List) {
          setState(() {
            services = jsonResponse; // Update the state with the services
            isLoading = false; // Data loaded, stop loading indicator
          });
        } else {
          throw FormatException('Response is not a valid JSON list.');
        }
      } else {
        throw Exception('Failed to load services: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e'; // Set error message
      });
      print('Error: $e'); // Log the error
    }
  }

  Future<void> approveService(int serviceId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/eldercare/approve_service.php'),
        body: {
          'id': serviceId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] != null) {
          // Fetch services again to update the UI
          fetchServices();
        } else {
          setState(() {
            errorMessage = jsonResponse['error'] ?? 'Error approving service.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to approve service: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e'; // Set error message
      });
      print('Error: $e'); // Log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Services'),
        backgroundColor: const Color(0xFF04C2C2), // Header color
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Show error message if any
              : SingleChildScrollView(
                  // Wrap with SingleChildScrollView
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Allow ListView to shrink to its content size
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];

                      // Ensure serviceId is parsed as an integer
                      final serviceId = int.tryParse(service['id'] ??
                          '0'); // Parse serviceId to int, with a fallback

                      // Check if the service is approved
                      final isApproved = service['approvestatus'] ==
                          1; // Assuming 'approvestatus' is returned in the response

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(service['packageName'] ??
                              'No Name'), // Fallback if packageName is missing
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'ID: ${serviceId.toString()}'), // Show service ID
                              Text(service['description'] ??
                                  'No Description'), // Fallback if description is missing
                              // Show success message if approved
                              if (service['approveMessage'] != null &&
                                  service['approveMessage'] != '')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    service[
                                        'approveMessage'], // Display the message from the API response
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                              '\$${service['price']?.toString() ?? '0.00'}'), // Fallback if price is null
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
