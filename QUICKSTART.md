# ⚡ Quick Start Guide

Get CodeLearn running in **5 minutes** without any external setup!

## 🎯 Demo Mode (Recommended for Testing)

The app includes demo Firebase configuration so you can start immediately:

```bash
# 1. Clone and install
git clone https://github.com/yourusername/codelearn.git
cd codelearn
flutter pub get

# 2. Run (that's it!)
flutter run -d chrome          # Web
flutter run                    # Mobile
```

### ✨ What Works in Demo Mode
- ✅ All 30 lessons with theory, quizzes, and code challenges
- ✅ XP system and level progression
- ✅ Achievement tracking
- ✅ Streak calendar
- ✅ Local progress storage (offline support)
- ✅ Beautiful UI and animations

### ⚠️ Demo Mode Limitations
- ❌ Progress doesn't sync across devices
- ❌ No account backup
- ❌ Anonymous authentication only

## 🔥 Production Mode (Real Firebase)

For production deployment with full features:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create new project
   - Add Web/Android/iOS apps

2. **Download Config Files**
   ```
   android/app/google-services.json        # Android config
   ios/Runner/GoogleService-Info.plist     # iOS config
   ```

3. **Update Configuration**
   - Edit `lib/core/config/firebase_config.dart`
   - Replace demo values with your Firebase credentials

4. **Enable Services**
   - Authentication (Email/Password + Anonymous)
   - Firestore Database (test mode for development)

**Detailed instructions:** See [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

## 🚀 First Run

1. **Skip Onboarding** (or create account in production mode)
2. **Browse Courses** - Choose Python, JavaScript, or HTML/CSS
3. **Start Learning** - Complete theory → quiz → code challenge
4. **Earn XP** - Level up and unlock achievements!

## 📱 Platform-Specific Notes

### Web
```bash
flutter run -d chrome
```
- Works immediately in demo mode
- Best for testing

### Android
```bash
flutter run -d <device_id>
```
- Demo mode works out of the box
- Real Firebase requires SHA-1 fingerprint

### iOS
```bash
flutter run -d <device_id>
```
- Demo mode works immediately
- Real Firebase requires Bundle ID setup

## 🐛 Troubleshooting

### "Invalid GOOGLE_APP_ID"
**Solution**: Demo config files are included. If you see this:
1. Verify files exist:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
2. Run `flutter clean && flutter pub get`
3. Rebuild the app

### "No Firebase App"
**Solution**: Demo configuration is pre-configured. If issues persist:
1. Check `lib/core/config/firebase_config.dart` has demo values
2. Verify Firebase initialization in `main.dart`

### Progress Not Saving
**Normal in Demo Mode**: Progress saves locally via cache but won't sync.
**Production Mode**: Ensure Firestore is enabled and rules are configured.

## 💡 Tips

- **Demo → Production**: Simply replace config files and credentials
- **Local Testing**: Use "Skip" on onboarding screen
- **Development**: Demo mode is perfect for UI/UX work
- **Production**: Set up real Firebase before app store deployment

## 📚 Next Steps

- ✅ Complete a few lessons
- ✅ Check out the Profile screen
- ✅ Explore Achievements
- ✅ Review the codebase
- 🔥 Set up real Firebase for production

## 🤝 Need Help?

- 📖 [Full Documentation](README.md)
- 🔥 [Firebase Setup Guide](FIREBASE_SETUP.md)
- 💻 [Developer Guide](DEVELOPER_GUIDE.md)
- 🐛 [Report Issues](https://github.com/yourusername/codelearn/issues)

---

**Made with ❤️ and GitHub Copilot CLI**  
**Version**: v1.0.0 Production Ready
