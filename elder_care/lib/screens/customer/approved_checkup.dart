import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ApprovedCheckupsPage extends StatefulWidget {
  final String userId;

  ApprovedCheckupsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ApprovedCheckupsPageState createState() => _ApprovedCheckupsPageState();
}

class _ApprovedCheckupsPageState extends State<ApprovedCheckupsPage> {
  final RentApi apiService = RentApi();
  List<dynamic> _checkups = [];
  bool _isLoading = true;
  String _errorMessage = '';

  late final String apiUrl;

  @override
  void initState() {
    super.initState();
    apiUrl = '${apiService.mainurl()}/approved_checkup.php';
    _fetchApprovedCheckups();
  }

  Future<void> _fetchApprovedCheckups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _checkups = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'No approved checkups found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoading = false;
      });
    }
  }

  void _navigateToDetailsPage(Map<String, dynamic> checkup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckupDetailsPage(checkup: checkup),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Checkups'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _checkups.isEmpty
                  ? Center(child: Text('No approved checkups available.'))
                  : ListView.builder(
                      itemCount: _checkups.length,
                      itemBuilder: (context, index) {
                        final checkup = _checkups[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading:
                                Icon(Icons.check_circle, color: Colors.green),
                            title: Text(
                              'Doctor Remark: ${checkup['doctor_remark']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Location: ${checkup['checkup_location']}'),
                                Text('Date: ${checkup['checkup_date']}'),
                                Text('User Remark: ${checkup['user_remark']}'),
                              ],
                            ),
                            onTap: () {
                              _navigateToDetailsPage(checkup);
                            },
                            trailing: Text(
                              'Approved',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class CheckupDetailsPage extends StatelessWidget {
  final Map<String, dynamic> checkup;

  CheckupDetailsPage({Key? key, required this.checkup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkup Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Remark:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                SizedBox(height: 8),
                Text(
                  checkup['doctor_remark'],
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text(
                  'Checkup Location:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final googleMapsUrl =
                        checkup['checkup_location']; // Use direct link

                    if (await canLaunch(googleMapsUrl)) {
                      await launch(googleMapsUrl,
                          forceWebView: false, forceSafariVC: false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open Google Maps')),
                      );
                    }
                  },
                  child: Text(
                    'Click Here!!!!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  checkup['checkup_location'],
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text(
                  'Checkup Date:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                SizedBox(height: 8),
                Text(
                  checkup['checkup_date'],
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text(
                  'User Remark:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                SizedBox(height: 8),
                Text(
                  checkup['user_remark'],
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
