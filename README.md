# 🎓 CodeLearn - Interactive Learning Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> An interactive learning platform similar to Mimo and Sololearn, built with Flutter and Firebase.

## ✨ Features

### 📚 **30 Interactive Lessons**
- **Python**: Variables, Loops, Functions, Exceptions
- **JavaScript**: Async/Await, Objects, Arrays, Functions  
- **HTML/CSS**: Flexbox, Grid, Animations, Responsive Design

### 🎮 **Gamification System**
- **XP System**: Earn XP and level up (100 levels!)
- **Achievements**: Unlock 8 unique achievements
- **Streak Tracking**: Daily activity calendar
- **Progress Bars**: Visual progress on all courses

### 💻 **Advanced Code Editor**
- Line numbers
- Syntax highlighting (Python, JavaScript, HTML/CSS)
- Auto language detection
- Test case validation

### 🎨 **Beautiful UI/UX**
- Material 3 design
- Smooth animations (fade, slide, stagger)
- Quiz animations
- Celebration effects
- Shimmer on success

### 📡 **Offline Support**
- Local caching with `shared_preferences`
- Auto-sync when online
- Offline mode indicator
- Continue learning anywhere

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
- Android Studio / VS Code
- Git
- [Firebase Account](https://firebase.google.com) (optional for full features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/codelearn.git
   cd codelearn
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional - see below for demo mode)
   
   **Option A: Use Demo Mode (Quick Start)**
   - The app includes demo Firebase configuration
   - Run immediately without setup
   - Features work locally but don't sync across devices
   - Perfect for testing and development
   
   **Option B: Setup Real Firebase (Production)**
   - See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions
   - Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Download configuration files:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`
   - Update `lib/core/config/firebase_config.dart` with your credentials

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d <device_id>
   
   # iOS
   flutter run -d <device_id>
   ```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── config/         # Firebase configuration
│   ├── services/       # Auth, Firestore, Cache services
│   └── utils/          # Router, theme, constants
├── features/
│   ├── auth/           # Login, Register, Onboarding
│   ├── courses/        # Course listing
│   ├── lessons/        # Interactive lessons
│   ├── progress/       # XP, levels, offline cache
│   ├── achievements/   # Achievement tracking
│   └── profile/        # User stats & profile
└── shared/
    └── widgets/        # Reusable components
```

## 📱 Screenshots

| Onboarding | Courses | Lesson |
|------------|---------|--------|
| ![Onboarding](docs/screenshots/onboarding.png) | ![Courses](docs/screenshots/courses.png) | ![Lesson](docs/screenshots/lesson.png) |

| Quiz | Profile | Achievements |
|------|---------|--------------|
| ![Quiz](docs/screenshots/quiz.png) | ![Profile](docs/screenshots/profile.png) | ![Achievements](docs/screenshots/achievements.png) |

## 🎯 Usage

### For Students
1. **Start Learning**: Choose a course (Python, JavaScript, or HTML/CSS)
2. **Complete Lessons**: Each lesson has theory, quiz, and code challenge
3. **Earn XP**: Get XP for completing lessons
4. **Level Up**: Reach 100 levels with unique titles
5. **Unlock Achievements**: Complete milestones to earn badges
6. **Track Progress**: View your stats, level, and streak

### For Developers
```dart
// Adding a new lesson
final lesson = Lesson(
  id: 'lesson-id',
  title: 'Your Lesson',
  theorySlides: [...],
  quiz: QuizData(...),
  codeChallenge: CodeChallenge(...),
  xpReward: 50,
);
```

## 🔧 Configuration

### Firebase Setup
1. Enable **Authentication** → Email/Password & Anonymous
2. Enable **Firestore Database**
3. Create collections:
   - `users`: User profiles
   - `progress`: User progress tracking

### Firestore Rules
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

### Localization Packs
The app now loads language metadata and translation packs from JSON assets:

- `assets/l10n/languages.json` — language list for the picker (`code`, `name`, `nativeName`, `flag`)
- `assets/l10n/<locale>.json` — locale key/value translations (for example: `it.json`, `ja.json`)

To add a new language without code changes:
1. Create `assets/l10n/<locale>.json` with translated keys.
2. Add the locale entry to `assets/l10n/languages.json`.
3. Run `flutter pub get` (or restart hot reload) so assets are refreshed.

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **State Management** | Riverpod |
| **Backend** | Firebase (Auth + Firestore) |
| **Navigation** | Go Router |
| **Animations** | flutter_animate |
| **Code Highlighting** | flutter_highlight |
| **Local Storage** | shared_preferences |

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^15.2.0
  firebase_auth: ^5.4.2
  cloud_firestore: ^5.6.1
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  flutter_highlight: ^0.7.0
  shared_preferences: ^2.3.3
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/lessons/lesson_test.dart

# Coverage
flutter test --coverage
```

## 🚀 Build & Deploy

### Debug Build
```bash
flutter build apk --debug        # Android
flutter build ios --debug        # iOS
```

### Release Build
```bash
flutter build apk --release      # Android (36.5s)
flutter build ios --release      # iOS
flutter build web --release      # Web
```

## 📈 Project Stats

- **Total Files**: 37
- **Lines of Code**: ~12,000
- **Lessons**: 30
- **Quiz Questions**: 60+
- **Code Challenges**: 30
- **Completion**: 100% (42/42 tasks)

## 🗺️ Roadmap

### ✅ v1.0.0 - MVP (Completed)
- [x] Authentication & Onboarding
- [x] 30 Interactive Lessons
- [x] XP & Level System
- [x] Achievements
- [x] Offline Support
- [x] Code Editor with Syntax Highlighting

### 🔮 v1.1.0 - Polish (Future)
- [ ] Push Notifications
- [ ] Settings Screen
- [ ] Achievement Toasts
- [ ] Daily Challenges

### 🚀 v2.0.0 - Advanced (Future)
- [ ] Real Code Execution
- [ ] Leaderboards
- [ ] More Courses (SQL, React, TypeScript)
- [ ] Social Features

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Inspired by [Mimo](https://mimo.org) and [Sololearn](https://sololearn.com)
- Built with [Flutter](https://flutter.dev)
- Powered by [Firebase](https://firebase.google.com)
- Icons from [Material Design](https://material.io/icons)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/codelearn/issues)
- **Email**: support@codelearn.com
- **Docs**: See [PROJECT_STATUS.md](PROJECT_STATUS.md) for detailed documentation

---

**Made with ❤️ and GitHub Copilot CLI**  
**Version**: v1.0.0 Production Ready  
**Last Updated**: March 31, 2026
