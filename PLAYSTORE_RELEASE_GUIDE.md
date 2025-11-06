# Google Play Store Release Guide

## ✅ App Configuration Status

### 1. App Signing - ⚠️ REQUIRES SETUP

**Status**: Template created, needs configuration

**Next Steps**:

1. Open a terminal in your project root
2. Run this command to generate your keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. Enter a strong password when prompted (SAVE THIS PASSWORD!)
4. Fill in your organization details
5. Move `upload-keystore.jks` to `android/app/` folder
6. Create `android/key.properties` file (see template at `android/key.properties.template`)
7. Add your actual passwords to `android/key.properties`

**⚠️ CRITICAL**: Backup your `upload-keystore.jks` file and passwords! If lost, you cannot update your app.

### 2. Package Name - ✅ CONFIGURED

**Current**: `com.muhammados.mens`
**Status**: Changed from default `com.example.mens`

**To customize**: Edit `android/app/build.gradle.kts` line with `applicationId`

### 3. App Version - ✅ CONFIGURED

**Current**: `1.0.0+1`
**Location**: `pubspec.yaml`

**For updates**: Increment the version code (the number after +)

- Example: `1.0.0+2`, `1.0.1+3`, `2.0.0+10`

### 4. Target API Level - ✅ CONFIGURED

**Current**: Android 15 (API 35)
**Location**: `android/app/build.gradle.kts`
**Status**: Meets Google Play 2025 requirements

### 5. App Icon - ✅ CONFIGURED

**Status**: Custom launcher icon configured
**Icon**: `@mipmap/launcher_icon`

### 6. Permissions - ✅ REVIEWED

**Current Permissions**:

- `INTERNET` - Required for API calls

**Location**: `android/app/src/main/AndroidManifest.xml`

### 7. Code Obfuscation - ✅ CONFIGURED

**Status**: ProGuard rules added
**File**: `android/app/proguard-rules.pro`
**Features**:

- Code shrinking enabled
- Resource shrinking enabled
- Obfuscation enabled

---

## 🚀 Building the Release App Bundle

Once you've set up signing (step 1 above), run:

```bash
# Clean previous builds
flutter clean

# Build the release app bundle
flutter build appbundle --release
```

**Output Location**: `build/app/outputs/bundle/release/app-release.aab`

---

## 📋 Google Play Console Checklist

Before submitting your app, prepare these items:

### Store Listing

- [ ] App name (up to 50 characters)
- [ ] Short description (up to 80 characters)
- [ ] Full description (up to 4000 characters)
- [ ] App category
- [ ] Contact email
- [ ] Privacy policy URL (REQUIRED)

### Graphics Assets

- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Phone screenshots (at least 2, up to 8)
- [ ] 7-inch tablet screenshots (optional but recommended)
- [ ] 10-inch tablet screenshots (optional but recommended)

### Content & Rating

- [ ] Complete content rating questionnaire
- [ ] Set target age group
- [ ] Declare if app has ads

### Data Safety

- [ ] Complete data safety form
- [ ] Declare data collection practices
- [ ] Explain data usage for each type collected

### App Access

- [ ] If app requires login: provide demo credentials
- [ ] List any special instructions for testing

### Testing Requirement (NEW 2024+)

- [ ] Create Closed Testing track
- [ ] Add at least 12 testers
- [ ] Run test for minimum 14 days
- [ ] Address any feedback
- [ ] Apply for Production release

---

## 🔐 Security Checklist

- [ ] `key.properties` is in `.gitignore` ✅ (Already configured)
- [ ] `upload-keystore.jks` is backed up securely
- [ ] Passwords stored in password manager
- [ ] No print statements in code ✅ (Already removed)
- [ ] No debug code in production ✅
- [ ] API keys not hardcoded (use environment variables)

---

## 📝 Common Issues & Solutions

### Issue: "Upload failed: You need to use a different package name"

**Solution**: Change `applicationId` in `android/app/build.gradle.kts`

### Issue: "You uploaded a debuggable APK"

**Solution**: Make sure you're building with `--release` flag

### Issue: "Your app's target API level doesn't meet requirements"

**Solution**: Already fixed! We're targeting API 35

### Issue: "App signing error"

**Solution**: Verify your `key.properties` file exists and has correct paths/passwords

---

## 🎯 Quick Start Commands

```bash
# 1. Clean project
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release bundle
flutter build appbundle --release

# 4. Locate the bundle
# File is at: build/app/outputs/bundle/release/app-release.aab
```

---

## 📞 Support Resources

- [Flutter Release Documentation](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android App Signing Guide](https://developer.android.com/studio/publish/app-signing)
