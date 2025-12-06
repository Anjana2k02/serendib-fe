# Quick Start Guide - Serendib App

Get up and running with Serendib in under 5 minutes!

## Prerequisites Checklist

- [ ] Flutter SDK installed (3.0.0+)
- [ ] Android Studio or VS Code installed
- [ ] Android SDK / Xcode installed (depending on target platform)
- [ ] Device or emulator ready

## Quick Setup (3 Steps)

### 1. Install Dependencies

Open terminal in the project directory and run:

```bash
flutter pub get
```

### 2. Run Flutter Doctor

Check if everything is configured:

```bash
flutter doctor
```

Fix any issues marked with ❌ before proceeding.

### 3. Run the App

```bash
flutter run
```

That's it! The app should now be running on your device/emulator.

## First Time Using the App

### Flow Experience

1. **Splash Screen** (2 seconds)
   - Beautiful brown-themed loading screen

2. **Onboarding** (First launch only)
   - 5 simple questions
   - Personalize your experience
   - Progress indicator at top

3. **Login Screen**
   - Enter any email and password (mock auth)
   - Or click "Sign Up" to create account

4. **Home Screen**
   - See 6 feature cards
   - Custom bottom navigation with elevated QR button
   - Explore all features!

### Test Credentials

Since authentication is mocked, use any credentials:
- Email: `test@example.com`
- Password: `123456` (minimum 6 characters)

## Project Structure Overview

```
lib/
├── main.dart              # App entry point
├── core/
│   ├── theme/            # Colors and theme
│   └── constants/        # App constants
├── models/               # Data models
├── providers/            # State management
├── screens/              # All UI screens
└── services/             # Business logic
```

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry and routing |
| `lib/core/theme/app_colors.dart` | Color palette |
| `lib/core/theme/app_theme.dart` | Complete theme |
| `lib/screens/home/home_screen.dart` | Main screen |
| `pubspec.yaml` | Dependencies |

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload (while running)
Press 'r' in terminal

# Hot restart (while running)
Press 'R' in terminal

# Clean build
flutter clean

# Build APK (Android)
flutter build apk

# Check for issues
flutter analyze
```

## Customization Quick Tips

### Change App Name
Edit `pubspec.yaml`:
```yaml
name: your_app_name
description: Your description
```

### Change Colors
Edit `lib/core/theme/app_colors.dart`:
```dart
static const Color primaryBrown = Color(0xFF6B4423); // Your color
```

### Modify Onboarding Questions
Edit `lib/models/onboarding_question.dart`:
```dart
OnboardingQuestion(
  id: 'q1',
  question: 'Your question?',
  options: ['Option 1', 'Option 2', ...],
)
```

### Update Feature Cards
Edit `lib/screens/home/home_content_screen.dart`:
```dart
_FeatureCard(
  icon: Icons.your_icon,
  title: 'Your Feature',
  color: AppColors.yourColor,
  route: '/your-route',
)
```

## Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Dependencies issue?
```bash
rm pubspec.lock
flutter pub get
```

### Android build failed?
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### iOS build failed?
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

## Next Steps

1. **Explore the app** - Click through all features
2. **Read the full README** - Understand the architecture
3. **Check SETUP_GUIDE.md** - Detailed platform setup
4. **Customize** - Make it your own!
5. **Integrate APIs** - Connect to real backends

## Features Ready to Use

✅ Onboarding flow
✅ Authentication UI
✅ Home screen with feature cards
✅ Custom bottom navigation
✅ All feature screens (placeholders)
✅ Settings and profile
✅ Brown & off-white theme
✅ Provider state management
✅ Local storage
✅ Secure token storage

## Features Ready for Integration

🔄 Real authentication API
🔄 Translation API
🔄 QR code scanning
🔄 AR/VR implementation
🔄 Maps integration
🔄 Backend services

## Need Help?

- Read [README.md](README.md) for complete documentation
- Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup
- Run `flutter doctor -v` to diagnose issues
- Check Flutter documentation at https://flutter.dev

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Provider Package**: https://pub.dev/packages/provider
- **Material Design**: https://material.io/design

---

**Happy Coding! 🚀**

Built with Flutter • Designed with ❤️
