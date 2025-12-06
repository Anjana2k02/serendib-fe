# Serendib - Flutter Mobile Application

A beautiful Flutter mobile application with a brown and off-white color theme, designed to showcase Sri Lankan tourism and culture.

## Features

### 🎨 Design System
- **Color Palette**: Brown and off-white tones creating a warm, elegant aesthetic
- **Custom Theme**: Complete Material Design 3 implementation
- **Consistent UI**: Reusable components with standardized spacing and styling
- **Responsive**: Adapts to different screen sizes

### 🚀 Core Features

#### 1. Onboarding Experience
- 5 interactive questions to personalize user experience
- Shows only on first app launch
- Smooth page transitions and progress tracking
- Beautiful custom option cards

#### 2. Authentication System
- Secure login and registration screens
- JWT-ready authentication structure
- Form validation and error handling
- Secure token storage using flutter_secure_storage
- Mock authentication (ready for API integration)

#### 3. Main Home Screen
- 6 feature cards in a grid layout:
  - Navigation
  - Translator
  - QR Scanner
  - AR/VR
  - Feedback
  - Contact Us
- Personalized welcome message
- Quick tips section

#### 4. Custom Bottom Navigation
- 5 navigation items
- **Elevated center QR button** with special styling
- Smooth transitions between screens
- Active state indicators

#### 5. Feature Screens
- **Navigation**: GPS and map integration placeholder
- **Translator**: Language translation interface with multiple language support
- **QR Scanner**: QR code scanning functionality (camera permission ready)
- **AR/VR**: Augmented and Virtual Reality experiences
- **Feedback**: User feedback form with rating system
- **Contact Us**: Complete contact information and social media links

#### 6. Additional Screens
- **Lists**: Saved places, favorites, recent visits
- **Profile**: User profile management and settings
- **Settings**: App preferences and configurations

### 🛠 Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Secure Storage**: flutter_secure_storage
- **HTTP Client**: http package
- **QR Features**: qr_code_scanner, qr_flutter

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for respective platform development)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone or extract the project**
   ```bash
   cd serendib
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Project Structure

```
serendib/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart       # App-wide constants
│   │   └── theme/
│   │       ├── app_colors.dart          # Color palette
│   │       └── app_theme.dart           # Theme configuration
│   ├── models/
│   │   ├── onboarding_question.dart     # Onboarding data models
│   │   └── user.dart                    # User model
│   ├── providers/
│   │   └── auth_provider.dart           # Authentication state management
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── features/
│   │   │   ├── ar_vr_screen.dart
│   │   │   ├── contact_screen.dart
│   │   │   ├── feedback_screen.dart
│   │   │   ├── list_screen.dart
│   │   │   ├── navigation_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── qr_scanner_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── translator_screen.dart
│   │   ├── home/
│   │   │   ├── home_content_screen.dart
│   │   │   └── home_screen.dart         # Main screen with bottom nav
│   │   └── onboarding/
│   │       └── onboarding_screen.dart
│   ├── services/
│   │   └── storage_service.dart         # Local storage management
│   └── main.dart                        # App entry point
├── pubspec.yaml                         # Dependencies
└── README.md
```

## Design System

### Color Palette

#### Primary Colors
- **Primary Brown**: `#6B4423`
- **Dark Brown**: `#4A2C1A`
- **Medium Brown**: `#8B5A3C`
- **Light Brown**: `#A67C52`
- **Very Light Brown**: `#D4A574`

#### Off-White Colors
- **Off White**: `#FAF7F2`
- **Cream White**: `#F5EFE6`
- **Warm White**: `#F0E9DC`
- **Light Cream**: `#E8DCC8`

#### Accent Colors
- **Accent Gold**: `#D4AF37`
- **Soft Gold**: `#E6C77C`

### Typography
- **Display**: Bold, large headings
- **Headline**: Section headers
- **Title**: Card and component titles
- **Body**: Regular content text
- **Label**: Small labels and captions

### Spacing
- **XS**: 4px
- **SM**: 8px
- **MD**: 16px
- **LG**: 24px
- **XL**: 32px
- **XXL**: 48px

### Components

#### Cards
- Rounded corners (16px radius)
- Subtle shadows
- Consistent padding
- Hover/tap feedback

#### Buttons
- **Elevated**: Primary actions (brown background, white text)
- **Outlined**: Secondary actions (brown border and text)
- **Text**: Tertiary actions (brown text only)

#### Input Fields
- Filled background (cream white)
- Rounded borders (12px radius)
- Focus state with primary color
- Clear validation states

## Configuration

### Onboarding Questions
Modify questions in `lib/models/onboarding_question.dart`:
```dart
static List<OnboardingQuestion> getQuestions() {
  // Add or modify questions here
}
```

### API Integration
Update authentication endpoints in `lib/providers/auth_provider.dart`:
```dart
// Replace mock authentication with actual API calls
Future<bool> login(String email, String password) async {
  // Your API integration here
}
```

### Storage Keys
Customize storage keys in `lib/core/constants/app_constants.dart`:
```dart
static const String onboardingKey = 'onboarding_completed';
static const String authTokenKey = 'auth_token';
static const String userDataKey = 'user_data';
```

## Features Ready for Integration

The app includes placeholder screens ready for feature integration:

- **Navigation**: Ready for Google Maps or Mapbox integration
- **Translator**: Ready for translation API (Google Translate, etc.)
- **QR Scanner**: Camera permission handling in place
- **AR/VR**: Structure ready for AR Core/Kit integration
- **Feedback**: Form ready for backend submission
- **Contact**: Links ready for email, phone, and web integration

## Testing

Run tests with:
```bash
flutter test
```

## Platform-Specific Setup

### Android
- Minimum SDK: 21
- Target SDK: 33
- Add permissions in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

### iOS
- Minimum iOS version: 11.0
- Add permissions in `ios/Runner/Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We need camera access for QR scanning</string>
  ```

## Known Limitations

- **Mock Authentication**: Currently uses mock JWT tokens. Integrate with your backend API.
- **QR Scanner**: Requires actual camera implementation
- **AR/VR**: Placeholder only - requires AR Core/Kit integration
- **Translation**: Needs translation API integration
- **Maps**: Navigation screen needs map SDK integration

## Future Enhancements

- [ ] Real API integration for authentication
- [ ] Actual QR code scanning implementation
- [ ] Google Maps / Mapbox integration
- [ ] Translation API integration
- [ ] AR/VR SDK integration
- [ ] Push notifications
- [ ] Offline mode with local database
- [ ] Dark mode support
- [ ] Multilingual support (i18n)
- [ ] Analytics integration
- [ ] Crash reporting

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues or questions, please use the in-app feedback feature or contact:
- Email: support@serendib.lk
- Phone: +94 11 234 5678

## Acknowledgments

- Designed with Flutter and Material Design 3
- Color palette inspired by Sri Lankan earthy tones
- Icons from Material Icons

---

**Built with ❤️ using Flutter**
