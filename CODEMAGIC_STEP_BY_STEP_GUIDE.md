# 🔧 Codemagic Step-by-Step Setup Guide

## 🎯 **What is Codemagic?**

**Codemagic** is a cloud-based CI/CD service that builds mobile apps for you:
- ✅ **No Mac needed** - builds iOS apps in the cloud
- ✅ **Free tier** - 500 build minutes per month
- ✅ **Automatic builds** - triggers when you push code
- ✅ **Firebase integration** - can upload directly to App Distribution

---

## 📋 **Prerequisites (5 minutes)**

### **1. GitHub Repository**
Your SmartCent project must be on GitHub:

```bash
# If not already on GitHub:
git init
git add .
git commit -m "Initial SmartCent commit"
git remote add origin https://github.com/yourusername/smartcent.git
git push -u origin main
```

### **2. Firebase Configuration Files**
Ensure you have:
- `android/app/google-services.json` (for Android)
- `ios/Runner/GoogleService-Info.plist` (for iOS)

---

## 🚀 **Step 1: Create Codemagic Account (3 minutes)**

### **1.1 Sign Up**
1. **Go to**: https://codemagic.io
2. **Click**: "Sign up"
3. **Choose**: "Sign up with GitHub" (recommended)
4. **Authorize**: Codemagic to access your GitHub

### **1.2 Verify Account**
1. **Check email** for verification link
2. **Click** verification link
3. **Complete profile** setup

---

## 📱 **Step 2: Connect Your Repository (2 minutes)**

### **2.1 Add Repository**
1. **In Codemagic Dashboard**: Click "Add repository"
2. **Select**: "GitHub"
3. **Choose**: Your SmartCent repository
4. **Click**: "Add repository"

### **2.2 Repository Permissions**
- Codemagic will ask for permissions
- **Allow**: Read access to your repository
- **Allow**: Webhook creation (for automatic builds)

---

## ⚙️ **Step 3: Create Build Configuration (10 minutes)**

### **3.1 Create codemagic.yaml File**

In your project root, create `codemagic.yaml`:

```yaml
workflows:
  # iOS Workflow
  ios-workflow:
    name: iOS Workflow
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Install CocoaPods dependencies
        script: |
          cd ios && pod install
      - name: Build iOS
        script: |
          flutter build ipa --release --no-codesign
    artifacts:
      - build/ios/ipa/*.ipa
    
  # Android Workflow (optional - since you can build locally)
  android-workflow:
    name: Android Workflow
    max_build_duration: 60
    environment:
      flutter: stable
    scripts:
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Build Android APK
        script: |
          flutter build apk --release
    artifacts:
      - build/app/outputs/flutter-apk/*.apk
```

### **3.2 Commit and Push**
```bash
git add codemagic.yaml
git commit -m "Add Codemagic configuration"
git push origin main
```

---

## 🔨 **Step 4: Configure iOS Build (5 minutes)**

### **4.1 iOS Code Signing (Important)**

For beta testing, you have two options:

#### **Option A: No Code Signing (Easiest)**
Already included in the YAML above with `--no-codesign`
- ✅ Works for Firebase App Distribution
- ✅ No certificates needed
- ✅ Perfect for beta testing

#### **Option B: Automatic Code Signing (Advanced)**
```yaml
environment:
  ios_signing:
    distribution_type: ad_hoc
    bundle_identifier: com.example.smartcent
```

**For now, use Option A (no code signing)**

---

## 🚀 **Step 5: Start Your First Build (2 minutes)**

### **5.1 Trigger Build**
1. **In Codemagic Dashboard**: Go to your repository
2. **Click**: "Start new build"
3. **Select**: "ios-workflow"
4. **Select**: "main" branch
5. **Click**: "Start new build"

### **5.2 Monitor Progress**
- **Build time**: ~15-20 minutes for iOS
- **Real-time logs**: Watch the build progress
- **Stages**: Setup → Dependencies → Build → Upload

---

## 📊 **Step 6: Understanding the Build Process**

### **6.1 Build Stages**
```
1. 📦 Setup Environment (2 min)
   - Flutter SDK installation
   - Xcode setup
   - Dependencies

2. 🔧 Install Dependencies (3 min)
   - flutter pub get
   - CocoaPods install

3. 🏗️ Build iOS App (10-15 min)
   - Flutter build ipa
   - Code compilation
   - Asset bundling

4. 📤 Generate Artifacts (1 min)
   - Create IPA file
   - Upload to Codemagic storage
```

### **6.2 Expected Output**
- **Success**: Green checkmarks ✅
- **Artifacts**: `smartcent.ipa` file ready for download
- **Logs**: Detailed build information

---

