# Setup & Deployment Guide

## 🚀 Getting Started

### Prerequisites Checklist

Before you begin, ensure you have the following installed:

- ✅ **Flutter SDK 3.7.2+** - [Download](https://flutter.dev/docs/get-started/install)
- ✅ **Dart SDK 3.0+** - (Included with Flutter)
- ✅ **Git** - [Download](https://git-scm.com/downloads)

### Platform-Specific Requirements

#### 🤖 Android Development
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (API level 21+)
- **Android Emulator** or physical device with USB debugging enabled

#### 🍎 iOS Development (macOS only)
- **Xcode 14.0+**
- **iOS Simulator** or physical device
- **Apple Developer Account** (for device testing)

#### 🌐 Web Development  
- **Chrome** browser for testing
- No additional setup required

#### 🖥️ Desktop Development
- **Windows**: Visual Studio 2019+ with C++ tools
- **macOS**: Xcode command line tools
- **Linux**: Clang, CMake, GTK development libraries

---

## 💻 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/burkelashell109/Flutter-Hello-World.git
cd Flutter-Hello-World
```

### 2. Verify Flutter Installation
```bash
flutter doctor
```
**Expected Output:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.7.2, on Microsoft Windows)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] Android Studio (version 2022.1)
[✓] VS Code (version 1.75.1)
[✓] Connected device (2 available)
[✓] HTTP Host Availability
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just run on default device
flutter run
```

---

## 🛠️ Development Setup

### IDE Configuration

#### VS Code (Recommended)
1. Install extensions:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)
   - **Flutter Widget Snippets**
   - **Bracket Pair Colorizer 2**

2. Configure settings (`settings.json`):
```json
{
  "dart.flutterSdkPath": "C:/src/flutter",
  "dart.lineLength": 100,
  "editor.rulers": [80, 100],
  "dart.enableSdkFormatter": true,
  "dart.runPubGetOnPubspecChanges": true
}
```

#### Android Studio
1. Install plugins:
   - **Flutter** 
   - **Dart**

2. Configure SDK paths:
   - File → Settings → Languages & Frameworks → Flutter
   - Set Flutter SDK path

### Git Hooks (Optional)
Set up pre-commit hooks for code quality:

```bash
# Create pre-commit hook
echo '#!/bin/sh
flutter analyze
flutter test
' > .git/hooks/pre-commit

chmod +x .git/hooks/pre-commit
```

---

## 🧪 Testing Setup

### Run All Tests
```bash
# Unit and widget tests
flutter test

# Integration tests  
flutter test integration_test/

# With coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Continuous Testing
```bash
# Watch mode (if supported by your Flutter version)
flutter test --watch

# Or use custom file watcher scripts
./watch_tests.sh        # macOS/Linux
./watch_tests.ps1       # Windows PowerShell
```

### Test Scripts
The project includes automated testing scripts:

```bash
# Windows
run_tests.bat

# macOS/Linux  
./run_tests.sh
```

---

## 📱 Platform-Specific Setup

### Android Setup

#### 1. Configure Signing (for release builds)
Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>  
keyAlias=<your-key-alias>
storeFile=<path-to-keystore-file>
```

#### 2. Update App Configuration
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
    android:icon="@mipmap/ic_launcher">
```

#### 3. Build APK
```bash
# Debug build
flutter build apk --debug

# Release build  
flutter build apk --release

# Split APKs by ABI (smaller files)
flutter build apk --split-per-abi
```

### iOS Setup

#### 1. Open iOS Project
```bash
open ios/Runner.xcworkspace
```

#### 2. Configure Signing & Capabilities
- Select "Runner" target
- Update Bundle Identifier
- Select your Development Team
- Configure signing certificates

#### 3. Build IPA
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Web Setup

#### 1. Enable Web Support (if not already enabled)
```bash
flutter config --enable-web
```

#### 2. Build for Web
```bash
# Debug build
flutter build web

# Release build  
flutter build web --release

# With custom base href
flutter build web --base-href "/your-app-path/"
```

#### 3. Serve Locally
```bash
# Using Flutter
flutter run -d chrome

# Using Python
cd build/web
python -m http.server 8000

# Using Node.js
npx serve build/web
```

---

## 🚀 Deployment

### Android Deployment

#### Google Play Store
1. **Build Release APK/AAB:**
```bash
flutter build appbundle --release
```

2. **Upload to Play Console:**
   - Sign in to [Google Play Console](https://play.google.com/console)
   - Create new app or select existing
   - Upload `build/app/outputs/bundle/release/app-release.aab`

3. **Configure Store Listing:**
   - Add screenshots, descriptions, icons
   - Set content rating and pricing
   - Submit for review

#### Firebase App Distribution
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Build and upload
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
    --app YOUR_APP_ID \
    --groups "testers"
```

### iOS Deployment

#### App Store Connect
1. **Build IPA:**
```bash
flutter build ios --release
```

2. **Archive in Xcode:**
   - Product → Archive
   - Upload to App Store Connect

3. **TestFlight/App Store:**
   - Configure in App Store Connect
   - Submit for review

### Web Deployment

#### GitHub Pages
1. **Build for Web:**
```bash
flutter build web --base-href "/Flutter-Hello-World/"
```

2. **Deploy to gh-pages:**
```bash
# Install gh-pages (Node.js required)
npm install -g gh-pages

# Deploy
gh-pages -d build/web
```

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize hosting
firebase init hosting

# Build and deploy
flutter build web
firebase deploy
```

#### Netlify
1. Build locally: `flutter build web`
2. Drag `build/web` folder to [Netlify Deploy](https://app.netlify.com/drop)
3. Or connect GitHub repository for automatic deployment

---

## 🔧 Environment Configuration

### Development
```bash
# Set environment
export FLUTTER_ENV=development

# Run with debug flags
flutter run --debug --dart-define=FLUTTER_ENV=development
```

### Production
```bash
# Set environment  
export FLUTTER_ENV=production

# Build with optimizations
flutter build apk --release --dart-define=FLUTTER_ENV=production
```

### Environment Variables
Create environment-specific config files:

**`lib/config/env_config.dart`:**
```dart
class EnvConfig {
  static const String environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'development',
  );
  
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}
```

---

## 📊 Performance Optimization

### Release Build Optimizations
```bash
# Enable tree shaking and minification
flutter build apk --release --shrink

