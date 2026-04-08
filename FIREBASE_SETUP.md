# Firebase Configuration Guide

## ⚠️ Firebase Setup Required

This app requires Firebase for authentication and data storage. Follow these steps to configure Firebase:

## 📋 Step-by-Step Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `codelearn-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create Project"

### 2. Add Android App
1. In Firebase Console, click "Add app" → Android icon
2. Enter package name: `com.example.untitled`
3. Download `google-services.json`
4. Place file in: `android/app/google-services.json`

### 3. Add iOS App
1. Click "Add app" → iOS icon
2. Enter bundle ID: `com.example.untitled`
3. Download `GoogleService-Info.plist`
4. Place file in: `ios/Runner/GoogleService-Info.plist`

### 4. Add Web App
1. Click "Add app" → Web icon
2. Register app with nickname
3. Copy the Firebase config object

### 5. Update Configuration Files

#### Update `lib/core/config/firebase_config.dart`:
```dart
static FirebaseOptions _getFirebaseOptions() {
  if (kIsWeb) {
    return const FirebaseOptions(
      apiKey: "YOUR_WEB_API_KEY",              // From Firebase Console
      authDomain: "your-project.firebaseapp.com",
      projectId: "your-project-id",
      storageBucket: "your-project.appspot.com",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:abc123",
    );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return const FirebaseOptions(
      apiKey: "YOUR_ANDROID_API_KEY",          // From google-services.json
      appId: "1:123456789:android:abc123",
      messagingSenderId: "123456789",
      projectId: "your-project-id",
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return const FirebaseOptions(
      apiKey: "YOUR_IOS_API_KEY",              // From GoogleService-Info.plist
      appId: "1:123456789:ios:abc123",
      messagingSenderId: "123456789",
      projectId: "your-project-id",
      iosBundleId: "com.example.untitled",
    );
  }
  
  throw UnsupportedError('Unsupported platform');
}
```

### 6. Enable Firebase Services

In Firebase Console:
1. **Authentication**
   - Go to "Build" → "Authentication"
   - Click "Get Started"
   - Enable "Email/Password" sign-in method
   - Enable "Anonymous" sign-in method

2. **Firestore Database**
   - Go to "Build" → "Firestore Database"
   - Click "Create database"
   - Start in **test mode** (for development)
   - Choose location closest to your users

3. **Security Rules** (for production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/progress/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🚀 Quick Start (Without Firebase)

For testing without Firebase setup:

1. Skip authentication:
   - On onboarding screen, use "Skip" button
   - This creates an anonymous session

2. Local testing:
   - All course content is embedded in the app
   - Progress tracking will work locally
   - No sync across devices

## 🔧 Troubleshooting

### Error: "Invalid GOOGLE_APP_ID"
**Solution**: Make sure you've added the configuration files:
- iOS: `GoogleService-Info.plist` in `ios/Runner/`
- Android: `google-services.json` in `android/app/`

### Error: "No Firebase App"
**Solution**: Check that Firebase is initialized in `main.dart`:
```dart
await FirebaseConfig.initialize();
```

### Error: "API Key not valid"
**Solution**: Verify API keys in `firebase_config.dart` match Firebase Console

## 📚 Additional Resources

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## 💡 Alternative: Use Demo Mode

To run the app without Firebase (demo only):
1. Comment out Firebase initialization in `main.dart`
2. Use "Skip" on onboarding
3. Progress won't persist between sessions

---

**Note**: Firebase configuration files are not included in the repository for security reasons. You must create your own Firebase project and add the configuration files.
