import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'SendNotificationPage.dart';

class UsersTable extends StatefulWidget {
  @override
  _UsersTableState createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  final RentApi apiService = RentApi();
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String? errorMessage;

  // Sorting state
  bool sortAscending = true;
  int sortColumnIndex = 0;

  // Search filter
  String searchFilter = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response =
          await http.get(Uri.parse('${apiService.mainurl()}/all_users.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data;
          filteredUsers = users; // Initially show all users
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load users: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        print('error:${error}');
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        final fullName = user['full_name'].toString().toLowerCase();
        final id = user['id'].toString();

        return fullName.contains(searchFilter.toLowerCase()) ||
            id.contains(searchFilter);
      }).toList();
    });
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;

      filteredUsers.sort((a, b) {
        if (columnIndex == 0) {
          return ascending
              ? a['id'].compareTo(b['id'])
              : b['id'].compareTo(a['id']);
        } else if (columnIndex == 1) {
          return ascending
              ? a['full_name'].compareTo(b['full_name'])
              : b['full_name'].compareTo(a['full_name']);
        } else if (columnIndex == 2) {
          return ascending
              ? a['email'].compareTo(b['email'])
              : b['email'].compareTo(a['email']);
        }
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Table'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to the notification page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SendNotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search by Name or ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search, color: Colors.teal),
                        ),
                        onChanged: (value) {
                          searchFilter = value;
                          applyFilters();
                        },
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortColumnIndex: sortColumnIndex,
                            sortAscending: sortAscending,
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey,
                            ),
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            columns: [
                              DataColumn(
                                label: Text('ID'),
                                numeric: true,
                                onSort: (index, ascending) =>
                                    onSort(index, ascending),
                              ),
                              DataColumn(
                                label: Text('Name'),
                                onSort: (index, ascending) =>
                                    onSort(index, ascending),
                              ),
                              DataColumn(
                                label: Text('Email'),
                                onSort: (index, ascending) =>
                                    onSort(index, ascending),
                              ),
                              DataColumn(label: Text('City')),
                              DataColumn(label: Text('Mobile No')),
                            ],
                            rows: filteredUsers.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(user['id'].toString())),
                                  DataCell(Text(user['full_name'] ?? 'N/A')),
                                  DataCell(Text(user['email'] ?? 'N/A')),
                                  DataCell(Text(user['city'] ?? 'N/A')),
                                  DataCell(Text(user['mobile_no'] ?? 'N/A')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
