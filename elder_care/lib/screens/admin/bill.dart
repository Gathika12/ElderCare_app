import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:elder_care/screens/admin/bill_details.dart';
import 'package:elder_care/screens/admin/payment_approve.dart';

class BillTable extends StatefulWidget {
  @override
  _BillTableState createState() => _BillTableState();
}

class _BillTableState extends State<BillTable> {
  final RentApi apiService = RentApi();
  List<dynamic> bills = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response =
          await http.get(Uri.parse('${apiService.mainurl()}/get_bill.php'));

      if (response.statusCode == 200) {
        setState(() {
          bills = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load bills: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error, stackTrace) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _navigateAndRefresh(BuildContext context, Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    // Check if navigation result indicates the need to refresh
    if (result == true) {
      fetchBills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Information'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DataTable(
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        dataTextStyle: TextStyle(
                          color: Colors.black87,
                        ),
                        columnSpacing: 20.0,
                        dataRowHeight: 70.0,
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.teal),
                        columns: [
                          DataColumn(label: Text('Bill ID')),
                          DataColumn(label: Text('Elder ID')),
                          DataColumn(label: Text('Payment Type')),
                          DataColumn(label: Text('Service')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Paid By')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Approval')),
                        ],
                        rows: bills.map((bill) {
                          return DataRow(
                            cells: [
                              DataCell(Text(bill['id'].toString())),
                              DataCell(Text(bill['elder_id'].toString())),
                              DataCell(Text(bill['payment_type'])),
                              DataCell(Text(bill['service'])),
                              DataCell(Text(bill['amount'].toString())),
                              DataCell(Text(bill['paidby'])),
                              DataCell(Text(bill['date'] ?? 'N/A')),
                              DataCell(
                                bill['approval'] == '0'
                                    ? IconButton(
                                        icon: Icon(Icons.add,
                                            color: Colors.blueAccent),
                                        onPressed: () {
                                          _navigateAndRefresh(
                                            context,
                                            ApprovalPage(
                                                elderId: bill['id'].toString()),
                                          );
                                        },
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.visibility,
                                            color: Colors.green),
                                        onPressed: () {
                                          _navigateAndRefresh(
                                            context,
                                            ReceiptPage(
                                              billId: bill['id'].toString(),
                                              elderId:
                                                  bill['elder_id'].toString(),
                                              paymentType: bill['payment_type'],
                                              service: bill['service'],
                                              amount: double.tryParse(
                                                      bill['amount']
                                                          .toString()) ??
                                                  0.0,
                                              paidBy: bill['paidby'],
                                              date: bill['date'] ?? 'N/A',
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}
