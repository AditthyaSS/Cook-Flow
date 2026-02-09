# ⚠️ IMPORTANT: Firebase Configuration Files Needed

This file serves as a reminder that Firebase configuration files are required.

## Missing Files:

1. **android/app/google-services.json**
2. **ios/Runner/GoogleService-Info.plist**

## How to Get These Files:

See [FIREBASE_CHECKLIST.md](../../../FIREBASE_CHECKLIST.md) for complete instructions.

Quick steps:
1. Go to https://console.firebase.google.com
2. Create/select your Firebase project
3. Register your Android app → Download `google-services.json` → Place here
4. Register your iOS app → Download `GoogleService-Info.plist` → Place in ios/Runner/

## DO NOT commit Firebase configuration files to Git!

These files contain sensitive project identifiers. They should be:
- Listed in .gitignore (already done)
- Downloaded individually by each developer
- Configured per environment (dev/staging/production)
