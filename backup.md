# BudgetSnap Project Backup

## Project Structure
```
budgetsnap/
├── lib/
│   ├── main.dart
│   ├── constants.dart
│   ├── budget_provider.dart
│   ├── receipt_pages.dart
│   ├── receipt.dart
│   ├── receipts_provider.dart
│   ├── screens/
│   ├── providers/
│   ├── widgets/
│   ├── theme/
│   ├── utils/
│   └── models/
├── assets/
│   └── sounds/
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## Dependencies (pubspec.yaml)
```yaml
name: budgetsnap
description: A personal finance management app.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  intl: ^0.18.0
  fl_chart: ^0.63.0
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  path_provider: ^2.1.0
  sqflite: ^2.3.0
  image_picker: ^1.0.4
  http: ^1.1.0
  audioplayers: ^5.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/sounds/
```

## Main Features
1. Family Mode
   - Dashboard with budget overview
   - Monthly reports and comparisons
   - Budget settings and management
   - Receipt scanning and management
   - Settings and preferences

2. Kids Mode
   - Savings tracking
   - Goal setting
   - Achievement system
   - Educational features

3. Core Features
   - Password protection
   - Dark/Light theme support
   - Receipt scanning with OCR
   - Budget tracking and analysis
   - Category management
   - Monthly and yearly reports

## Key Files
1. main.dart - Contains the main application code including:
   - App initialization
   - Theme management
   - Navigation structure
   - Family and Kids mode implementations
   - Receipt scanning and processing
   - Budget management
   - UI components

2. budget_provider.dart - Manages budget data and calculations

3. receipts_provider.dart - Handles receipt storage and management

4. constants.dart - Contains app-wide constants and configurations

## Setup Instructions
1. Ensure Flutter SDK is installed (version 3.0.0 or higher)
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Backup Date
Created on: ${new Date().toISOString()}

## Notes
- The app uses Google Cloud Vision API for OCR functionality
- Data is stored locally using SharedPreferences
- The app supports both iOS and Android platforms
- Material Design is used for the UI
- Provider pattern is used for state management

## Important API Keys
- Google Cloud Vision API Key: AIzaSyBSREhZpDAkqLk1Zurl0VrvNkt1ELnFQQ4
  (Note: This key should be secured and not exposed in production)

## Security Considerations
1. Password protection is implemented for app access
2. Sensitive data is stored locally
3. API keys should be secured in production
4. User data is not shared with external services

## Known Issues
1. OCR accuracy depends on image quality
2. Some date formats may not be recognized
3. Category detection may need manual adjustment

## Future Improvements
1. Cloud backup functionality
2. Enhanced receipt categorization
3. More detailed financial reports
4. Additional security features
5. Multi-language support 