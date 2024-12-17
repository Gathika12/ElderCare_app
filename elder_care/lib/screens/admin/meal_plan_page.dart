import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;
import 'add_meal_plan_page.dart'; // Import the second file

class MealPlanPage extends StatefulWidget {
  @override
  _MealPlanPageState createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  List<Map<String, dynamic>> mealPlans = []; // Holds meal plan data
  bool isLoading = true; // Indicates loading state

  // Fetch data from the API
  Future<void> fetchMealPlans() async {
    const String apiUrl = 'http://192.168.1.4/eldercare/get_meal_plans.php';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            mealPlans = List<Map<String, dynamic>>.from(responseData['data']);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete meal plan from the API
  Future<void> deleteMealPlan(int id) async {
    const String apiUrl = 'http://192.168.1.4/eldercare/delete_meal_plan.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // Show success message and refresh meal plans
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Meal plan deleted successfully')),
          );
          fetchMealPlans(); // Refresh the list
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception(
            'Failed to delete meal plan. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting meal plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMealPlans();
  }

  // Navigate to the Add/Edit meal plan page
  void navigateToAddOrEditPage(Map<String, dynamic>? mealPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealPlanPage(
          mealPlan: mealPlan, // Pass the meal plan data if it's editing
        ),
      ),
    ).then((_) {
      fetchMealPlans(); // Refresh the meal plans after returning
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
            onPressed: () {
              navigateToAddOrEditPage(null);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : mealPlans.isEmpty
              ? const Center(
                  child: Text(
                    'No meal plans available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: mealPlans.length,
                  itemBuilder: (context, index) {
                    final mealPlan = mealPlans[index];
                    return Card(
                      margin: const EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          '${mealPlan['conditions']} - ${mealPlan['preference']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        subtitle: Text(
                          mealPlan['meal_plan'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () {
                                navigateToAddOrEditPage(mealPlan);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteMealPlan(
                                    int.parse(mealPlan['id'].toString()));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
