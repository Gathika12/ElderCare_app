import 'dart:convert';

import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/admin/view_approved_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewAdditionalService extends StatefulWidget {
  const ViewAdditionalService({Key? key}) : super(key: key);

  @override
  _ViewAdditionalServiceState createState() => _ViewAdditionalServiceState();
}

class _ViewAdditionalServiceState extends State<ViewAdditionalService> {
  final RentApi apiService = RentApi();
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
      final response = await http.get(
          Uri.parse('${apiService.mainurl()}/view_notapprove_additional.php'));

      if (response.statusCode == 200) {
        // Clean the response by removing the invalid "Connected" text
        String cleanedResponse = response.body.replaceFirst('Connected', '');

        print(
            'Cleaned Response body: $cleanedResponse'); // Log the cleaned response

        final jsonResponse =
            json.decode(cleanedResponse); // Decode cleaned response

        if (jsonResponse is List) {
          setState(() {
            services = jsonResponse.reversed.toList(); // Reverse the list
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

  // Function to handle "Approve" button press and send POST request
  Future<void> approveService(int? serviceId, int index) async {
    if (serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service ID is null. Cannot approve.')),
      );
      return;
    }

    try {
      // Define the URL of your PHP API
      final url = Uri.parse('${apiService.mainurl()}/updateApprovalStatus.php');

      // Create the body of the POST request with approvestatus as a string
      final body = {
        'serviceId': serviceId.toString(), // Ensure serviceId is a string
        'approvestatus': '1', // approvestatus is sent as a string
      };

      // Send the POST request
      final response = await http.post(
        url,
        body: body,
      );

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );

        // Remove the approved service from the list and update the state
        setState(() {
          services.removeAt(index); // Remove the item at the given index
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'])),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Services'),
        backgroundColor: const Color(0xFF04C2C2), // Header color
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewApprovedService(), // Replace with your actual widget
                ),
              );
            },
            child: const Text(
              'Approved Services',
              style: TextStyle(
                color: Colors.white, // Text color
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Show error message if any
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];

                    // Ensure serviceId is parsed as an integer
                    final serviceId = int.tryParse(service['id'] ??
                        '0'); // Parse serviceId to int, with a fallback

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
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                '\$${service['price']?.toString() ?? '0.00'}'), // Fallback if price is null
                            const SizedBox(
                                width: 8.0), // Space between price and button
                            ElevatedButton(
                              onPressed: () => approveService(
                                  serviceId, index), // Pass serviceId and index
                              child: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green, // Text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