## 📥 **Step 7: Download Your iOS App (2 minutes)**

### **7.1 Download IPA**
1. **Build completed**: Look for green "Success" status
2. **Click**: "Artifacts" tab
3. **Download**: `smartcent.ipa` file
4. **Save to**: Your computer for Firebase upload

### **7.2 File Details**
- **File name**: `smartcent.ipa`
- **Size**: ~30-50MB (typical)
- **Format**: iOS app package ready for distribution

---

## 🔄 **Step 8: Automatic Builds (Optional)**

### **8.1 Enable Auto-Build**
1. **Repository settings**: Go to your repo in Codemagic
2. **Webhooks**: Enable automatic builds
3. **Trigger**: Every push to main branch
4. **Result**: New builds start automatically

### **8.2 Build Triggers**
```bash
# Any push to main will trigger a new build
git add .
git commit -m "Update app features"
git push origin main
# → Codemagic starts building automatically
```

---

## 💰 **Step 9: Free Tier Limits**

### **9.1 Free Plan Includes**
- ✅ **500 build minutes/month**
- ✅ **Unlimited repositories**
- ✅ **All platforms** (iOS, Android, Web)
- ✅ **Basic integrations**

### **9.2 Usage Estimation**
- **iOS build**: ~20 minutes each
- **Monthly capacity**: ~25 iOS builds
- **Perfect for**: Beta testing and development

### **9.3 Monitor Usage**
- **Dashboard**: Shows remaining minutes
- **Billing**: Track usage in account settings
- **Upgrade**: Available if you need more minutes

---

## 🛠️ **Troubleshooting Common Issues**

### **Issue 1: "Build Failed - Dependencies"**
**Solution**:
```yaml
# Add this to your codemagic.yaml
scripts:
  - name: Clean Flutter
    script: |
      flutter clean
      flutter pub get
```

### **Issue 2: "CocoaPods Error"**
**Solution**:
```yaml
scripts:
  - name: CocoaPods Setup
    script: |
      cd ios
      pod repo update
      pod install
```

### **Issue 3: "Build Timeout"**
**Solution**:
```yaml
# Increase build time limit
max_build_duration: 120  # 2 hours
```

### **Issue 4: "Firebase Configuration Missing"**
**Solution**:
- Ensure `GoogleService-Info.plist` is in your repository
- Check file is in correct location: `ios/Runner/GoogleService-Info.plist`

---

## 🚀 **Advanced: Firebase Auto-Upload (Optional)**

### **10.1 Direct Firebase Upload**
Add this to your `codemagic.yaml`:

```yaml
publishing:
  firebase:
    firebase_token: $FIREBASE_TOKEN
    android:
      app_id: your_android_app_id
      groups:
        - testers
    ios:
      app_id: your_ios_app_id
      groups:
        - testers
```

### **10.2 Setup Firebase Token**
1. **Install Firebase CLI**: `npm install -g firebase-tools`
2. **Login**: `firebase login:ci`
3. **Copy token**: Add to Codemagic environment variables
4. **Automatic upload**: After successful build

---

## ✅ **Success Checklist**

### **Codemagic Setup Complete:**
- [ ] Codemagic account created
- [ ] GitHub repository connected
- [ ] `codemagic.yaml` file created and pushed
- [ ] First iOS build started
- [ ] Build completed successfully
- [ ] IPA file downloaded
- [ ] Ready for Firebase App Distribution upload

### **Ready for Distribution:**
- [ ] Android APK built locally ✅
- [ ] iOS IPA built via Codemagic ✅
- [ ] Both files ready for Firebase upload
- [ ] Friends' emails collected
- [ ] Email template prepared

---

## 🎯 **What Happens Next**

### **Immediate (Today):**
1. **Upload IPA** to Firebase App Distribution
2. **Upload APK** to Firebase App Distribution
3. **Add friends** as testers
4. **Send unified email** with both download links

### **Ongoing:**
- **Push code updates** → Codemagic builds automatically
- **New IPA generated** → Upload to Firebase
- **Continuous testing** with your friends

---

## 📞 **Quick Reference**

### **Important Links:**
- **Codemagic Dashboard**: https://codemagic.io/apps
- **Build Logs**: Available in each build
- **Documentation**: https://docs.codemagic.io
- **Support**: Available in Codemagic dashboard

### **Key Commands:**
```bash
# Create config file
touch codemagic.yaml

# Push to trigger build
git add . && git commit -m "Update" && git push

# Check build status
# → Go to Codemagic dashboard
```

---

**🎉 Congratulations! You now have a professional iOS build system without needing a Mac!**

**Next step**: Upload your IPA to Firebase App Distribution and start testing with friends! 