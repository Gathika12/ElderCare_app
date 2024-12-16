import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApproveMedicals extends StatefulWidget {
  final dynamic medicalData;

  ApproveMedicals({required this.medicalData});

  @override
  _ApproveMedicalsState createState() => _ApproveMedicalsState();
}

class _ApproveMedicalsState extends State<ApproveMedicals> {
  late TextEditingController checkupLocationController;
  late TextEditingController checkupDateController;
  late TextEditingController doctorRemarkController;
  late TextEditingController userRemarkController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the data passed from the previous page
    checkupLocationController =
        TextEditingController(text: widget.medicalData['checkup_location']);
    checkupDateController =
        TextEditingController(text: widget.medicalData['checkup_date']);
    doctorRemarkController =
        TextEditingController(text: widget.medicalData['doctor_remark']);
    userRemarkController =
        TextEditingController(text: widget.medicalData['user_remark']);
  }

  // Update function for updating medical data using the API
  Future<void> updateMedicalData() async {
    // Prepare the data to send to the API, adding the 'approval' field as 1
    final Map<String, String> data = {
      'id': widget.medicalData['id'].toString(),
      'checkup_location': checkupLocationController.text,
      'checkup_date': checkupDateController.text,
      'doctor_remark': doctorRemarkController.text,
      'user_remark': userRemarkController.text,
      'approval': '1', // Set approval to 1
    };

    // Send POST request to the API
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4/eldercare/UpdateMedical.php'),
        body: data,
      );

      if (response.statusCode == 200) {
        // If the server returns a success response
        print('Data updated successfully');
        print('Response: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        // If the server returns an error
        print('Failed to update data. Status Code: ${response.statusCode}');
        print('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data')),
        );
      }
    } catch (e) {
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during update. Please try again')),
      );
    }
  }

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        checkupDateController.text =
            "${picked.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  @override
  void dispose() {
    checkupLocationController.dispose();
    checkupDateController.dispose();
    doctorRemarkController.dispose();
    userRemarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // Set a professional theme color
        title: Text("Approve Medical Data",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4.0, // Adds slight shadow for a more elevated look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the ID
              Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "ID: ${widget.medicalData['id']}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              buildInputField("Checkup Location", checkupLocationController),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: buildInputField("Checkup Date", checkupDateController),
                ),
              ),
              buildInputField("Doctor Remark", doctorRemarkController),
              buildInputField("User Remark", userRemarkController,
                  enabled: false),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: updateMedicalData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4.0, // Button elevation for a 3D effect
                  ),
                  child: Text("Update Data",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the text field with a consistent style
  Widget buildInputField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        elevation: 2.0,
        margin: EdgeInsets.zero,
        child: TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
      ),
    );
  }
}
