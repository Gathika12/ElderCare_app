import 'dart:convert';

import 'package:elder_care/screens/ChooseRolePage.dart';
import 'package:elder_care/screens/merchant/serviceprovidehome.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceproviderLogin extends StatefulWidget {
  @override
  _ServiceproviderLoginState createState() => _ServiceproviderLoginState();
}

class _ServiceproviderLoginState extends State<ServiceproviderLogin> {
  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false; // Added for toggle visibility
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4/eldercare/serviceprovider_login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.startsWith('Connected')) {
          responseBody = responseBody.replaceFirst('Connected', '').trim();
        }

        final Map<String, dynamic> data = jsonDecode(responseBody);

        if (data.containsKey('message') &&
            data['message'] == "Login successful") {
          String? userId = data['id']?.toString(); // Extract userId
          if (userId == null) {
            _showDialog(context, 'Error', 'User ID not found in response');
            return;
          }
          print('$userId');
          switch (data['redirect']) {
            case 'serviceprovidehome.dart':
              String? fullName = data['full_name'];

              if (fullName == null) {
                _showDialog(context, 'Error',
                    'Required user data not found in response');
                return;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceProvidePage(
                    serviceProviderId: userId,
                    serviceProviderName: fullName,
                  ),
                ),
              );
              break;
            default:
              _showDialog(context, 'Error', 'Unknown redirect path');
              break;
          }
        } else {
          _showDialog(
              context, 'Login Failed', data['message'] ?? 'Unknown error.');
        }
      } else {
        _showDialog(context, 'Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showDialog(context, 'Error', 'An unexpected error occurred: $e');
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 500 : double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/login.png',
                      width: isWideScreen ? 400 : 300,
                      height: isWideScreen ? 300 : 250,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                              color: Colors.black87,
                              fontSize: 16.0,
                              decoration: TextDecoration.none,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: const TextStyle(
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextSpan(
                            text: 'Register Now',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              decoration: TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChooseRolePage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _emailController,
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.teal, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _passwordController,
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.teal, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.teal),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.teal,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          _login(context, _emailController.text.trim(),
                              _passwordController.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
