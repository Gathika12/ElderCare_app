import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsScreen extends StatefulWidget {
  final String userId;

  EventsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  Future<void> _fetchEvents() async {
    final String apiUrl =
        'http://10.0.2.2/eldercare/get_events.php?id=${widget.userId}'; // Replace with your actual API endpoint

    setState(() {
      _isLoading = true;
    });

    try {
      print('Fetching events from API: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List) {
          // If the response is a list, parse it into events
          setState(() {
            _events = body.map((e) => Map<String, dynamic>.from(e)).toList();
            _isLoading = false;
          });
          print('Parsed events: $_events');
        } else if (body is Map && body.containsKey('message')) {
          // If the response contains a message (e.g., "No records found")
          setState(() {
            _events = [];
            _isLoading = false;
          });
          print('API message: ${body['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'])),
          );
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load events: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Text(
                    'No events found!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _buildEventCard(event);
                  },
                ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                child: event['image_url'] != null &&
                        event['image_url'].isNotEmpty
                    ? Image.network(
                        event['image_url'],
                        height: 250, // Increased height for better visibility
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image,
                              size: 60, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: Icon(Icons.event, size: 60, color: Colors.grey),
                      ),
              ),
              // Overlay with Title and Date
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Untitled Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            event['event_date'] ?? 'Unknown date',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['description'] ?? 'No description available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      event['event_time'] ?? 'Unknown time',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event['location'] ?? 'No location specified.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () {
                  // Add action for "View Details" if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('View details for "${event['title']}"')),
                  );
                },
                child: Text('View Details'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