# Profile performance
flutter build apk --profile
flutter run --profile

# Analyze bundle size
flutter build apk --analyze-size
```

### Web Performance
```bash
# Build with optimizations
flutter build web --release --web-renderer html

# Enable caching
flutter build web --release --pwa-strategy offline-first
```

---

## 🐛 Troubleshooting

### Common Issues

#### "Flutter Doctor" Issues
```bash
# Android license issues
flutter doctor --android-licenses

# iOS setup issues  
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### Build Failures
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

#### Hot Reload Issues
```bash
# Restart with clean state
flutter run --hot --no-fast-start
```

### Performance Issues
- Check `flutter analyze` for optimization warnings
- Use `flutter inspector` to identify widget rebuild issues
- Profile with `flutter run --profile`

### Platform-Specific Issues

#### Android
- Ensure minimum SDK version compatibility
- Check ProGuard rules for release builds
- Verify signing configuration

#### iOS  
- Update Podfile if needed: `cd ios && pod install`
- Check iOS deployment target compatibility
- Verify provisioning profiles

---

## 📈 Monitoring & Analytics

### Crash Reporting
```dart
// Add to pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.9

// Initialize in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}
```

### Performance Monitoring
```dart
// Add Firebase Performance
dependencies:
  firebase_performance: ^0.9.3

// Track custom traces
final trace = FirebasePerformance.instance.newTrace('animation_performance');
trace.start();
// ... animation code ...
trace.stop();
```

---

## 🔐 Security Considerations

### API Keys & Secrets
- Never commit secrets to version control
- Use environment variables or secure storage
- Configure different keys for dev/prod environments

### App Security
- Enable ProGuard/R8 for Android release builds
- Use HTTPS for all network requests
- Validate all user inputs

### Store Compliance
- Follow platform-specific guidelines
- Implement proper privacy policies
- Handle user data according to GDPR/CCPA

---

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io)

### Tools
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Flutter Performance Profiler](https://flutter.dev/docs/perf/flutter-performance-profiling)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub](https://github.com/flutter/flutter)

---

## 🎯 Quick Reference

### Essential Commands
```bash
# Development
flutter run                 # Run on connected device
flutter hot-restart        # Full app restart
flutter logs               # View device logs

# Testing  
flutter test               # Run all tests
flutter test --coverage   # Generate coverage

# Building
flutter build apk         # Android APK
flutter build ios         # iOS app
flutter build web         # Web app

# Maintenance
flutter clean             # Clean build cache
flutter pub upgrade       # Update dependencies
flutter doctor            # Check setup
```

### Project Structure
```
lib/
├── main.dart              # Entry point
├── models/               # Data models
├── controllers/          # Business logic  
├── widgets/              # UI components
├── utils/                # Helper functions
└── config/               # Configuration

test/                     # Tests
docs/                     # Documentation
android/                  # Android platform
ios/                      # iOS platform
web/                      # Web platform
```

---

**Ready to deploy? Follow the platform-specific guides above and your app will be live in no time! 🚀**
