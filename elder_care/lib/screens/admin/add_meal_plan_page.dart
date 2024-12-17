import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMealPlanPage extends StatefulWidget {
  final Map<String, dynamic>? mealPlan; // Optional parameter for editing

  const AddMealPlanPage({Key? key, this.mealPlan}) : super(key: key);

  @override
  _AddMealPlanPageState createState() => _AddMealPlanPageState();
}

class _AddMealPlanPageState extends State<AddMealPlanPage> {
  final _formKey = GlobalKey<FormState>();
  String? _conditions;
  String? _preference;
  String? _mealPlan;

  final List<String> preferences = ['Vegetarian', 'Non-Vegetarian'];

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if editing an existing meal plan
    if (widget.mealPlan != null) {
      _conditions = widget.mealPlan!['conditions'];
      _preference = widget.mealPlan!['preference'];
      _mealPlan = widget.mealPlan!['meal_plan'];
    }
  }

  // Function to send meal plan data to PHP
  Future<void> submitMealPlans() async {
    final isEditing = widget.mealPlan != null;
    final url = Uri.parse(
      isEditing
          ? 'http://localhost/eldercare/update_mealplan.php' // Update endpoint
          : 'http://localhost/eldercare/add_mealplan.php', // Add endpoint
    );

    // Send POST request with form data
    final response = await http.post(url, body: {
      'id': widget.mealPlan?['id'] ?? '', // Send ID if editing
      'conditions': _conditions!,
      'preference': _preference!,
      'meal_plan': _mealPlan!,
    });

    final responseData = json.decode(response.body);
    if (responseData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Meal plan updated successfully!'
              : 'Meal plan added successfully!'),
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save meal plan: ${responseData['message']}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealPlan != null ? 'Edit Meal Plan' : 'Add Meal Plan'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _conditions,
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a condition';
                    }
                    return null;
                  },
                  onSaved: (value) => _conditions = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _preference,
                  decoration: const InputDecoration(
                    labelText: 'Preference',
                    border: OutlineInputBorder(),
                  ),
                  items: preferences.map((preference) {
                    return DropdownMenuItem(
                      value: preference,
                      child: Text(preference),
                    );
                  }).toList(),
                  validator: (value) =>
                      value == null ? 'Please select a preference' : null,
                  onChanged: (value) {
                    setState(() {
                      _preference = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _mealPlan,
                  decoration: const InputDecoration(
                    labelText: 'Meal Plan (Breakfast, Lunch, Dinner)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the meal plan details';
                    }
                    return null;
                  },
                  onSaved: (value) => _mealPlan = value,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      submitMealPlans(); // Call the function to send data
                    }
                  },
                  child: Text(
                    widget.mealPlan != null ? 'Update Meal Plan' : 'Add Meal Plan',
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
