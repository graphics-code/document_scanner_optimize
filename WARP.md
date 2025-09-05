# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Document Scanner** (`doc_scanner`) is a Flutter mobile application that provides comprehensive document scanning capabilities. The app supports multiple scanning modes including document scanning, ID card scanning, QR code reading, and barcode reading. It uses Firebase for crashlytics and messaging, Google Mobile Ads for monetization, and includes features like PDF generation, image editing, and multi-language support.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK for Android
flutter build apk

# Build app bundle for Android (recommended for Play Store)
flutter build appbundle

# Build for iOS
flutter build ios

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Generate localizations
flutter gen-l10n

# Clean build artifacts
flutter clean

# Build with 16KB page size support
flutter build appbundle --release
```

### Platform-Specific Commands
```bash
# Get dependencies for local package
cd package/merge_image && flutter pub get && cd ../..

# Run with specific flavor or environment
flutter run --dart-define=ENV=dev

# Skip Android build dependency validation (if needed)
flutter build apk --android-skip-build-dependency-validation

# Test on 16KB page size devices
flutter run --enable-impeller --android-project-args="--16kb-pages"
```

## 16KB Page Size Support

This project has been configured for **Android 16KB page size support** as required by Google Play Store (mandatory from Nov 1, 2025).

### Key Configurations:

**Android Gradle Plugin**: Updated to 8.6.0+
**Kotlin**: Updated to 2.1.0+
**Target SDK**: 36 (Android 15+)
**NDK**: 26.1.10909125 with flexible page size support

### Configuration Files:
- `android/settings.gradle`: Updated AGP and Kotlin versions
- `android/gradle.properties`: 16KB-specific properties
- `android/app/build.gradle`: CMake arguments for flexible page sizes
- `AndroidManifest.xml`: Native library optimization properties

## Architecture Overview

### Core Architecture Patterns

**Provider Pattern**: The app uses the Provider package for state management with three main providers:
- `CameraProvider`: Manages camera operations, image capture, PDF creation, and QR/barcode processing
- `HomePageProvider`: Handles file management, directory operations, and document organization  
- `ImageEditProvider`: Manages image editing history with undo/redo functionality

**Module Organization**: The codebase is organized into feature-based modules:
- `camera_screen/`: Document/ID scanning, QR/barcode reading
- `home_page/`: File management and navigation
- `image_edit/`: Image processing and editing tools
- `settings_page/`: App configuration and preferences
- `utils/`: Shared utilities and helpers

### Key Integrations

**Firebase Services**:
- Firebase Core for initialization
- Firebase Crashlytics for error reporting (currently commented out)
- Firebase Messaging for push notifications
- Local notifications via `flutter_local_notifications`

**File System Architecture**:
The app creates a structured directory hierarchy in the app's documents folder:
```
/Doc Scanner/
  ├── Document/     # Scanned documents and PDFs
  ├── ID Card/      # ID card scans
  ├── QR Code/      # QR code scan results (text files)
  └── Bar Code/     # Barcode scan results (text files)
