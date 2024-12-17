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

        setState(() {
          if (data is List<dynamic>) {
            billDetails = data.isNotEmpty ? data[0] : null;
          } else if (data is Map<String, dynamic>) {
            billDetails = data;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch bill details')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment approved successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseBody['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve payment')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
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
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Bill Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Divider(),
                            _buildDetailRow(
                                label: 'Elder ID',
                                value: billDetails!['elder_id']),
                            _buildDetailRow(
                                label: 'Payment Type',
                                value: billDetails!['payment_type']),
                            _buildDetailRow(
                                label: 'Service',
                                value: billDetails!['service']),
                            _buildDetailRow(
                                label: 'Amount',
                                value: '\$${billDetails!['amount']}'),
                            _buildDetailRow(
                                label: 'Paid By',
                                value: billDetails!['paidby']),
                            _buildDetailRow(
                                label: 'Date', value: billDetails!['date']),
                            SizedBox(height: 30),
                            isApproving
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton.icon(
                                    onPressed: approvePayment,
                                    icon: Icon(Icons.check_circle_outline),
                                    label: Text('Approve Payment'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailRow({required String label, required dynamic value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.teal[700],
            ),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
