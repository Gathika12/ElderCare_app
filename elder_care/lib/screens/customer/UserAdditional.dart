import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/Additional_buy.dart';
import 'package:elder_care/screens/customer/PackageBuy.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserAdditional extends StatefulWidget {
  final String userId;

  const UserAdditional({Key? key, required this.userId}) : super(key: key);

  @override
  _UserAdditionalState createState() => _UserAdditionalState();
}

class _UserAdditionalState extends State<UserAdditional> {
  final RentApi apiService = RentApi();
  List<dynamic> services = [];
  bool isLoading = true;
  String errorMessage = '';
  String packageType = 'additional';

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final response = await http
          .get(Uri.parse('${apiService.mainurl()}/userviewpackagedetails.php'));

      if (response.statusCode == 200) {
        String cleanedResponse = response.body.replaceFirst('Connected', '');
        final jsonResponse = json.decode(cleanedResponse);

        if (jsonResponse is List) {
          if (mounted) {
            setState(() {
              services = jsonResponse;
              isLoading = false;
            });
          }
        } else {
          throw FormatException('Response is not a valid JSON list.');
        }
      } else {
        throw Exception('Failed to load services: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error: $e';
        });
      }
      print('Error: $e');
    }
  }

  void addService(int? serviceId, String packageName, String packagePrice) {
    if (serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service ID is null. Cannot add.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdditionalBuy(
          serviceId: serviceId,
          userId: widget.userId,
          packageName: packageName,
          packagePrice: packagePrice,
          packageType: packageType,
        ),
      ),
    );
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
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    if (service == null)
                      return SizedBox.shrink(); // Validate service
                    final serviceId = int.tryParse(service['id'] ?? '0') ?? 0;
                    final packageName = service['packageName'] ?? 'No Name';
                    final packagePrice = service['price']?.toString() ?? '0.00';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    packageName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ID: $serviceId',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service['description'] ?? 'No Description',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$$packagePrice',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => addService(
                                    serviceId,
                                    packageName,
                                    packagePrice,
                                  ),
                                  child: const Text('Add'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 8.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
