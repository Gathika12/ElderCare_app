import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDataPage extends StatefulWidget {
  final String userId;

  UserDataPage({required this.userId});

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final RentApi apiService = RentApi();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse(
          '${apiService.mainurl()}/get_user_data.php?userId=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body)['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User ID: ${userData!['id']}'),
                      SizedBox(height: 8),
                      Text('Name: ${userData!['full_name']}'),
                      SizedBox(height: 8),
                      Text('Email: ${userData!['nic']}'),
                      SizedBox(height: 8),
                      Text('Phone: ${userData!['birthday']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['email']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['age']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['gender']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['city']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['mobile_no']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['blood_group']}'),
                      SizedBox(height: 8),
                      Text('Address: ${userData!['health_issues']}'),
                      // Add more fields as necessary
                    ],
                  ),
                )
              : Center(
                  child: Text('No user data found'),
                ),
    );
  }
}
