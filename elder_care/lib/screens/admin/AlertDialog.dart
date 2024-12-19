import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertDialogInterface extends StatefulWidget {
  @override
  _AlertDialogInterfaceState createState() => _AlertDialogInterfaceState();
}

class _AlertDialogInterfaceState extends State<AlertDialogInterface> {
  final RentApi apiService = RentApi();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedRecipient = 'User';
  final List<String> _recipientOptions = ['User', 'Service Provider'];

  Future<void> _sendNotification(String title, String imageUrl,
      String description, String recipient) async {
    final String apiUrl = '${apiService.mainurl()}/send_alert.php';

    // Set status based on the selected recipient
    final int status = (recipient == 'User') ? 1 : 0;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'image': imageUrl,
          'description': description,
          'recipient': recipient,
          'status': status,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // Successfully sent
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Notification Sent'),
            content: Text(
              'Recipient: $recipient\nTitle: $title\nDescription: $description\nStatus: $status',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Handle connection error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  void _handleSend() {
    final title = _titleController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || imageUrl.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields before sending.'),
        ),
      );
      return;
    }

    _sendNotification(title, imageUrl, description, _selectedRecipient);

    _titleController.clear();
    _imageUrlController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedRecipient = 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
        backgroundColor: Color(0xFF04C2C2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: _selectedRecipient,
                items: _recipientOptions.map((String recipient) {
                  return DropdownMenuItem<String>(
                    value: recipient,
                    child: Text(recipient),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRecipient = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter notification title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Image URL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter notification description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSend,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    backgroundColor: Color(0xFF04C2C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Send',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AlertDialogInterface(),
  ));
}
