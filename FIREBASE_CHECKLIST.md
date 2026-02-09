# Firebase Setup Checklist for CookFlow

## ⚠️ Current Status
Firebase is **configured in code** but **configuration files are missing**. You need to complete the setup.

---

## 🔴 Missing Files (Required before running app)

### Android Configuration
- [ ] **File**: `cookflow_app/android/app/google-services.json`
  - **How to get**: Firebase Console → Project Settings → Your apps → Android app → Download `google-services.json`
  - **Status**: ❌ NOT FOUND

### iOS Configuration  
- [ ] **File**: `cookflow_app/ios/Runner/GoogleService-Info.plist`
  - **How to get**: Firebase Console → Project Settings → Your apps → iOS app → Download `GoogleService-Info.plist`
  - **Status**: ❌ NOT FOUND

---

## ✅ Already Configured

### Code Setup
- ✅ Firebase initialized in `main.dart` (line 22)
- ✅ Firebase dependencies in `pubspec.yaml`:
  - `firebase_core: ^2.24.0`
  - `firebase_auth: ^4.16.0`
  - `cloud_firestore: ^4.14.0`
  - `google_sign_in: ^6.1.5`
- ✅ Auth service implemented (`auth_service.dart`)
- ✅ Firestore service implemented (`firestore_service.dart`)
- ✅ All screens ready for Firebase integration

---

## 📋 Step-by-Step Firebase Setup

### Step 1: Create Firebase Project (if not done)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select existing project
3. Project name: `CookFlow` (or any name you prefer)
4. Click **"Create project"**

### Step 2: Register Android App

1. In Firebase Console → **Project Overview**
2. Click the **Android icon** to add app
3. Fill in details:
   - **Android package name**: `com.example.cookflow_app`
     - To verify, check: `cookflow_app/android/app/build.gradle`
     - Look for: `applicationId "com.example.cookflow_app"`
   - **App nickname**: `CookFlow Android`
   - **Debug SHA-1**: (optional, needed for Google Sign-In later)
4. Click **"Register app"**
5. **Download `google-services.json`**
6. Move file to: `cookflow_app/android/app/google-services.json`

### Step 3: Register iOS App

1. In Firebase Console → **Project Overview**
2. Click the **iOS icon** to add app
3. Fill in details:
   - **iOS bundle ID**: Check in `cookflow_app/ios/Runner.xcodeproj/project.pbxproj` or Xcode
   - Usually: `com.example.cookflowApp`
   - **App nickname**: `CookFlow iOS`
4. Click **"Register app"**
5. **Download `GoogleService-Info.plist`**
6. Move file to: `cookflow_app/ios/Runner/GoogleService-Info.plist`
7. In Xcode:
   - Open `cookflow_app/ios/Runner.xcworkspace`
   - Right-click `Runner` folder
   - Click "Add Files to Runner"
   - Select `GoogleService-Info.plist`
   - ✅ Check "Copy items if needed"

### Step 4: Enable Firebase Authentication

1. In Firebase Console → **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable the following:

   **Email/Password:**
   - Click "Email/Password"
   - Toggle **Enable**
   - Click **Save**

   **Google Sign-In:**
   - Click "Google"
   - Toggle **Enable**
   - Add support email: your-email@gmail.com
   - Click **Save**

### Step 5: Create Firestore Database

1. In Firebase Console → **Firestore Database**
2. Click **"Create database"**
3. Select mode:
   - **Test mode** (for development - open for 30 days)
   - **Production mode** (for production - we'll add rules)
4. Choose location: `us-central` or closest to your users
5. Click **"Enable"**

### Step 6: Verify Android Configuration

Check `cookflow_app/android/build.gradle`:
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.4.0'  // Should be present
    }
}
```

Check `cookflow_app/android/app/build.gradle`:
```gradle
// At the bottom of the file
apply plugin: 'com.google.gms.google-services'  // Should be present
```

### Step 7: Verify iOS Configuration

Run from `cookflow_app` directory:
```bash
cd ios
pod install
cd ..
```

If you get errors, try:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

---

## 🧪 Testing Firebase Setup

### Test 1: Run the App

```bash
cd cookflow_app

# Android
flutter run -d android

# iOS
flutter run -d ios
```

**Expected**: App should launch without Firebase errors

### Test 2: Test Sign Up

1. Launch app
2. Go to Sign Up screen
3. Enter email and password
4. Tap "Create Account"
5. Check Firebase Console → Authentication → Users
6. Your new user should appear

### Test 3: Test Firestore

1. After signing in, extract a recipe
2. Save the recipe
3. Check Firebase Console → Firestore Database
4. You should see: `users/{uid}/recipes/{recipeId}`

---

## ⚠️ Common Issues & Solutions

### Issue 1: "No Firebase App '[DEFAULT]' has been created"

**Solution**: Make sure configuration files are in the correct location:
- Android: `cookflow_app/android/app/google-services.json`
- iOS: `cookflow_app/ios/Runner/GoogleService-Info.plist`

### Issue 2: "com.google.gms.google-services plugin not found"

**Solution**: 
1. Check `android/build.gradle` has the classpath
2. Check `android/app/build.gradle` applies the plugin
3. Run: `flutter clean && flutter pub get`

### Issue 3: iOS Build Fails

**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Issue 4: "Package name doesn't match"

**Solution**: The package name in Firebase must match exactly:
- Android: Check `android/app/build.gradle` → `applicationId`
- iOS: Check `ios/Runner.xcodeproj` → Bundle Identifier

### Issue 5: Google Sign-In not working on Android

**Solution**: Add SHA-1 fingerprint to Firebase:
```bash
# Debug keystore SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Copy SHA-1 and add to Firebase Console → Project Settings → Your apps → Android app

---

## 🔒 Security: Firestore Rules (Production)

Once testing is done, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can only read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Apply in: Firebase Console → Firestore Database → Rules tab

---

## ✅ Final Verification Checklist

Before deploying to production:

- [ ] `google-services.json` file present in `android/app/`
- [ ] `GoogleService-Info.plist` file present in `ios/Runner/`
- [ ] Firebase project created in console
- [ ] Android app registered in Firebase
- [ ] iOS app registered in Firebase
- [ ] Email/Password authentication enabled
- [ ] Google authentication enabled
- [ ] Firestore database created
- [ ] App runs without Firebase errors
- [ ] Sign up creates user in Firebase Auth
- [ ] Data saves to Firestore
- [ ] Firestore security rules configured (for production)
- [ ] SHA-1 fingerprint added (for Google Sign-In)

---

## 🚀 Quick Start Commands

Once files are in place:

```bash
# Get dependencies
cd cookflow_app
flutter pub get

# Clean build
flutter clean

# iOS pod install
cd ios && pod install && cd ..

# Run app
flutter run

# Check for issues
flutter doctor
```

---

## 📞 Need Help?

- **Firebase Documentation**: https://firebase.google.com/docs/flutter/setup
- **Firebase Console**: https://console.firebase.google.com
- **Troubleshooting**: See FIREBASE_SETUP.md in project root

---

**Status**: ⏳ **Ready for Firebase setup - Download configuration files from Firebase Console**
