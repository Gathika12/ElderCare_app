import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserAdditional extends StatefulWidget {
  const UserAdditional({Key? key}) : super(key: key);

  @override
  _UserAdditionalState createState() => _UserAdditionalState();
}

class _UserAdditionalState extends State<UserAdditional> {
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
          Uri.parse('http://10.0.2.2/eldercare/userviewpackagedetails.php'));

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

  // Function to handle "Add" button press
  void addService(int? serviceId) {
    if (serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service ID is null. Cannot add.')),
      );
      return;
    }

    // You can implement the logic for adding the service here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Service $serviceId added successfully!')),
    );
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
                              onPressed: () => addService(
                                  serviceId), // Call addService with serviceId
                              child: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue, // Button color
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
