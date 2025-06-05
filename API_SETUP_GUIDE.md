# 🔑 Google Vision API Setup Guide

## ✅ Quick Start (5 minutes)

### Step 1: Google Cloud Console Setup
1. **Go to**: [Google Cloud Console](https://console.cloud.google.com)
2. **Sign in** with your Google account
3. **Create a project** (or select existing):
   - Click "Select a project" → "New Project"
   - Enter project name: `BudgetSnap-App`
   - Click "Create"

### Step 2: Enable Vision API
1. **Go to**: APIs & Services → Library
2. **Search for**: "Vision API"
3. **Click** on "Cloud Vision API"
4. **Click**: "Enable"

### Step 3: Set Up Billing (Required)
1. **Go to**: Billing
2. **Link** a payment method (Google gives free credits)
3. **Note**: You get $300 free credits + 1000 free Vision API calls/month

### Step 4: Create API Key
1. **Go to**: APIs & Services → Credentials
2. **Click**: "Create Credentials" → "API Key"
3. **Copy** the generated key (starts with `AIza...`)

### Step 5: Add Key to App
1. **Open**: `lib/config/api_config.dart`
2. **Replace**: `YOUR_GOOGLE_VISION_API_KEY_HERE`
3. **With**: Your actual API key
4. **Save** the file

```dart
// Before
static const String googleVisionApiKey = 'YOUR_GOOGLE_VISION_API_KEY_HERE';

// After
static const String googleVisionApiKey = 'AIzaSyBSREhZpDAkqLk1Zurl0VrvNkt1ELnFQQ4';
```

## 🚨 Common Issues & Solutions

### Issue: "Permission Denied" (403 Error)
**Symptoms**: App says "Permission denied" when scanning
**Solutions**:
- ✅ Make sure Vision API is enabled
- ✅ Check that billing is set up
- ✅ Verify your project has the API enabled

### Issue: "Invalid API Key" (401 Error)
**Symptoms**: App says "Unauthorized" or "Invalid API key"
**Solutions**:
- ✅ Check API key is copied correctly (no extra spaces)
- ✅ Verify key starts with `AIza` and is 39 characters
- ✅ Make sure key isn't expired/revoked

### Issue: "Rate Limit Exceeded" (429 Error)
**Symptoms**: App says "Too many requests"
**Solutions**:
- ✅ Wait a few minutes and try again
- ✅ Check quotas in Google Cloud Console
- ✅ Consider upgrading quota if needed

### Issue: Camera Works But OCR Doesn't
**Symptoms**: Can take photos but text extraction fails
**Solutions**:
- ✅ This is expected behavior - camera works without API key
- ✅ API key is only needed for text recognition (OCR)
- ✅ Follow the setup steps above to enable OCR

## 💰 Cost Information

### Free Tier
- **$300** in free Google Cloud credits
- **1,000** Vision API calls per month (free forever)
- **Perfect** for personal use

### Paid Usage
- **$1.50** per 1,000 requests after free tier
- **Very affordable** for most users
- **Example**: 100 receipts/month = $0.15

## 🔧 Testing Your Setup

### Quick Test
1. **Take a photo** with the app (should work immediately)
2. **Try to process** the image
3. **Check for errors** in the dialog

### Manual API Test
1. **Go to**: [Google Cloud Console API Explorer](https://console.cloud.google.com)
2. **Navigate to**: APIs & Services → Vision API
3. **Try** the "Try this API" feature
4. **Test** with a sample image

## 📱 App Behavior

### ✅ What Works Without API Key:
- Taking photos with camera
- Selecting images from gallery
- Selecting images from files
- All other app features

### 🔍 What Needs API Key:
- Text recognition (OCR) from images
- Automatic receipt data extraction
- Store/category detection

## 🆘 Still Having Issues?

### Check These:
1. **Console errors**: Look at Google Cloud Console logs
2. **App logs**: Check the debug output in your IDE
3. **API status**: Visit [Google Cloud Status](https://status.cloud.google.com)

### Contact Support:
- **Google Cloud**: Use support tickets in console
- **App Issues**: Check the app's GitHub repository

## 🎯 Success Indicators

✅ **Setup Complete When**:
- Camera opens and takes photos
- Gallery selection works
- OCR processing shows results (not errors)
- Receipt data is extracted automatically

Remember: The app is designed to work even without an API key for basic photo functionality! 