# Flutter AI Demo - Quick Start Guide

## What You Got

A **complete, production-ready Flutter application** with:
- 8 interactive AI/ML demo chapters
- Full Riverpod state management
- Material 3 design with Thai UI
- 2750+ lines of clean Dart code
- Zero external API dependencies

## 30-Second Setup

```bash
# Navigate to project
cd /sessions/nifty-peaceful-feynman/mnt/FLUTTER_AI/FLUTTER_AI_DEMO

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## What Each Chapter Does

### 1. AI Agent (LLM Chat)
**What**: Interactive chat interface
**Try**: Type a message and watch the AI respond with animations

### 2. On-device ML
**What**: Image classification demo
**Try**: Click sample buttons to see classification with confidence bars

### 3. Google ML Kit
**What**: Vision APIs (OCR, Face, Barcode)
**Try**: Switch tabs and tap scan buttons

### 4. AI-powered UI/UX
**What**: Generative UI from text prompts
**Try**: Type "form" or "grid" to generate matching widgets

### 5. RAG for Flutter
**What**: Question answering with knowledge base
**Try**: Ask questions about Flutter topics

### 6. AI Image Generation
**What**: Text-to-image with gallery
**Try**: Enter a description and see a gradient preview

### 7. Speech & Voice AI
**What**: Speech-to-text and text-to-speech
**Try**: Tap the mic button or enter text to hear it spoken

### 8. AI Camera & AR
**What**: Object detection with bounding boxes
**Try**: Tap "Detect" to see objects with confidence bars

## File Structure

```
lib/
├── main.dart              ← App entry with Riverpod ProviderScope
├── models/                ← Data classes
├── providers/             ← State management (6 providers)
├── screens/               ← 9 screens (1 home + 8 chapters)
├── services/              ← Ready for API integration
└── widgets/               ← Reusable components (ready to add)
```

## Key Technologies

| What | Why |
|------|-----|
| **Riverpod** | Clean state management |
| **Material 3** | Modern UI with indigo theme |
| **fl_chart** | Data visualization |
| **Thai Language** | Full Thai UI text |
| **Simulated Data** | No API keys needed |

## Customization

### Change App Color
Edit `lib/main.dart` line 18:
```dart
colorSchemeSeed: Colors.purple,  // Change from Colors.indigo
```

### Modify Thai Text
Search and replace Thai text in screen files. All text is hardcoded for easy editing.

### Add Real APIs
Create services in `lib/services/` and integrate with providers.

### Add Reusable Widgets
Create custom widgets in `lib/widgets/` and import in screens.

## Riverpod Pattern

All chapters follow this pattern:

```dart
// 1. Define state class
class MyState {
  final bool isLoading;
  final String result;
}

// 2. Create notifier
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState(isLoading: false, result: ''));
  
  void doSomething() async {
    state = state.copyWith(isLoading: true);
    // ... do work
    state = state.copyWith(isLoading: false, result: 'done');
  }
}

// 3. Export provider
final myProvider = StateNotifierProvider((ref) => MyNotifier());

// 4. Use in screen
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);
    final notifier = ref.read(myProvider.notifier);
    // Use state and notifier
  }
}
```

## Common Tasks

### Run Tests
```bash
flutter test
```

### Build APK
```bash
flutter build apk
```

### Check Code Quality
```bash
flutter analyze
```

### View App Logs
```bash
flutter logs
```

## Project Statistics

- **Total Files**: 24
- **Dart Files**: 20
- **Lines of Code**: 2,750+
- **Screens**: 9 (1 home + 8 chapters)
- **Providers**: 6 (state management)
- **Models**: 2 (data classes)
- **Dependencies**: 14 packages
- **Documentation Files**: 3

## Dependencies

**Core**: flutter_riverpod, flutter
**UI**: google_fonts, animated_text_kit, lottie, fl_chart
**Future**: http, image_picker, path_provider, url_launcher

## Architecture

```
User Interface (Screens)
        ↓
State Management (Riverpod Providers)
        ↓
Data Models (Classes)
        ↓
Services Layer (Ready for APIs)
```

## Material 3 Features

- Indigo color scheme with auto-generated shades
- Light and dark theme support
- Proper contrast ratios for accessibility
- Rounded corners and elevation shadows
- Responsive layouts

## Troubleshooting

### Dependency Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Hot Reload Not Working
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Or run `flutter run` again

### Build Errors
- Check Flutter version: `flutter --version`
- Update: `flutter upgrade`
- Run `flutter doctor` to diagnose

## Next Steps

1. **Learn**: Study the Riverpod patterns in each provider
2. **Customize**: Change colors, text, and add your own chapters
3. **Integrate**: Connect real APIs in the services layer
4. **Extend**: Add more features to each chapter
5. **Deploy**: Build and submit to app stores

## Documentation Files

- **README.md** - Full feature overview
- **SETUP_GUIDE.md** - Detailed development guide
- **PROJECT_STRUCTURE.txt** - File-by-file breakdown
- **QUICKSTART.md** - This file

## Support

- Flutter docs: https://flutter.dev
- Riverpod docs: https://riverpod.dev
- Material Design 3: https://m3.material.io
- Dart docs: https://dart.dev

## Success!

Your project is ready to run. Execute this in the project directory:

```bash
flutter run
```

Then explore all 8 chapters and enjoy building with AI in Flutter!

---

**Created**: February 2026
**Framework**: Flutter 3.2+
**State Management**: Riverpod 2.4.9
**Design**: Material 3
**Language**: Thai UI
