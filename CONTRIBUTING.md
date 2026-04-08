# Contributing to CodeLearn

First off, thank you for considering contributing to CodeLearn! 🎉

## 📋 Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Guidelines](#coding-guidelines)
- [Commit Messages](#commit-messages)

---

## 📜 Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inspiring community for all.

### Our Standards
**Examples of behavior that contributes to a positive environment:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior:**
- Trolling, insulting/derogatory comments, personal or political attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

---

## 🤝 How Can I Contribute?

### Reporting Bugs
Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title** - Descriptive summary of the issue
- **Steps to reproduce** - Detailed steps to reproduce the behavior
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Screenshots** - If applicable
- **Environment** - OS, Flutter version, device details
- **Additional context** - Any other relevant information

**Example:**
```
**Bug**: Quiz doesn't validate correct answers

**Steps to reproduce:**
1. Complete Python Lesson 1
2. Answer quiz questions correctly
3. Click "Check Answer"

**Expected**: Green checkmark, "Correct!" message
**Actual**: Red X, "Try again" message

**Environment**: Android 13, Flutter 3.16.0
**Screenshots**: [attached]
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Include:

- **Clear title** - Descriptive summary of the enhancement
- **Detailed description** - Explain the feature and why it's useful
- **Use cases** - Describe scenarios where this feature would help
- **Mockups** - If applicable, add design mockups
- **Alternatives** - Other solutions you've considered

### Adding New Lessons

Want to contribute lesson content? Great! Here's how:

1. **Choose a topic** - Check roadmap for planned courses
2. **Create lesson outline** - Theory → Quiz → Code Challenge
3. **Write content** - Follow the lesson template (see DEVELOPER_GUIDE.md)
4. **Test thoroughly** - Ensure all quiz answers and code tests work
5. **Submit PR** - Include screenshots of the lesson in action

**Lesson Template:**
```dart
Lesson(
  id: 'course-topic-number',
  title: 'Lesson Title',
  description: 'Brief description',
  xpReward: 50,
  theorySlides: [...],  // 3-5 slides
  quiz: QuizData(...),   // 3-5 questions
  codeChallenge: CodeChallenge(...),  // 1 challenge with 3+ test cases
)
```

### Improving Documentation

Documentation improvements are always welcome:
- Fix typos or clarify explanations
- Add examples or tutorials
- Translate documentation (internationalization)
- Update screenshots or diagrams

---

## 💻 Development Setup

### Prerequisites
- Flutter SDK (3.x or higher)
- Dart SDK (included with Flutter)
- Android Studio / VS Code
- Git
- Firebase Account (for testing)

### Setup Steps

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/codelearn.git
   cd codelearn
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/original/codelearn.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Configure Firebase** (optional, for full testing)
   - Create Firebase project
   - Add your apps (Android, iOS, Web)
   - Download config files
   - Place in appropriate directories

6. **Run the app**
   ```bash
   flutter run -d chrome  # Web
   flutter run            # Mobile (device/emulator)
   ```

### Project Structure
See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for detailed architecture overview.

---

## 🔄 Pull Request Process

### Before Submitting

1. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes**
   - Write clean, readable code
   - Follow coding guidelines (below)
   - Add comments for complex logic
   - Update documentation if needed

3. **Test your changes**
   ```bash
   # Run analyzer
   flutter analyze
   
   # Format code
   flutter format .
   
   # Run tests
   flutter test
   
   # Build to verify
   flutter build apk --debug
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new Python lesson on decorators"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

### Submitting the PR

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Fill out the PR template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Web
- [ ] Added/updated tests
- [ ] All tests pass

## Screenshots (if applicable)
[Attach screenshots]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Tests added/updated
```

4. Wait for review
5. Address feedback if requested
6. Celebrate when merged! 🎉

### PR Review Process

- Maintainers will review within 3-5 business days
- May request changes or clarifications
- Once approved, PR will be merged
- Your contribution will be credited in CHANGELOG

---

## 📝 Coding Guidelines

### Dart Style
Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

**Good:**
```dart
// Use descriptive names
final userProgressData = getUserProgress();

// Extract complex logic to methods
Widget _buildProgressCard() { ... }

// Use early returns
if (data == null) return;
```

**Bad:**
```dart
// Unclear variable names
final x = getP();

// Long methods
Widget build() {
  // 200 lines of code...
}

// Deep nesting
if (a) {
  if (b) {
    if (c) { ... }
  }
}
```

### File Organization

```dart
// 1. Imports (grouped and sorted)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service.dart';
import '../models/model.dart';

// 2. Providers
final myProvider = Provider(...);

// 3. Main widget
class MyWidget extends ConsumerWidget { ... }

// 4. Helper widgets/methods (private, underscore prefix)
class _HelperWidget extends StatelessWidget { ... }

void _helperMethod() { ... }
```

### Widget Best Practices

```dart
// Extract reusable widgets
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  
  const StatCard({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) { ... }
}

// Use const constructors when possible
const SizedBox(height: 16)

// Avoid deeply nested widgets
// Instead of: Container > Padding > Column > Row > Container > Text
// Extract: _buildItem() or create ItemWidget
```

### State Management

```dart
// Use Riverpod providers
final counterProvider = StateProvider<int>((ref) => 0);

// Watch in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}

// Read for one-time access
onPressed: () {
  final count = ref.read(counterProvider);
  // Use count...
}
```

---

## 💬 Commit Messages

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style (formatting, no logic change)
- **refactor**: Code refactoring
- **test**: Adding/updating tests
- **chore**: Build process, dependencies

### Examples

**Good:**
```
feat(lessons): add Python lesson on decorators

- Add theory slides explaining decorators
- Create quiz with 5 questions
- Implement code challenge with test cases
- Update course content service

Closes #123
```

```
fix(quiz): correct answer validation

Quiz was marking correct answers as wrong due to
case-sensitive comparison. Changed to case-insensitive.

Fixes #45
```

**Bad:**
```
update stuff
```

```
fixed bug
```

---

## 🎨 Design Guidelines

### Colors
Use theme colors from `app_theme.dart`:
```dart
Theme.of(context).primaryColor
Theme.of(context).colorScheme.secondary
```

### Spacing
Use consistent spacing:
```dart
const SizedBox(height: 8)   // Small
const SizedBox(height: 16)  // Medium
const SizedBox(height: 24)  // Large
```

### Animations
Use `flutter_animate` for consistency:
```dart
Text('Hello')
  .animate()
  .fadeIn(duration: 600.ms)
  .slideY(begin: 0.2, end: 0);
```

---

## ❓ Questions?

- **General questions**: Open a GitHub Discussion
- **Bug reports**: Create an Issue
- **Security issues**: Email security@codelearn.com
- **Feature ideas**: Create an Issue with "enhancement" label

---

## 🏆 Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Mentioned in release notes
- Added to README.md contributors section
- Eligible for special badges/recognition

---

**Thank you for contributing to CodeLearn!** 🎓✨

*Your contributions make learning to code accessible and fun for everyone.*
