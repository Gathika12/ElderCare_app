import 'dart:convert';
import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/EventDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsScreenAdmin extends StatefulWidget {
  @override
  _EventsScreenAdminState createState() => _EventsScreenAdminState();
}

class _EventsScreenAdminState extends State<EventsScreenAdmin> {
  final RentApi apiService = RentApi();
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final String apiUrl =
        Uri.parse('${apiService.mainurl()}/get_events.php').toString();

    setState(() {
      _isLoading = true;
    });

    print("Fetching events from API: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("Raw Response Body: $body");

        if (body is Map &&
            body['status'] == 'success' &&
            body['data'] is List) {
          final List<dynamic> rawEvents = body['data'] as List<dynamic>;

          setState(() {
            // Filter events: exclude those with event_date <= current date
            _events =
                rawEvents.map((e) => e as Map<String, dynamic>).where((event) {
              final eventDate = DateTime.tryParse(event['event_date'] ?? '');
              if (eventDate == null) return false; // Exclude invalid dates
              return eventDate.isAfter(DateTime.now()); // Only future dates
            }).toList();
          });

          print("Filtered Events: $_events");
        } else {
          print("Unexpected Response Format: $body");
          setState(() {
            _events = [];
          });
        }
      } else {
        throw Exception('Failed to load events: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching events: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("Loading state set to false.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(
                  child: Text(
                    'No events available.',
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            child: event['image_url'] != null && event['image_url'].isNotEmpty
                ? Image.network(
                    event['image_url'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 60),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.event, size: 60, color: Colors.grey),
                    ),
                  ),
          ),
          // Event Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'No Title',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(event['event_date'] ?? 'No Date'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 8),
                    Text(event['event_time'] ?? 'No Time'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event['location'] ?? 'No Location',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event['description'] ?? 'No Description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
