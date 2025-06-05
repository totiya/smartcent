# BudgetSnap - Smart Receipt Scanner

A comprehensive budget management application with dual-mode functionality for personal and family use.

## Features

- 📷 **Smart Receipt Scanning**: Uses Google Vision API to automatically extract receipt information
- 💰 **Budget Tracking**: Track expenses across multiple categories
- 👨‍👩‍👧‍👦 **Family Mode**: Manage family budgets and kids' allowances
- 📊 **Visual Analytics**: Charts and graphs to visualize spending patterns
- 🔒 **Secure**: Password protection and privacy controls
- 🌙 **Dark Mode**: Beautiful light and dark themes

## Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / Xcode for mobile development
- Google Vision API key (required for receipt scanning)

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
git clone <your-repository-url>
cd budgetsnap
flutter pub get
```

### 2. Configure Google Vision API

#### Get Your API Key:
1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Vision API**:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Vision API"
   - Click on it and press "Enable"
4. Create credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy your API key

#### Configure the API Key:
1. Open `lib/config/api_config.dart`
2. Replace `YOUR_GOOGLE_VISION_API_KEY_HERE` with your actual API key:

```dart
class ApiConfig {
  static const String googleVisionApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
  // ... rest of the file
}
```

⚠️ **Security Note**: For production apps, consider using environment variables or secure key storage instead of hardcoding the API key.

### 3. Platform-Specific Setup

#### Android Setup
The app is already configured with the necessary permissions in `android/app/src/main/AndroidManifest.xml`:
- Camera permission
- Storage permissions
- Internet permission

#### iOS Setup
The app is already configured with the necessary permissions in `ios/Runner/Info.plist`:
- Camera usage description
- Photo library access
- Photo library add usage

### 4. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```

## Features Overview

### Receipt Scanning
- **Camera Mode**: Take photos directly with your camera
- **Gallery Mode**: Select existing photos from your gallery
- **File Browser**: Choose images from your file system
- **Smart Recognition**: Automatically extracts:
  - Total amount
  - Store category
  - Receipt date
  - Barcode information

### Budget Management
- Set monthly budgets by category
- Track spending vs. budget
- Visual progress indicators
- Historical spending analysis

### Family Mode
- Manage multiple family members
- Set and track kids' allowances
- Goal-based savings for children
- Secure access controls

## Troubleshooting

### Camera Issues
1. **Camera doesn't work**:
   - Ensure camera permissions are granted
   - Check if your device has a camera
   - Try restarting the app

2. **Permission denied errors**:
   - Go to device Settings > Apps > BudgetSnap > Permissions
   - Enable Camera, Storage, and Photos permissions

### API Issues
1. **"API key not configured" error**:
   - Make sure you've replaced the placeholder API key in `lib/config/api_config.dart`
   - Check that your API key is valid

2. **"No text detected" errors**:
   - Ensure good lighting when taking photos
   - Keep receipts flat and unfolded
   - Try taking photos straight-on (not at an angle)
   - Make sure text is clear and readable

3. **API quota exceeded**:
   - Check your Google Cloud Console for API usage
   - Consider upgrading your API plan if needed

### General Issues
1. **App crashes on startup**:
   - Run `flutter clean && flutter pub get`
   - Rebuild the app

2. **Dark mode not working**:
   - Check if your device supports dark mode
   - Toggle the setting in the app's settings screen

## Development

### Project Structure
```
lib/
├── config/
│   └── api_config.dart          # API configuration
├── screens/                     # App screens
├── widgets/                     # Reusable widgets
├── providers/                   # State management
├── constants.dart               # App constants
└── main.dart                   # Main app file
```

### Adding New Features
1. Create new screens in the `screens/` directory
2. Add reusable widgets to `widgets/`
3. Use Provider pattern for state management
4. Follow the existing code structure and naming conventions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on both Android and iOS
5. Submit a pull request

## Privacy & Security

- Receipt images are processed through Google Vision API
- No receipt images are stored permanently
- All budget data is stored locally on your device
- Optional password protection for sensitive data

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues:
1. Check this troubleshooting guide
2. Ensure all setup steps are completed
3. Check that permissions are granted
4. Verify your API key is configured correctly

For additional support, please create an issue in the repository.
