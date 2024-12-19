import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/approved_checkup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NearestDoctorsPage extends StatefulWidget {
  final String userId;

  NearestDoctorsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NearestDoctorsPageState createState() => _NearestDoctorsPageState();
}

class _NearestDoctorsPageState extends State<NearestDoctorsPage> {
  final RentApi apiService = RentApi();
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];
  List<String> _districts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Vavuniya',
    'Mullaitivu',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Monaragala',
    'Ratnapura',
    'Kegalle'
  ];
  String _searchQuery = '';
  bool _isLoading = true;
  String _errorMessage = '';

  final String apiUrl = 'http://192.168.1.4/eldercare/get_doctor.php';
  final String saveCheckupApi = 'http://192.168.1.4/eldercare/user_checkup.php';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final String apiUrl = '${apiService.mainurl()}/get_doctor.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List) {
          setState(() {
            _doctors = responseData.map((doctor) {
              return {
                'id': doctor['id'],
                'full_name': doctor['full_name'] ?? 'No Name',
                'specialty': doctor['specialty'] ?? 'Unknown Specialty',
                'area': doctor['area'] ?? 'Unknown Area',
                'distance': doctor['distance'] ?? 0,
              };
            }).toList();
            _filteredDoctors = _doctors;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Unexpected response format.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load doctors. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoading = false;
      });
      print('Error: $error');
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDoctors = _doctors
          .where((doctor) => doctor['area']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _saveCheckup(String doctorId, String userRemark) async {
    final String saveCheckupApi = '${apiService.mainurl()}/user_checkup.php';

    try {
      final response = await http.post(
        Uri.parse(saveCheckupApi),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'doctor_id': doctorId,
          'user_id': widget.userId,
          'user_remark': userRemark,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _showDialog('Success', 'Your checkup request has been saved.');
        } else {
          _showDialog('Error', data['message'] ?? 'Failed to save request.');
        }
      } else {
        _showDialog('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showDialog('Error', 'An unexpected error occurred: $e');
      print('Error: $e');
    }
  }

  void _showRemarkPopup(String doctorId) {
    TextEditingController remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Special Note'),
          content: TextField(
            controller: remarkController,
            decoration: InputDecoration(
              labelText: 'Enter your special note',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final userRemark = remarkController.text.trim();
                if (userRemark.isNotEmpty) {
                  Navigator.of(context).pop();
                  _saveCheckup(doctorId, userRemark);
                } else {
                  _showDialog('Error', 'Special note cannot be empty.');
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Doctors'),
        backgroundColor: Colors.teal,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ApprovedCheckupsPage(userId: widget.userId),
                ),
              );
            },
            child: Text(
              'Your Checkups',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    // Search Bar with Autocomplete
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _districts.where((district) => district
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _filterDoctors(selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode,
                            onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            onChanged: (value) => _filterDoctors(value),
                            decoration: InputDecoration(
                              labelText: 'Search by Area',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              leading: Icon(Icons.local_hospital,
                                  color: Colors.teal),
                              title: Text(
                                'Dr. ${doctor['full_name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${doctor['specialty']} • Area: ${doctor['area']}',
                              ),
                              onTap: () {
                                _showRemarkPopup(doctor['id'].toString());
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
