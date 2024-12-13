import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class NearestDoctorsPage extends StatefulWidget {
  final String userId;

  NearestDoctorsPage({Key? key, required this.userId}) : super(key: key);
  @override
  _NearestDoctorsPageState createState() => _NearestDoctorsPageState();
}

class _NearestDoctorsPageState extends State<NearestDoctorsPage> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentCity = 'Unknown';

  final String apiUrl = 'http://192.168.1.4/eldercare/get_doctor.php';
  final String saveCheckupApi = 'http://192.168.1.4/eldercare/user_checkup.php';

  @override
  void initState() {
    super.initState();
    _getUserLocationAndFetchDoctors();
  }

  Future<void> _getUserLocationAndFetchDoctors() async {
    try {
      Position position = await _determinePosition();
      await _getCityName(position.latitude, position.longitude);
      await _fetchNearbyDoctors(position.latitude, position.longitude);
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to get location: $error';
        print('error: $error');
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    Position position = await Geolocator.getCurrentPosition();

    print(
        'Current Location: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    return position;
  }

  Future<void> _getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentCity = place.locality ?? 'Unknown';
        });
        print('Current City: $_currentCity');
      } else {
        setState(() {
          _currentCity = 'Unknown';
        });
        print('No placemark data found for the coordinates.');
      }
    } catch (e) {
      setState(() {
        _currentCity = 'Unknown';
      });
      print('Failed to get city name: $e');
    }
  }

  Future<void> _fetchNearbyDoctors(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?latitude=$latitude&longitude=$longitude'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List) {
          setState(() {
            _doctors = responseData
                .where((doctor) => doctor.containsKey('id'))
                .map((doctor) {
              return {
                'id': doctor['id'], // Doctor ID
                'full_name': doctor['full_name'] ?? 'No Name', // Doctor Name
                'specialty': doctor['specialty'] ??
                    'Unknown Specialty', // Doctor Specialty
                'distance': doctor['distance'] ?? 0, // Distance
              };
            }).toList();
          });
          _isLoading = false;
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
        _errorMessage = 'An error occurred while fetching doctors: $error';
        _isLoading = false;
      });
      print('Error: $error');
    }
  }

  Future<void> _saveCheckup(String doctorId, String userRemark) async {
    try {
      print(
          "Sending Data: doctor_id=$doctorId, user_id=${widget.userId}, user_remark=$userRemark");

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
        String responseBody = response.body.trim();
        if (responseBody.startsWith('Connected')) {
          responseBody = responseBody.replaceFirst('Connected', '').trim();
        }

        final data = jsonDecode(responseBody);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Doctors - $_currentCity'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Choose a Doctor for your Medical Checkup',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _doctors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              leading: Icon(Icons.local_hospital,
                                  color: Colors.teal),
                              title: Text(
                                'Dr. ${doctor['full_name'] ?? 'No Name'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${doctor['specialty'] ?? 'Unknown Specialty'} • ${doctor['distance']} km away',
                              ),
                              onTap: () {
                                if (doctor['id'] != null) {
                                  _showRemarkPopup(doctor['id'].toString());
                                } else {
                                  _showDialog('Error', 'Doctor ID not found.');
                                }
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
