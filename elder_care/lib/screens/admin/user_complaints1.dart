import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserComplaints extends StatefulWidget {
  @override
  _UserComplaintsState createState() => _UserComplaintsState();
}

class _UserComplaintsState extends State<UserComplaints> {
  final RentApi apiService = RentApi();
  List<dynamic> complaints = [];
  List<dynamic> filteredComplaints = [];
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
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('${apiService.mainurl()}/get_complaints.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          complaints = data;
          filteredComplaints = complaints; // Initially show all complaints
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load complaints: ${response.statusCode}';
          isLoading = false;
          print(response.body);
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredComplaints = complaints.where((complaint) {
        final fullName = '${complaint['first_name']} ${complaint['last_name']}'
            .toLowerCase();
        final id = complaint['id'].toString();

        return fullName.contains(searchFilter.toLowerCase()) ||
            id.contains(searchFilter);
      }).toList();
    });
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;

      filteredComplaints.sort((a, b) {
        if (columnIndex == 0) {
          return ascending
              ? a['id'].compareTo(b['id'])
              : b['id'].compareTo(a['id']);
        } else if (columnIndex == 1) {
          return ascending
              ? '${a['first_name']} ${a['last_name']}'
                  .compareTo('${b['first_name']} ${b['last_name']}')
              : '${b['first_name']} ${b['last_name']}'
                  .compareTo('${a['first_name']} ${a['last_name']}');
        } else if (columnIndex == 2) {
          return ascending
              ? a['email'].compareTo(b['email'])
              : b['email'].compareTo(a['email']);
        } else if (columnIndex == 3) {
          return ascending
              ? a['comments'].compareTo(b['comments'])
              : b['comments'].compareTo(a['comments']);
        }
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Complaints'),
        backgroundColor: Colors.teal,
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
                          labelText: 'Search by Name, ID or Comments',
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
                              DataColumn(
                                label: Text('Comments'),
                                onSort: (index, ascending) =>
                                    onSort(index, ascending),
                              ),
                            ],
                            rows: filteredComplaints.map((complaint) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(complaint['id'].toString())),
                                  DataCell(Text(
                                      '${complaint['first_name']} ${complaint['last_name']}')),
                                  DataCell(Text(complaint['email'] ?? 'N/A')),
                                  DataCell(
                                      Text(complaint['comments'] ?? 'N/A')),
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
