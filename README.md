# 🏛️ Serendib – Smart Artifact Guide

Multilingual, Navigational, and AI-Enhanced Mobile Application for Colombo National Museum

## Project Overview

Serendib is an AI powered smart museum mobile application developed to enhance visitor engagement, accessibility, and personalization at the Colombo National Museum. The system integrates Artificial Intelligence, Machine Learning, Natural Language Processing, Image Processing, and affective computing to address limitations found in traditional museum experiences.

Museums typically rely on static information displays, manual navigation, and generic feedback mechanisms, which fail to adapt to diverse visitor needs. Serendib proposes a unified smart museum ecosystem that delivers interactive artifact exploration, multilingual support, intelligent navigation, personalized recommendations, personalized AI Assistant Chatbot, and emotion aware feedback through a single mobile platform.

## Project Objectives

### Main Objective

To design and develop an AI driven Smart Museum Guide system that enhances visitor experience through personalization, multilingual interaction, intelligent navigation, and emotion based feedback analysis.

### Specific Objectives

- Provide personalized artifact recommendations based on user profiles and interaction history
- Deliver real time multilingual artifact descriptions using museum specific vocabulary
- Enable efficient indoor navigation using a 2D Cartesian coordinate based mapping system
- Capture visitor emotions using facial and vocal cues for passive feedback collection
- Integrate an AI Assistant Chatbot capable of multilingual, emotion aware interaction
- Support inclusive access for diverse visitor demographics, including differently abled users

## Problem Statement

Despite the growing adoption of digital technologies in museums, many visitor experiences remain limited by static information displays, lack of interactivity, and generic content delivery. Museum information is often presented in fixed formats that do not adapt to individual visitor interests or learning styles, while language barriers significantly reduce understanding for both local and international audiences. Additionally, the absence of personalized guidance and intelligent indoor navigation makes it difficult for visitors to efficiently explore large museum spaces. Existing feedback mechanisms rely heavily on manual surveys and explicit user input, which are intrusive, time consuming, and ineffective in capturing visitors’ true emotional responses. As a result, museums lack reliable, real time insights into visitor satisfaction and engagement, limiting their ability to continuously improve services and exhibit design.

## Proposed Solution

To address these challenges, Serendib proposes a unified, AI-powered smart museum ecosystem that integrates personalization, multilingual interaction, intelligent navigation, and emotion aware feedback within a single mobile application. The system incorporates an AI-driven recommendation engine, interactive 2D and 3D artifact visualization, and a personalized AI Assistant Chatbot that serves as a virtual museum guide and primary interaction layer. Indoor navigation is enabled through a 2D Cartesian coordinate based spatial model derived from the museum floor plan, allowing efficient and adaptive route guidance. Visitor emotions are captured using facial and vocal expression recognition to collect passive, real time feedback, which is analyzed to generate actionable insights for museum staff. Together, these components form a scalable and inclusive solution that enhances visitor engagement, reduces accessibility barriers, and supports continuous improvement of museum experiences.

## Design System

- **Color Palette**: Brown and off white tones creating a warm, elegant aesthetic
- **Custom Theme**: Complete Material Design 3 implementation
- **Consistent UI**: Reusable components with standardized spacing and styling
- **Responsive**: Adapts to different screen sizes

## Core Features

### 1. Onboarding Experience
- Interactive questions to personalize user experience
- Shows only on first app launch
- Smooth page transitions and progress tracking
- Beautiful custom option cards

### 2. Authentication System
- Secure login and registration screens
- JWT ready authentication structure
- Form validation and error handling
- Secure token storage using flutter_secure_storage
- Mock authentication (ready for API integration)

### 3. Main Home Screen
- 6 feature cards in a grid layout:
  - Navigation
  - Translator
  - QR Scanner
  - Artifact Visualization
  - Feedback
  - Assistant Chatbot
- Personalized welcome message
- Quick tips section

### 4. Custom Bottom Navigation
- 5 navigation items
- **Elevated center QR button** with special styling
- Smooth transitions between screens
- Active state indicators

### 5. Feature Screens
- **Navigation**: GPS and map integration placeholder
- **Translator**: Language translation interface with multiple language support
- **QR Scanner**: QR code scanning functionality (camera permission ready)
- **Artifact Visualization**: Uses AI inpainting to digitally restore broken/missing artifacts
- **Feedback**: User feedback form with rating system
- **Assistant Chatbot**: Helps via QnA

### 6. Additional Screens
- **Lists**: Saved places, favorites, recent visits
- **Profile**: User profile management and settings
- **Settings**: App preferences and configurations

## Accessibility Support

### Visual Impairment Support

- Screen reader compatible UI
- Audio based content via chatbot and narration
- High contrast and readable interface

### Hearing Impairment Support

- Text based chatbot interaction
- Visual explanations and artifact details
- Non audio dependent navigation cues

### Cognitive and Learning Difficulties Support

- Simple, consistent interface design
- Step by step guidance through chatbot
- Visual learning via artifact visualization

## Technical Stack

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
│   │   │   ├── visualization_screen.dart
│   │   │   ├── chatbot_screen.dart
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
## Expected Outcomes

- Improved visitor engagement and satisfaction
- Reduced language and accessibility barriers
- Personalized museum experiences
- Emotion-driven insights for exhibit improvement
- Data-driven decision support for museum management

## Project Limitations

- Emotion recognition accuracy can vary due to lighting, noise, and cultural differences
- Biometric data usage is limited by privacy and consent requirements
- Performance depends on mobile device hardware capabilities
- Real-time crowd detection for navigation is limited
- Some features require stable internet connectivity

## Future Enhancements

- [ ] Advanced AI-based recommendation refinement
- [ ] Crowd-aware indoor navigation optimization
- [ ] Offline mode for low-connectivity environment
- [ ] Expansion to additional foreign languages
- [ ] Integration with museum analytics dashboards
- [ ] Explainable AI (XAI) for transparent recommendations
- [ ] Dark mode support
- [ ] Deployment across multiple museums

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## Acknowledgments

- Designed with Flutter and Material Design 3
- Color palette inspired by Sri Lankan earthy tones
- Icons from Material Icons
