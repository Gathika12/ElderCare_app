import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class ServiceProviderNotification extends StatefulWidget {
  const ServiceProviderNotification({super.key});

  @override
  State<ServiceProviderNotification> createState() =>
      _ServiceProviderNotificationState();
}

class _ServiceProviderNotificationState
    extends State<ServiceProviderNotification> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final String apiUrl =
        'http://10.0.2.2/eldercare/serviceprovider_notification.php'; 
        // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');

        // Split the response body by <br> to separate each notification
        List<String> rawNotifications = response.body.split('<br>');

        // Remove any empty entries from the list
        rawNotifications
            .removeWhere((notification) => notification.trim().isEmpty);

        // Parse each notification string and create a map for each one
        List<Map<String, dynamic>> parsedNotifications =
            rawNotifications.map((notification) {
          // Split the string by "-" to get individual fields
          List<String> fields = notification.split(' - ');

          // Create a map to store each field's value
          Map<String, String> notificationMap = {};
          for (String field in fields) {
            // Split by ":" to separate key and value
            List<String> keyValue = field.split(': ');
            if (keyValue.length == 2) {
              notificationMap[keyValue[0].trim()] = keyValue[1].trim();
            }
          }

          // Convert the 'Date' field to a relative time string using timeago
          String relativeTime = 'No Date';
          if (notificationMap['Date'] != null) {
            DateTime dateTime =
                DateTime.tryParse(notificationMap['Date']!) ?? DateTime.now();
            relativeTime = timeago.format(dateTime, locale: 'en');
          }

          // Return the notification map with the required fields
          return {
            'title': notificationMap['Title'] ?? 'No Title',
            'description': notificationMap['Description'] ?? 'No Description',
            'time': relativeTime,
            'icon': Icons.notifications,
            'color': Colors.teal,
            'image': notificationMap['Image'] ?? '',
          };
        }).toList();

        // Reverse the list to show newest notifications first
        parsedNotifications = parsedNotifications.reversed.toList();

        setState(() {
          notifications = parsedNotifications;
          isLoading = false; // Set loading to false once data is fetched
        });
      } else {
        print('Failed to load notifications: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No Notifications Available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _notificationCard(
                        notification['title'],
                        notification['description'],
                        notification['time'],
                        notification['icon'],
                        notification['color'],
                        notification['image'],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _notificationCard(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
    String imageUrl,
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
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, exception, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.withOpacity(0.2),
                        child: const Icon(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}
