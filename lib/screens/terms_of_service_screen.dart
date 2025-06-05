import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms of Service — SmartCent',
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
                              'Terms of Service — SmartCent',
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
                              'By using the SmartCent app, you agree to these Terms of Service. Please read them carefully.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            
            _buildSection(
              '1. Using SmartCent',
              [
                                  'You must be 13 years or older, or have parental consent to use SmartCent.',
                'You agree to provide accurate information during registration.',
                'You agree not to use the app for illegal or abusive purposes.',
              ],
            ),
            
            _buildSection(
              '2. Accounts & Security',
              [
                'You are responsible for maintaining the confidentiality of your account.',
                'If you believe your account is compromised, notify us immediately.',
              ],
            ),
            
            _buildSection(
              '3. Subscription & Payment',
              [
                'Some features may be available under a premium subscription.',
                'You will be informed clearly before any charges apply.',
                'All payments are handled securely through the app store (Google Play / App Store).',
              ],
            ),
            
            _buildSection(
              '4. Intellectual Property',
              [
                'All app designs, features, and code are owned by SmartCent Inc.',
                'You may not copy, modify, or distribute any part of the app without written permission.',
              ],
            ),
            
            _buildSection(
              '5. Limitation of Liability',
              [
                'SmartCent is a financial planning assistant, not professional financial advice.',
                'We are not liable for decisions made based on app insights or analytics.',
              ],
            ),
            
            _buildSection(
              '6. Termination',
              [
                'We reserve the right to suspend or terminate your access if you violate these terms.',
              ],
            ),
            
            _buildSection(
              '7. Modifications',
              [
                'We may update these terms. We\'ll notify you of major changes within the app.',
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