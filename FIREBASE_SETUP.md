# Firebase Setup Guide for CookFlow

This guide will walk you through setting up Firebase for CookFlow Phase 3.

## Prerequisites
- Google account
- Flutter project already set up
- Node.js backend already running

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Project name: `CookFlow-Production` (or your preferred name)
4. Disable Google Analytics (optional for now)
5. Click **"Create project"**

---

## Step 2: Register Android App

1. In Firebase console, click the **Android** icon
2. Fill in details:
   - **Android package name**: `com.example.cookflow_app` (check `android/app/build.gradle`)
   - **App nickname**: `CookFlow Android`
   - **Debug signing certificate SHA-1**: (optional for now, required for Google Sign-In)
3. Click **"Register app"**
4. **Download `google-services.json`**
5. Move `google-services.json` to: `cookflow_app/android/app/google-services.json`

---

## Step 3: Register iOS App

1. In Firebase console, click the **iOS** icon
2. Fill in details:
   - **iOS bundle ID**: `com.example.cookflowApp` (check `ios/Runner.xcodeproj`)
   - **App nickname**: `CookFlow iOS`
3. Click **"Register app"**
4. **Download `GoogleService-Info.plist`**
5. Move `GoogleService-Info.plist` to: `cookflow_app/ios/Runner/GoogleService-Info.plist`
   - Open Xcode → Right-click `Runner` folder → Add Files → Select the plist file

---

## Step 4: Enable Authentication

1. In Firebase console → **Authentication** → **Get started**
2. Click **"Sign-in method"** tab
3. Enable providers:
   - ✅ **Email/Password** → Click → Enable → Save
   - ✅ **Google** → Click → Enable → Add support email → Save

---

## Step 5: Create Firestore Database

1. In Firebase console → **Firestore Database** → **Create database**
2. Select **"Start in test mode"** (we'll add security rules later)
3. Choose location: `us-central` or closest to your users
4. Click **"Enable"**

---

## Step 6: Generate Service Account Key (Backend)

1. In Firebase console → **Project Settings** (gear icon) → **Service accounts**
2. Click **"Generate new private key"**
3. Download the JSON file
4. Rename to `firebase-service-account.json`
5. Move to `cookflow/backend/firebase-service-account.json`
6. ⚠️ **Add to `.gitignore`** immediately!

---

## Step 7: Update Environment Variables

Add to `backend/.env`:

```env
# Firebase Admin SDK
FIREBASE_PROJECT_ID=cookflow-production
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

---

## Step 8: Install Dependencies

### Backend (Node.js)
```bash
cd backend
npm install firebase-admin
```

### Flutter App
```bash
cd cookflow_app
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add google_sign_in
```

---

## Step 9: Configure Android for Firebase

Edit `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Edit `android/app/build.gradle`:
```gradle
// Add at the bottom of the file
apply plugin: 'com.google.gms.google-services'
```

---

## Step 10: Configure iOS for Firebase

Run:
```bash
cd ios
pod install
cd ..
```

---

## Verification Checklist

- [ ] `google-services.json` in `android/app/`
- [ ] `GoogleService-Info.plist` in `ios/Runner/`
- [ ] `firebase-service-account.json` in `backend/` (and in `.gitignore`)
- [ ] Firebase Authentication enabled
- [ ] Firestore Database created
- [ ] All dependencies installed
- [ ] Android/iOS configuration complete

---

## Next Steps

Once this setup is complete, we'll implement:
1. `auth_service.dart` - Authentication logic
2. `login_screen.dart` - Login UI
3. `signup_screen.dart` - Signup UI
4. Backend authentication middleware

**Ready to proceed!** 🚀
