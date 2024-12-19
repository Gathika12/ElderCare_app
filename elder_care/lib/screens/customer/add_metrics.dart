import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddMetricsScreen extends StatefulWidget {
  final String userId;

  AddMetricsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddMetricsScreenState createState() => _AddMetricsScreenState();
}

class _AddMetricsScreenState extends State<AddMetricsScreen> {
  final RentApi apiService = RentApi();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _sugarLevelController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> addMetrics() async {
    if (_formKey.currentState!.validate()) {
      final metricsData = {
        'user_id': widget.userId,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'blood_pressure': _bloodPressureController.text,
        'sugar_level': _sugarLevelController.text,
        'weight': _weightController.text,
      };

      final response = await http.post(
        Uri.parse('${apiService.mainurl()}/add_metrics.php'),
        body: metricsData,
      );
      print(widget.userId);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Metrics added successfully!')),
        );

        // Navigate back and send a refresh signal
        Navigator.pop(context, true); // Pass true as a signal to refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add metrics.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Health Metrics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Your Health Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _bloodPressureController,
                  decoration: InputDecoration(
                    labelText: 'Blood Pressure (e.g., 120/80)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood pressure';
                    }
                    if (!RegExp(r'^\d{2,3}/\d{2,3}$').hasMatch(value)) {
                      return 'Enter in format: 120/80';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _sugarLevelController,
                  decoration: InputDecoration(
                    labelText: 'Sugar Level (mg/dL)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your sugar level';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: addMetrics,
                    icon: Icon(Icons.check),
                    label: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
