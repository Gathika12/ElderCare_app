import 'package:elder_care/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final RentApi apiService = RentApi();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedFilePath;
  String selectedType = 'All Users'; // Default selection
  final List<String> typeOptions = ['All Users', 'Package Buyers'];

  // Function to pick a file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    }
  }

  // Function to send notification
  Future<void> sendNotification(BuildContext context) async {
    final String apiUrl =
        Uri.parse('${apiService.mainurl()}/insert_notifications.php')
            .toString(); // Replace with your actual API URL

    // Map the selected type to the appropriate value
    final String typeValue = selectedType == 'All Users' ? '0' : '1';

    // Prepare the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['title'] = titleController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['type'] = typeValue;

    // Add the image file only if selected, otherwise send '0' as a placeholder
    if (selectedFilePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', selectedFilePath!));
    } else {
      request.fields['image'] = '0'; // Default placeholder for no image
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification Sent Successfully!')),
        );

        // Navigate back after successful insertion
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Notification Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        selectedFilePath == null
                            ? 'Select an Image (Optional)'
                            : selectedFilePath!,
                        style: TextStyle(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Notification Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: typeOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Target Audience',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('All fields are required!')),
                      );
                      return;
                    }
                    sendNotification(context);
                  },
                  child: Text('Send Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
