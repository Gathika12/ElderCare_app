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

    // Replace '0' with an empty string when initializing controllers
    checkupLocationController = TextEditingController(
        text: widget.medicalData['checkup_location'] == '0'
            ? ''
            : widget.medicalData['checkup_location']);
    checkupDateController = TextEditingController(
        text: widget.medicalData['checkup_date'] == '0'
            ? ''
            : widget.medicalData['checkup_date']);
    doctorRemarkController = TextEditingController(
        text: widget.medicalData['doctor_remark'] == '0'
            ? ''
            : widget.medicalData['doctor_remark']);
    userRemarkController = TextEditingController(
        text: widget.medicalData['user_remark'] == '0'
            ? ''
            : widget.medicalData['user_remark']);
  }

  Future<void> updateMedicalData() async {
    final Map<String, String> data = {
      'id': widget.medicalData['id'].toString(),
      'checkup_location': checkupLocationController.text,
      'checkup_date': checkupDateController.text,
      'doctor_remark': doctorRemarkController.text,
      'user_remark': userRemarkController.text,
      'approval': '1', // Set approval to 1
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4/eldercare/UpdateMedical.php'),
        body: data,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );

        // Pop back with a result to trigger refresh
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        checkupDateController.text = "${picked.toLocal()}".split(' ')[0];
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
        backgroundColor: Colors.teal,
        title: Text(
          "${widget.medicalData['id']} - ${widget.medicalData['full_name']}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              SizedBox(height: 20),
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
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5.0,
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

  // Function to display header card with ID and Full Name
  Widget _buildHeaderCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.teal, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "ID: ${widget.medicalData['id']}\nFull Name: ${widget.medicalData['full_name']}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build input fields
  Widget buildInputField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.teal.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal.shade600, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
