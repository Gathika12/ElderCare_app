import 'package:elder_care/apiservice.dart';
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
  final RentApi apiService = RentApi();
  String? _selectedCondition;
  String? _selectedPreference;
  String _mealPlan = "";
  bool _loading = false;

  List<String> _conditionList = []; // List to hold fetched conditions
  final List<String> _preferences = ["Vegetarian", "Non-Vegetarian", "Vegan"];

  @override
  void initState() {
    super.initState();
    fetchConditions(); // Fetch conditions on page load
  }

  // Function to fetch conditions from the database
  Future<void> fetchConditions() async {
    try {
      final String apiUrl = '${apiService.mainurl()}/meal_plan_conditions.php';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            // Use a Set to eliminate duplicate conditions
            _conditionList = List<String>.from(
                data['data'].map((item) => item['conditions']).toSet());
          });
        } else {
          throw Exception(data['message'] ?? "Failed to load conditions.");
        }
      } else {
        throw Exception(
            "Failed to fetch conditions. HTTP Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching conditions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading conditions: $e")),
      );
    }
  }

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
      _mealPlan = ""; // Clear previous meal plan
    });

    try {
      final String apiUrl =
          '${apiService.mainurl()}/fetch_meal_plan.php?conditions=$_selectedCondition&preference=$_selectedPreference';
      final Uri url = Uri.parse(apiUrl);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['meal_plan'] != null) {
          final Map<String, dynamic> mealPlanMap = data['meal_plan'];

          // Format the meal plan data into a readable string
          setState(() {
            _mealPlan = mealPlanMap.entries.map((entry) {
              return "${entry.key}: ${entry.value}";
            }).join("\n\n"); // Each meal part separated with a line break
          });
        } else {
          setState(() {
            _mealPlan = "No meal plan found for the selected options.";
          });
        }
      } else {
        setState(() {
          _mealPlan =
              "Failed to fetch meal plan (HTTP ${response.statusCode}).";
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
            pw.Text("Dietary Consultation",
                style:
                    pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 24),
            pw.Text("Condition:",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(_selectedCondition ?? "Not Specified",
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 16),
            pw.Text("Preference:",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(_selectedPreference ?? "Not Specified",
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 24),
            pw.Text("Meal Plan:",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(_mealPlan, style: pw.TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );

    try {
      if (await requestManageExternalStoragePermission()) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) await directory.create(recursive: true);

        final filePath =
            "${directory.path}/meal_plan_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final file = File(filePath);

        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Meal Plan saved to $filePath")),
        );
        print("PDF saved to $filePath");
      }
    } catch (e) {
      print("Error saving PDF: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to save PDF.")));
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
            // Updated DropdownButtonFormField for Conditions
            DropdownButtonFormField(
              hint: Text("Select Condition"),
              value: _selectedCondition,
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value as String;
                });
              },
              items: _conditionList
                  .map((condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
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
                child: SingleChildScrollView(
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
                            _mealPlan, // Display dynamically formatted meal plan
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed:
                                generatePdf, // Generate PDF with dynamic content
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
