import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/merchant/buyers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApproveAdditional extends StatefulWidget {
  final String serviceProviderId;

  const ApproveAdditional({
    Key? key,
    required this.serviceProviderId,
  }) : super(key: key);

  @override
  _ApproveAdditionalState createState() => _ApproveAdditionalState();
}

class _ApproveAdditionalState extends State<ApproveAdditional> {
  final RentApi apiService = RentApi();

  List<dynamic> services = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${apiService.mainurl()}/viewApprovePackage.php?serviceProviderId=${widget.serviceProviderId}'),
      );

      if (response.statusCode == 200) {
        String cleanedResponse = response.body.replaceFirst('Connected', '');
        final jsonResponse = json.decode(cleanedResponse);

        if (jsonResponse is List) {
          setState(() {
            services = jsonResponse;
            isLoading = false;
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
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Services'),
        backgroundColor: const Color(0xFF04C2C2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final serviceId = service['id'] != null
                        ? service['id'].toString()
                        : '0'; // Convert id to string
                    final packageName = service['packageName'] ?? 'No Name';
                    final description =
                        service['description'] ?? 'No Description';
                    final price = service['price'] != null
                        ? service['price'].toString()
                        : '0.00'; // Convert price to string

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(packageName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: $serviceId'),
                            Text(description),
                          ],
                        ),
                        trailing: Text('\$$price'),
                        onTap: () {
                          // Navigate to BuyersPage with packageName
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuyersPage(
                                serviceName: packageName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
