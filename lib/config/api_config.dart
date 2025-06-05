class ApiConfig {
  // TODO: Replace with your actual Google Vision API key
  // For production, consider using environment variables or secure storage
  static const String googleVisionApiKey = 'AIzaSyBSREhZpDAkqLk1Zurl0VrvNkt1ELnFQQ4';
  
  // Google Vision API endpoint
  static const String googleVisionApiUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  // Check if API key is configured
  static bool get isApiKeyConfigured => 
      googleVisionApiKey != 'YOUR_GOOGLE_VISION_API_KEY_HERE' && 
      googleVisionApiKey.isNotEmpty &&
      googleVisionApiKey.length > 10; // Basic length check
      
  // Validate API key format (basic check)
  static bool get isApiKeyFormatValid {
    if (!isApiKeyConfigured) return false;
    // Google API keys typically start with AIza and are 39 chars long
    return googleVisionApiKey.startsWith('AIza') && googleVisionApiKey.length == 39;
  }
      
  // Get setup instructions for API key
  static String get setupInstructions => '''
🔑 Google Vision API Key Setup Required

To scan receipts, you need to configure your Google Vision API key:

1. Go to Google Cloud Console (console.cloud.google.com)
2. Create a new project or select existing one
3. Enable the Vision API:
   • Go to APIs & Services > Library
   • Search for "Vision API" and enable it
4. Create an API key:
   • Go to APIs & Services > Credentials
   • Click "Create Credentials" > "API Key"
   • Copy the generated key

5. Add your API key to the app:
   • Open lib/config/api_config.dart
   • Replace 'YOUR_GOOGLE_VISION_API_KEY_HERE' with your actual key

📱 Camera works without API key - you can take photos!
🔍 API key is only needed for text recognition (OCR).
''';

  // Get troubleshooting instructions for API errors
  static String get troubleshootingInstructions => '''
🚨 API Key Issues - Troubleshooting

If you're getting API errors, check these common issues:

🔧 API Key Problems:
• Make sure your API key is correct (39 characters, starts with "AIza")
• Check that it's properly copied without extra spaces
• Verify the key is not expired or revoked

🔧 Google Cloud Setup:
• Ensure Vision API is enabled in your Google Cloud project
• Check that billing is set up (Google requires a billing account)
• Verify API quotas aren't exceeded

🔧 Common Error Codes:
• 403 Forbidden: API not enabled or billing issue
• 400 Bad Request: Invalid API key format
• 429 Too Many Requests: Rate limit exceeded

🔧 Quick Test:
• Try the API key in Google Cloud Console API Explorer
• Check your Google Cloud Console for error details

💡 Need Help?
• Visit: console.cloud.google.com
• Check: APIs & Services > Credentials
• Enable: APIs & Services > Library > Vision API
''';

  // Get user-friendly error message based on HTTP status code
  static String getErrorMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return "❌ Invalid API request. Please check your API key format.\n\n${troubleshootingInstructions}";
      case 401:
        return "❌ Unauthorized. Your API key may be invalid or expired.\n\n${troubleshootingInstructions}";
      case 403:
        if (responseBody.contains('PERMISSION_DENIED')) {
          return "❌ Permission denied. Make sure:\n• Vision API is enabled in Google Cloud\n• Billing is set up\n• API key has proper permissions\n\n${troubleshootingInstructions}";
        }
        return "❌ Access forbidden. Check your API key permissions and billing setup.\n\n${troubleshootingInstructions}";
      case 429:
        return "❌ Rate limit exceeded. Please wait a moment and try again.\n\nIf this persists, check your API quotas in Google Cloud Console.";
      case 500:
      case 502:
      case 503:
        return "❌ Google server error. Please try again in a few moments.\n\nIf the problem persists, check Google Cloud Status page.";
      default:
        return "❌ API Error (${statusCode}): ${responseBody}\n\n${troubleshootingInstructions}";
    }
  }
} 