```

**Custom Package**: 
- `merge_image` package located in `package/merge_image/` for image merging operations

### Critical Dependencies for 16KB Support

**Native Plugins Verified for 16KB Compatibility**:
- `mobile_scanner` 7.0.1: ✅ Compatible
- `cunning_document_scanner` 1.3.1: ✅ Compatible
- `google_mlkit_text_recognition` 0.15.0: ✅ Compatible
- `image_editor` 1.6.0: ✅ Compatible
- `google_mobile_ads` 5.3.1: ✅ Compatible

### State Management Flow

1. **Image Capture Flow**: Camera → `CameraProvider` → `ImageModel` → Processing → Storage
2. **File Management**: Storage → `HomePageProvider` → UI Lists → User Actions
3. **Image Editing**: Original Image → `ImageEditProvider` (History) → Edited Image → Save

### Permission Handling

The app implements comprehensive permission handling in `AppHelper.handlePermissions()`:
- Camera permissions for document scanning
- Storage/Photos permissions (API level dependent)
- Gallery permissions with Android 13+ compatibility
- Automatic permission settings navigation for denied permissions

## Development Guidelines

### Working with Images
- All images are processed as `Uint8List` for memory efficiency
- `ImageModel` class encapsulates image data with metadata
- Use `AppHelper.convertUint8ListToFile()` for file conversions
- Image compression is handled via `flutter_image_compress`

### PDF Generation
- PDF creation uses the `pdf` package with A4 format
- Multiple images are combined into single PDF documents
- Duplicate file name handling with automatic numbering
- Platform-specific external storage (Android) vs. app documents (iOS)

### Internationalization
- Localization files are generated in `lib/l10n/`
- Support for 12 languages including Arabic, Bengali, English, Spanish, French, Hindi, Indonesian, Japanese, Korean, Russian, and Chinese
- Use `flutter gen-l10n` after modifying ARB files

### Testing
- Widget tests are located in `test/widget_test.dart`
- Run `flutter test` for unit and widget testing
- Use device-specific testing with `flutter run -d <device_id>`
- Test on 16KB page size environments when possible

### Asset Management
- Icons: `assets/icons/`
- Images: `assets/png/` (includes app_icon.png for launcher)
- Audio: `assets/audio/`
- App icon generation via `flutter_launcher_icons` package

## Firebase Configuration

The app uses Firebase with platform-specific configuration:
- `firebase_options.dart` contains auto-generated configuration
- Push notifications are initialized with a 5-second delay
- Notification handling supports foreground, background, and terminated app states
- FCM token logging is enabled for debugging

## Build Considerations

### Android
- Minimum SDK: 21
- Compile SDK: 36 (Android 15+)
- Target SDK: 36
- Build tools: 34.0.0
- NDK: 26.1.10909125
- **16KB page size support**: Enabled via CMake arguments and manifest properties
- Supports both APK and App Bundle builds

### 16KB Page Size Compliance Checklist
- ✅ Android Gradle Plugin 8.6.0+
- ✅ Kotlin 2.1.0+
- ✅ NDK 26.1+ with flexible page size support
- ✅ Target SDK 36 (Android 15+)
- ✅ Native libraries configured for 16KB alignment
- ✅ All native plugins verified for compatibility
- ✅ Manifest properties for uncompressed native libs

### Dependencies
- Core Flutter SDK: 3.35.2+
- Key packages: provider, mobile_scanner, firebase_core, google_mobile_ads, pdf, image processing packages
- Development packages: flutter_lints, flutter_test

## Debugging Tips

- Use `flutter analyze` to catch static analysis issues
- Firebase messaging setup includes comprehensive error handling
- Image processing operations include try-catch blocks with user feedback
- Provider pattern allows for easy state debugging with notifyListeners()
- For 16KB page size issues: Use `--android-skip-build-dependency-validation` flag during development

## Project-Specific Notes

- The app name is "Document Scanner - PDF Scanner" but package name is `doc_scanner`
- Version format follows semantic versioning with build numbers (e.g., 2.0.1+21)
- Google Mobile Ads integration with banner and interstitial ad support
- Local package `merge_image` requires separate dependency management
- Portrait-only orientation is enforced in the app
- **Google Play Store Ready**: Project configured for 16KB page size requirement (Nov 1, 2025 deadline)

## Troubleshooting Common Issues

### 16KB Page Size Related
- If build fails with deprecated properties: Update AGP to 8.6.0+
- If manifest merge fails: Check for proper placeholder substitution
- If native library issues: Verify NDK version and CMake arguments

### General Build Issues
- Clean build: `flutter clean` followed by `flutter pub get`
- Gradle sync issues: Delete `android/.gradle` and rebuild
- Version conflicts: Use `flutter pub deps` to check dependency tree
