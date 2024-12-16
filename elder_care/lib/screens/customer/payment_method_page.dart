import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/payment.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Details',
      home: PaymentDetailsPage(),
    );
  }
}

class PaymentDetailsPage extends StatefulWidget {
  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final RentApi apiService = RentApi();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> submitPayment() async {
    // Build the URL dynamically using the API service
    final String apiUrl = '${apiService.mainurl()}/payment.php';
    final Uri url = Uri.parse(apiUrl);

    try {
      // Prepare the request body
      final Map<String, String> requestBody = {
        "cardholder_name": _nameController.text,
        "amount": _amountController.text,
        "date": _dateController.text,
        "remark": _remarkController.text,
      };

      // Send POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment submitted successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed: ${jsonResponse['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit payment.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Details"),
        backgroundColor: Color(0xFF04C2C2), // Setting the AppBar color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Payment Details',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 0),
                  child: Image.asset(
                    'assets/images/payment2.jpg',
                    width: 1000,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Your Name'),
              SizedBox(height: 5),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Your name',
                ),
              ),
              SizedBox(height: 20),
              Text('Amount'),
              SizedBox(height: 5),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter amount',
                ),
              ),
              SizedBox(height: 5),
              SizedBox(height: 20),
              Text('Remark'),
              SizedBox(height: 5),
              TextFormField(
                controller: _remarkController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter remark',
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentMethodPage()),
                    );
                  },
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF04C2C2), // Text color
                    padding: EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15), // Button padding
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold), // Text style
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
