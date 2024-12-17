import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppointmentsPage extends StatefulWidget {
  final String doctorId;

  AppointmentsPage({required this.doctorId});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<List<dynamic>> _appointments;
  final String apiUrl = "http://192.168.1.4/eldercare/schedules.php";

  @override
  void initState() {
    super.initState();
    _appointments = fetchAppointments();
  }

  Future<List<dynamic>> fetchAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?doctor_id=${widget.doctorId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'No appointments found.');
        }
      } else {
        throw Exception(
            "Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upcoming Appointments"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No upcoming appointments found."));
          } else {
            final appointments = snapshot.data!;
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      "Location: ${appointment['checkup_location']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          "Date: ${appointment['checkup_date']}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Doctor's Remark: ${appointment['doctor_remark'] ?? 'N/A'}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "User's Remark: ${appointment['user_remark'] ?? 'N/A'}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.calendar_today, color: Colors.teal),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
