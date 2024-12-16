import 'dart:convert';

import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/meal_plan.dart';
import 'package:elder_care/screens/customer/nearest_doctors.dart';
import 'package:elder_care/screens/customer/special_events.dart';
import 'package:elder_care/screens/customer/view_metrics.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class UserDashboard extends StatefulWidget {
  final String userId;

  UserDashboard({Key? key, required this.userId}) : super(key: key);
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  final RentApi apiService = RentApi();
  int _currentImageIndex = 0;
  AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentTrackUrl;
  List<String> _images = [
    'assets/images/slide1.jpg',
    'assets/images/slide2.jpg',
    'assets/images/slide3.jpg'
  ];
  List<Map<String, String>> _playlist = [
    {
      'title': 'Song 1',
      'artist': 'Artist 1',
      'url': 'music/songs1.mp3', // Local path
    },
    {
      'title': 'Song 2',
      'artist': 'Artist 2',
      'url': 'music/songs2.mp3',
    },
    {
      'title': 'Song 3',
      'artist': 'Artist 3',
      'url': 'music/songs3.mp3',
    },
    {
      'title': 'Song 4',
      'artist': 'Artist 4',
      'url': 'music/songs4.mp3',
    },
    {
      'title': 'Song 5',
      'artist': 'Artist 5',
      'url': 'music/songs5.mp3',
    },
  ];

  bool isPlaying = false;
  bool isLoading = true;
  int package = 0; // Default value

  @override
  void initState() {
    super.initState();
    _fetchPackageStatus();

    _initializeAnimations();
  }

  // Initialize animations and set state after a delay for smooth transitions
  void _initializeAnimations() async {
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      isLoading = false;
    });
  }

  // Function to handle track play/pause
  void _playTrack(String url) async {
    if (_currentTrackUrl == url && isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (url.startsWith('http')) {
        await _audioPlayer.play(UrlSource(url));
      } else {
        await _audioPlayer.play(AssetSource(url));
      }
      setState(() {
        _currentTrackUrl = url;
        isPlaying = true;
      });
    }
  }

  // Fetch package status from API
  Future<void> _fetchPackageStatus() async {
    final url = Uri.parse(
        '${apiService.mainurl()}/package_status.php?id=${widget.userId}');
    try {
      final response = await http.get(url);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Remove the "Connected" prefix
          final jsonString = response.body.replaceFirst('Connected', '').trim();
          print('Cleaned JSON String: $jsonString');

          final data = json.decode(jsonString);
          print('Decoded Data: $data');
          setState(() {
            package =
                data['data']['package']; // Adjusted to match your API structure
            isLoading = false;
          });
        } catch (decodeError) {
          print('JSON Decode Error: $decodeError');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load package status');
      }
    } catch (e) {
      print('Error fetching package: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to show the nurse contact popup dialog
  void _showNurseContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNurseContact('Nurse Alice', '555-1234'),
              _buildNurseContact('Nurse Bob', '555-5678'),
              _buildNurseContact('Nurse Carol', '555-8765'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Method to build individual nurse contact row with phone icon
  Widget _buildNurseContact(String name, String contactNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.green),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _launchDialer(contactNumber);
                },
                child: Text(
                  contactNumber,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to launch the dialer with the nurse's phone number
  void _launchDialer(String phoneNumber) async {
    final Uri dialUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(dialUri)) {
      await launchUrl(dialUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $phoneNumber')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add Fade Transition on Image Carousel
              AnimatedOpacity(
                opacity: isLoading ? 0.0 : 1.0,
                duration: Duration(seconds: 1),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: true,
                    aspectRatio: 2.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: _images.map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return AnimatedOpacity(
                          opacity: isLoading ? 0.0 : 1.0,
                          duration: Duration(milliseconds: 800),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20),

              // Package Offer Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  if (package == 0)
                    Text(
                      'Buy A Package For an Amazing Offer',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    )
                  else
                    Wrap(
                      spacing: 20.0, // Horizontal space between icons
                      runSpacing: 20.0, // Vertical space if wrapping is needed
                      alignment: WrapAlignment
                          .center, // Center-align icons horizontally
                      children: _getPackageIcons(),
                    ),
                ],
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showNurseContactsDialog(context);
                },
                child: Text(
                  "Call a nurse!",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),

              SizedBox(height: 20),

              // Smooth Now Playing Section with AnimatedSwitcher

              // Smooth Now Playing Section with AnimatedSwitcher
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity, // Full width
                  height: 220.0, // Custom height
                  child: Card(
                    key: ValueKey<String>(_currentTrackUrl ?? 'no_track'),
                    elevation: 8, // Increased elevation for better depth
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Now Playing',
                            style: TextStyle(
                              fontSize: 22, // Increased font size for the title
                              fontWeight: FontWeight.bold,
                              color: Colors.teal, // Color for the title
                            ),
                          ),
                          SizedBox(height: 10),

                          // Track Title
                          Text(
                            _currentTrackUrl != null
                                ? _playlist.firstWhere((track) =>
                                    track['url'] == _currentTrackUrl)['title']!
                                : 'Select a Song',
                            style: TextStyle(
                              fontSize:
                                  18, // Increased font size for better readability
                              fontWeight: FontWeight.w600,
                              color: Colors.black, // Track title color
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            _currentTrackUrl != null
                                ? _playlist.firstWhere((track) =>
                                    track['url'] == _currentTrackUrl)['artist']!
                                : 'Artist',
                            style: TextStyle(
                              fontSize: 16, // Slightly increased font size
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),

                          // Play/Pause Button with a larger tap area and a shadow effect
                          ElevatedButton(
                            onPressed: () {
                              if (_currentTrackUrl != null) {
                                _playTrack(_currentTrackUrl!);
                              }
                            },
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 36, // Increased icon size
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16), // Larger tap target
                              backgroundColor: Colors.teal, // Button color
                              elevation: 4, // Added shadow for elevation
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

// Playlist Section with AnimatedList
              Text(
                'Playlist',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              SizedBox(height: 10),
              AnimatedOpacity(
                opacity: isLoading ? 0.0 : 1.0,
                duration: Duration(milliseconds: 1000),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _playlist.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      elevation: 3, // Added elevation to each track card
                      child: ListTile(
                        leading: Icon(Icons.music_note, color: Colors.blue),
                        title: Text(_playlist[index]['title']!),
                        subtitle: Text(_playlist[index]['artist']!),
                        trailing: IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () {
                            _playTrack(_playlist[index]['url']!);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build icons based on the package value
  List<Widget> _getPackageIcons() {
    List<Widget> icons = [];

    // Add icons based on the package value
    if (package >= 1) {
      icons.add(_buildIconColumn(
          Icons.medication, "Checkup", Colors.green[100]!, _onCheckupTap));
    }
    if (package >= 2) {
      icons.add(_buildIconColumn(
          Icons.lunch_dining, "Dietary", Colors.pink[100]!, _onDietaryTap));
    }
    if (package == 3) {
      icons.add(_buildIconColumn(
          Icons.favorite, "Events", Colors.blue[100]!, _onEventsTap));
      icons.add(_buildIconColumn(Icons.favorite, "Check Health",
          Colors.blue[100]!, _onHealthCheckTap));
    }

    // Return a centered Wrap widget for responsiveness
    return [
      Wrap(
        spacing: 20.0, // Horizontal space between icons
        runSpacing: 20.0, // Vertical space between icons
        alignment: WrapAlignment.center, // Center-align the icons horizontally
        children: icons,
      ),
    ];
  }

  // Example onTap actions
  void _onEventsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EventsScreen(
                userId: widget.userId,
              )),
    );
    // Add your desired behavior here
  }

  void _onDietaryTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DietaryConsultation()),
    );
    // Add your desired behavior here
  }

  void _onCheckupTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NearestDoctorsPage(
                userId: widget.userId,
              )),
    );
    // Add your desired behavior here
  }

  void _onHealthCheckTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ViewMetricsScreen(
                userId: widget.userId,
              )),
    );
    // Add your desired behavior here
  }

// Helper method to build icons with labels and onTap actions
  Widget _buildIconColumn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Action when the icon is tapped
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Icon(icon, size: 40, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
