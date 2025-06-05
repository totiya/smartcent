# 🔧 BudgetSnap Setup Guide - Camera & API Fix

This guide will help you resolve the camera and API key issues in your BudgetSnap app.

## 🚨 Issues Fixed

✅ **Camera not working**  
✅ **API key error**  
✅ **Missing permissions**  
✅ **Better error handling**

## 📱 What Was Fixed

### 1. Camera Permissions
**Problem**: App couldn't access camera  
**Solution**: Added proper permissions for Android and iOS

- **Android**: Added camera, storage, and internet permissions to `AndroidManifest.xml`
- **iOS**: Added camera and photo library usage descriptions to `Info.plist`

### 2. API Key Security
**Problem**: Hardcoded API key causing errors  
**Solution**: Created secure API configuration system

- **Before**: API key was hardcoded in source code
- **After**: API key is configurable in `lib/config/api_config.dart`

### 3. Permission Handling
**Problem**: No runtime permission requests  
**Solution**: Added permission checks before camera/gallery access

- Camera permission check before scanning
- Photo library permission check before gallery access
- Storage permission check before file browsing

## 🛠️ Setup Steps

### Step 1: Configure Your Google Vision API Key

1. **Get API Key** (if you don't have one):
   ```
   📍 Go to: https://console.cloud.google.com/
   📍 Create project or select existing one
   📍 Enable "Vision API" in APIs & Services > Library
   📍 Create API Key in APIs & Services > Credentials
   ```

2. **Configure in App**:
   - Open `lib/config/api_config.dart`
   - Replace this line:
     ```dart
     static const String googleVisionApiKey = 'YOUR_GOOGLE_VISION_API_KEY_HERE';
     ```
   - With your actual key:
     ```dart
     static const String googleVisionApiKey = 'YOUR_ACTUAL_API_KEY_FROM_GOOGLE';
     ```

### Step 2: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### Step 3: Test Camera Functionality

1. **Launch the app**
2. **Navigate to receipt scanning**
3. **Try taking a photo** - app should now request camera permission
4. **Grant permissions** when prompted

## ✅ How to Verify It's Working

### Camera Test:
1. Open the app
2. Go to receipt scanning
3. Tap camera button
4. ✅ You should see a permission request
5. ✅ After granting, camera should open
6. ✅ You can take a photo

### API Key Test:
1. Take a photo of a receipt
2. ✅ Should process without "API key" error
3. ✅ Should extract text from receipt
4. ✅ Should show detected amount and category

## 🔍 Troubleshooting

### "API key not configured" Error
```
❌ Error: API key not configured
✅ Solution: Check lib/config/api_config.dart has your real API key
```

### "Camera permission required" Error
```
❌ Error: Camera permission is required
✅ Solution: Grant camera permission in device settings
```

### "No text detected" Error
```
❌ Error: No text detected in image
✅ Solution: 
   - Ensure good lighting
   - Keep receipt flat
   - Take photo straight-on
   - Make sure text is readable
```

### Manual Permission Fix
If permissions aren't working:

**Android**:
1. Settings > Apps > BudgetSnap > Permissions
2. Enable Camera, Storage, Photos

**iOS**:
1. Settings > Privacy & Security > Camera
2. Enable for BudgetSnap
3. Settings > Privacy & Security > Photos
4. Enable for BudgetSnap

## 📋 File Changes Made

| File | What Changed |
|------|-------------|
| `android/app/src/main/AndroidManifest.xml` | ✅ Added camera & storage permissions |
| `ios/Runner/Info.plist` | ✅ Added camera & photo usage descriptions |
| `lib/config/api_config.dart` | ✅ NEW: Secure API key configuration |
| `lib/main.dart` | ✅ Added permission checks & better error handling |
| `pubspec.yaml` | ✅ Added permission_handler dependency |

## 🚀 Performance Improvements

- **Better Image Quality**: Increased image quality for OCR
- **Enhanced Text Detection**: Uses both TEXT_DETECTION and DOCUMENT_TEXT_DETECTION
- **Improved Error Messages**: Clear, actionable error messages
- **Permission Flow**: Smooth permission request experience

## 🔐 Security Notes

- API key is now configurable (not hardcoded)
- For production, consider using environment variables
- Receipt images are processed but not stored permanently
- All data remains on your device

## 📞 Need Help?

If you still have issues:

1. **Check the logs**: Look for error messages in console
2. **Verify API key**: Make sure it's valid and Vision API is enabled
3. **Check permissions**: Ensure all permissions are granted
4. **Try different photos**: Use clear, well-lit receipt images

## 🎉 You're All Set!

Your BudgetSnap app should now:
- ✅ Access camera without issues
- ✅ Process receipts using Google Vision API
- ✅ Handle permissions gracefully
- ✅ Provide clear error messages

Happy budget tracking! 💰📊 