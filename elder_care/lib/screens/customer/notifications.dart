import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  final String userId;

  NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final String apiUrl =
        'http://10.0.2.2/eldercare/notifications.php?userId=${widget.userId}'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');

        // Parse the JSON response
        List<dynamic> rawNotifications = jsonDecode(response.body);

        // Map each notification and prepare it for display
        List<Map<String, dynamic>> parsedNotifications =
            rawNotifications.map((notification) {
          // Convert the 'date' field to a relative time string using timeago
          String relativeTime = 'No Date';
          if (notification['date'] != null) {
            DateTime dateTime =
                DateTime.tryParse(notification['date']) ?? DateTime.now();
            relativeTime = timeago.format(dateTime, locale: 'en');
          }

          // Return the notification map with the required fields
          return {
            'title': notification['title'] ?? 'No Title',
            'description': notification['description'] ?? 'No Description',
            'time': relativeTime, // Use the relative time string
            'icon': Icons.notifications, // Use a default icon
            'color': Colors.teal, // Use a default color
            'image': notification['image'] ?? '', // URL to the image
          };
        }).toList();

        // Reverse the list to show newest notifications first
        parsedNotifications = parsedNotifications.reversed.toList();

        // Update the state with parsed notifications
        setState(() {
          notifications = parsedNotifications;
        });
      } else {
        print('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _notificationCard(
            notification['title'],
            notification['description'],
            notification['time'],
            notification['icon'],
            notification['color'],
            notification['image'], // Pass image URL to the card widget
          );
        },
      ),
    );
  }

  // Function to create a card widget for each notification
  Widget _notificationCard(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
    String imageUrl, // Added imageUrl parameter
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon or Image
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Return a placeholder icon or widget if image loading fails
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.withOpacity(0.2),
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),

            SizedBox(width: 16),
            // Notification Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Arrow Icon for further action (optional)
          ],
        ),
      ),
    );
  }
}
