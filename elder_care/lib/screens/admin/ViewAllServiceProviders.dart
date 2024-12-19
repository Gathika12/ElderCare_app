import 'dart:convert';

import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewAllServiceProviders extends StatefulWidget {
  @override
  _ViewAllServiceProvidersState createState() =>
      _ViewAllServiceProvidersState();
}

class _ViewAllServiceProvidersState extends State<ViewAllServiceProviders> {
  final RentApi apiService = RentApi();
  List<dynamic> serviceProviders = [];

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
  }

  Future<void> fetchServiceProviders() async {
    final response = await http
        .get(Uri.parse('${apiService.mainurl()}/getServiceProviders.php'));

    if (response.statusCode == 200) {
      setState(() {
        serviceProviders = json.decode(response.body).reversed.toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  Future<void> deleteServiceProvider(String id) async {
    final response = await http.post(
      Uri.parse('${apiService.mainurl()}/deleteServiceProvider.php'),
      body: {'id': id},
    );

    if (response.statusCode == 200 &&
        json.decode(response.body)['status'] == 'success') {
      setState(() {
        serviceProviders.removeWhere((provider) => provider['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service provider deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service provider')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Service Providers'),
        backgroundColor: const Color.fromARGB(255, 0, 150, 136),
        elevation: 3,
      ),
      body: serviceProviders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
              // Center the table on the screen
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => const Color.fromARGB(255, 0, 150, 136)
                          .withOpacity(0.1),
                    ),
                    columnSpacing: 16,
                    horizontalMargin: 16,
                    border: TableBorder.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    columns: [
                      DataColumn(label: Text('ID', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Full Name', style: _headerTextStyle())),
                      DataColumn(label: Text('NIC', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Email', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Contact Number',
                              style: _headerTextStyle())),
                      DataColumn(
                          label:
                              Text('Company Name', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Area', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Position', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Category', style: _headerTextStyle())),
                      DataColumn(
                          label: Text('Actions', style: _headerTextStyle())),
                    ],
                    rows: serviceProviders
                        .map<DataRow>(
                          (serviceProvider) => DataRow(
                            cells: [
                              DataCell(Text(serviceProvider['id'].toString(),
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['full_name'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['nic'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['email'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['contact_number'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['company_name'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['area'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['position'],
                                  style: _rowTextStyle())),
                              DataCell(Text(serviceProvider['category'],
                                  style: _rowTextStyle())),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete this service provider?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            deleteServiceProvider(
                                                serviceProvider['id']);
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }

  TextStyle _headerTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: const Color.fromARGB(255, 0, 150, 136),
    );
  }

  TextStyle _rowTextStyle() {
    return TextStyle(
      fontSize: 14,
      color: Colors.black87,
    );
  }
}
