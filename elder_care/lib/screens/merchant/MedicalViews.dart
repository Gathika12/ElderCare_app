import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:elder_care/screens/merchant/ApproveMedicals.dart';

class MedicalViews extends StatefulWidget {
  final String serviceProviderId;

  MedicalViews({
    required this.serviceProviderId,
  });

  @override
  _MedicalViewsState createState() => _MedicalViewsState();
}

class _MedicalViewsState extends State<MedicalViews> {
  final RentApi apiService = RentApi();
  late Future<List<dynamic>> _medicalData;

  // API URL
  late final String apiUrl;

  @override
  void initState() {
    super.initState();
    apiUrl = Uri.parse(
            '${apiService.mainurl()}/ViewMedicals.php?doctor_id=${widget.serviceProviderId}')
        .toString();
    _fetchMedicalData();
  }

  // Fetch data from the API
  Future<List<dynamic>> fetchMedicalData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        debugPrint("Raw Response: ${response.body}");
        String cleanedResponse = response.body;

        if (cleanedResponse.contains('[')) {
          cleanedResponse =
              cleanedResponse.substring(cleanedResponse.indexOf('['));
        }

        return jsonDecode(cleanedResponse);
      } else {
        debugPrint(
            "Failed to load medical data. Status code: ${response.statusCode}");
        throw Exception("Failed to load medical data");
      }
    } catch (e) {
      debugPrint("Error occurred: $e");
      throw Exception("Error: $e");
    }
  }

  void _fetchMedicalData() {
    setState(() {
      _medicalData = fetchMedicalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Details"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _medicalData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint("Snapshot error: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No medical data available"));
          } else {
            final medicalData = snapshot.data!;
            return ListView.builder(
              itemCount: medicalData.length,
              itemBuilder: (context, index) {
                final item = medicalData[index];
                final fullName = item['full_name'] ?? 'N/A';

                return Card(
                  elevation: 6,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.teal),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Name: $fullName",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.comment, color: Colors.teal),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "User's Remark: ${item['user_remark'] ?? 'N/A'}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.teal),
                            SizedBox(width: 8),
                            Text(
                              "Approval Status: ${item['approval'] == 1 ? 'Approved' : 'Pending'}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ApproveMedicals(medicalData: item),
                                ),
                              );

                              if (result == true) {
                                // Refresh data after approving
                                _fetchMedicalData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                            child: Text(
                              "Approve",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
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
