import 'package:elder_care/screens/admin/ServiceProviderControlPage.dart';
import 'package:elder_care/screens/customer/UserAdditional.dart';
import 'package:elder_care/screens/customer/UserProfile%20.dart';
import 'package:elder_care/screens/customer/contact1.dart';
import 'package:elder_care/screens/customer/my_services.dart';
import 'package:elder_care/screens/merchant/ViewproviderAdditional.dart';
import 'package:elder_care/screens/customer/contact.dart';
import 'package:elder_care/screens/customer/homepage.dart';
import 'package:elder_care/screens/customer/notifications.dart';
import 'package:elder_care/screens/customer/packages.dart';

import 'package:elder_care/screens/login_page.dart';

//import 'package:elder_care/screens/packages.dart';
import 'package:flutter/material.dart';

class MainBottomNav extends StatefulWidget {
  final String email;
  final String userId; // Accept userId

  MainBottomNav({required this.email, required this.userId});

  @override
  _MainBottomNavState createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;

  // List of pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize _pages here to access widget.email
    _pages = <Widget>[
      UserDashboard(
        userId: widget.userId,
      ),
      Package(
        userId: widget.userId,
      ),
      NotificationScreen(
        userId: widget.userId,
      ),
      HelpContactPage1(
        userId: widget.userId,
      ),
      UserProfile(userId: widget.userId), // Access email from widget
    ];
  }

  // Corresponding titles for each page
  static final List<String> _titles = <String>[
    'Dashboard',
    'Packages',
    'Reminders',
    'Contact Us',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]), // Dynamic title
        backgroundColor: Colors.teal,
        elevation: 8,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal,
                Colors.teal[700]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Packages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'ElderCare Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.health_and_safety),
              title: Text('Additional Services'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserAdditional(
                            userId: widget.userId,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.approval),
              title: Text('My Services'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyServices(
                            userId: widget.userId,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Buy Packages'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('Contact US'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                            role: '',
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
