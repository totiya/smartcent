import 'package:flutter/material.dart';

class SimplePrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Privacy')),
      body: Center(
        child: Text('Privacy Policy Works!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
} 