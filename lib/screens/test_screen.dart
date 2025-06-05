import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: const Center(
        child: Text(
          'This is a test screen to verify navigation works!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 