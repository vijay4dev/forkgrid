import 'package:flutter/material.dart';
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
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          child: const ForkYouGraphWidget(
            userUrl: 'https://forkyou.dev/user/vijay4dev',
          ),
        ),
      ),
    );
  }
}