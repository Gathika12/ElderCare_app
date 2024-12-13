import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class DietaryConsultation extends StatefulWidget {
  @override
  _DietaryConsultationState createState() => _DietaryConsultationState();
}

class _DietaryConsultationState extends State<DietaryConsultation> {
  String? _selectedCondition;
  String? _selectedPreference;
  String _mealPlan = "";
  bool _loading = false;

  final List<String> _conditions = [
    "Diabetes",
    "Hypertension",
    "Heart Disease"
  ];
  final List<String> _preferences = ["Vegetarian", "Non-Vegetarian", "Vegan"];

  Future<bool> requestManageExternalStoragePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> fetchMealPlan() async {
    setState(() {
      _loading = true;
    });
    try {
      final url = Uri.parse(
          "http://192.168.1.4/eldercare/fetch_meal_plan.php?conditions=$_selectedCondition&preference=$_selectedPreference");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            _mealPlan = data['meal_plan'];
          });
        } catch (e) {
          print("Error parsing JSON: $e");
          setState(() {
            _mealPlan = "Error parsing the meal plan data.";
          });
        }
      } else {
        print("HTTP error: ${response.statusCode}, Body: ${response.body}");
        setState(() {
          _mealPlan = "Failed to fetch meal plan (HTTP Error).";
        });
      }
    } catch (e) {
      print("Error fetching meal plan: $e");
      setState(() {
        _mealPlan = "An error occurred while fetching the meal plan.";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Request again if denied
      return await Permission.storage.request().isGranted;
    } else if (status.isPermanentlyDenied) {
      // Notify the user to enable permissions in app settings
      openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Storage permission is permanently denied. Please enable it in app settings."),
        ),
      );
    }
    return false;
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Dietary Consultation",
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              "Condition:",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              _selectedCondition ?? "Not Specified",
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              "Preference:",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              _selectedPreference ?? "Not Specified",
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              "Meal Plan:",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Breakfast:",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Smoothie with spinach, banana, and almond milk.",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Lunch:",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Grilled tofu with brown rice.",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Dinner:",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Vegetable stir-fry with soba noodles.",
              style: pw.TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );

    try {
      // Request Manage External Storage Permission
      if (await requestManageExternalStoragePermission()) {
        // Use the Downloads directory directly
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath =
            "${directory.path}/meal_plan_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final file = File(filePath);

        // Write the PDF file
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Meal Plan saved to $filePath")),
        );
        print("PDF saved to $filePath");
      } else {
        print("Storage permission not granted.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission not granted.")),
        );
      }
    } catch (e) {
      print("Error saving PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save PDF.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dietary Consultation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField(
              hint: Text("Select Condition"),
              value: _selectedCondition,
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value as String;
                });
              },
              items: _conditions
                  .map((condition) => DropdownMenuItem(
                        child: Text(condition),
                        value: condition,
                      ))
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Health Condition",
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              hint: Text("Select Preference"),
              value: _selectedPreference,
              onChanged: (value) {
                setState(() {
                  _selectedPreference = value as String;
                });
              },
              items: _preferences
                  .map((preference) => DropdownMenuItem(
                        child: Text(preference),
                        value: preference,
                      ))
                  .toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Dietary Preference",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedCondition != null && _selectedPreference != null) {
                  fetchMealPlan();
                }
              },
              child: _loading
                  ? CircularProgressIndicator()
                  : Text("Get Meal Plan"),
            ),
            SizedBox(height: 16),
            if (_mealPlan.isNotEmpty)
              Expanded(
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Your Meal Plan",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Text(
                          "Breakfast:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Smoothie with spinach, banana, and almond milk.",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Lunch:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Grilled tofu with brown rice.",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Dinner:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Vegetable stir-fry with soba noodles.",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: generatePdf, // Add PDF generation here
                          icon: Icon(Icons.download),
                          label: Text("Download PDF"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Text(
                "No meal plan to display.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
