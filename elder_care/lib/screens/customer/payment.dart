import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Method',
      home: PaymentMethodPage(),
    );
  }
}

class PaymentMethodPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  TextEditingController _cardNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _securityCodeController = TextEditingController();

  Future<void> _selectExpiryDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Method"),
        backgroundColor: Color(0xFF04C2C2), // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed the title Text widget
            SizedBox(height: 30),
            Text('Card Number'),
            SizedBox(height: 5),
            TextFormField(
              controller: _cardNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter card number',
              ),
            ),
            SizedBox(height: 20),

            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter cardholder name',
              ),
            ),
            SizedBox(height: 20),
            Text('Expiration Date'),
            SizedBox(height: 5),
            TextFormField(
              controller: _expiryDateController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select expiration date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                _selectExpiryDate(context);
              },
            ),
            SizedBox(height: 20),
            Text('Security Code'),
            SizedBox(
              height: 5,
              width: 2,
            ),
            TextFormField(
              controller: _securityCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter security code',
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add the functionality for Pay Now button here
                },
                child: Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF04C2C2), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
