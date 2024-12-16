import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApprovalPage extends StatefulWidget {
  final String elderId;

  ApprovalPage({required this.elderId});

  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final RentApi apiService = RentApi();
  Map<String, dynamic>? billDetails;
  bool isLoading = true;
  bool isApproving = false;

  @override
  void initState() {
    super.initState();
    fetchBillDetails();
  }

  Future<void> fetchBillDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${apiService.mainurl()}/approve_payment.php?id=${widget.elderId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic>) {
          setState(() {
            billDetails = data.isNotEmpty ? data[0] : null;
            isLoading = false;
          });
        } else if (data is Map<String, dynamic>) {
          setState(() {
            billDetails = data;
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        final errorMessage =
            'Failed to fetch bill details: ${response.statusCode}';
        print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching bill details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bill details: $error')),
      );
    }
  }

  Future<void> approvePayment() async {
    setState(() {
      isApproving = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/approve_payment.php'),
        body: {'id': widget.elderId},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          print('Payment approved successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment approved successfully!')),
          );

          // Navigate back with result to indicate success
          Navigator.pop(context, true);
        } else {
          final errorMessage =
              'Failed to approve payment: ${responseBody['message']}';
          print(errorMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        final errorMessage =
            'Failed to approve payment: ${response.statusCode}';
        print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      print('Error approving payment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving payment: $error')),
      );
    } finally {
      setState(() {
        isApproving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approve Payment'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : billDetails == null
              ? Center(child: Text('No bill details found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.teal, size: 30),
                              SizedBox(width: 10),
                              Text(
                                'Elder ID: ${billDetails!['elder_id']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildDetailRow(
                            label: 'Payment Type',
                            value: billDetails!['payment_type'],
                          ),
                          _buildDetailRow(
                            label: 'Service',
                            value: billDetails!['service'],
                          ),
                          _buildDetailRow(
                            label: 'Amount',
                            value: '\$${billDetails!['amount']}',
                          ),
                          _buildDetailRow(
                            label: 'Paid By',
                            value: billDetails!['paidby'],
                          ),
                          _buildDetailRow(
                            label: 'Date',
                            value: billDetails!['date'],
                          ),
                          SizedBox(height: 30),
                          isApproving
                              ? Center(child: CircularProgressIndicator())
                              : ElevatedButton.icon(
                                  onPressed: approvePayment,
                                  icon: Icon(Icons.check),
                                  label: Text('Approve Payment'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
