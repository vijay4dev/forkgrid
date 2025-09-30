import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forkgrid/widgets/graphwidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _username;
   Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Load saved username from SharedPreferences
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('forkyou_username');
    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        _username = savedUsername;
      });
    }
  }

  // Save username in SharedPreferences
  Future<void> _saveUsername() async {
    if (_controller.text.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('forkyou_username', _controller.text.trim());

    setState(() {
      _username = _controller.text.trim();
    });
  }

  void _startApiTimer() {
    _timer?.cancel(); // avoid multiple timers
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      _callApiIfConnected();
    });
    // first call immediately
    _callApiIfConnected();
  }

  // Check internet and call API
  Future<void> _callApiIfConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint("No internet. Skipping API call.");
      return;
    }

    try {
      final response = await http.get(Uri.parse("https://forkyou.dev/user/$_username"));
      if (response.statusCode == 200) {
        debugPrint("API call success: ${response.body.substring(0, 50)}...");
      } else {
        debugPrint("API call failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("API call error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _username == null
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your ForkYou.dev username',
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUsername,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: const Text('Show Graph' , style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              )
            : ForkYouGraphWidget(
                userUrl: 'https://forkyou.dev/user/$_username',
              ),
      ),
    );
  }
}
