import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy — SmartCent',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                              'Privacy Policy — SmartCent',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Effective Date: [Insert Date]',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to SmartCent. We take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile app.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            
            _buildSection(
              '1. Information We Collect',
              [
                'Personal Information: Name, email address, age (for child/parent distinction), and location (if you enable it).',
                'Financial Data: Receipt totals, budgets set, expenses tracked. We do not access your bank account.',
                'Photos/Images: If you scan receipts, we access your camera/gallery only with permission.',
                'Device Information: Device type, operating system, app usage statistics (for performance improvement).',
              ],
            ),
            
            _buildSection(
              '2. How We Use Your Data',
              [
                'To provide budgeting tools, charts, and analytics.',
                'To improve user experience through insights and feedback.',
                'To support child-parent interactions, allowance tracking, and savings goals.',
                'To send you optional notifications and updates (you can opt out anytime).',
              ],
            ),
            
            _buildSection(
              '3. Data Storage and Protection',
              [
                'Your data is stored securely in encrypted databases.',
                'Firebase and Google Vision APIs are used, complying with GDPR/CCPA standards.',
                'We do not sell your personal data to third parties.',
              ],
            ),
            
            _buildSection(
              '4. Children\'s Privacy',
              [
                'SmartCent complies with COPPA and only collects limited data with parental consent.',
                'Children under 13 can use the app only with a parent account linked.',
              ],
            ),
            
            _buildSection(
              '5. Your Rights',
              [
                'You may request to delete your data at any time.',
                'You can review or modify your profile and financial inputs via app settings.',
              ],
            ),
            
            _buildSection(
              '6. Changes to Policy',
              [
                'We may update this Privacy Policy occasionally. We\'ll notify you within the app when we do.',
              ],
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        SizedBox(height: 12),
        ...content.map((text) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        )).toList(),
        SizedBox(height: 20),
      ],
    );
  }
} 