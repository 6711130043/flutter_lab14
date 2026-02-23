# Flutter AI Demo - Setup & Development Guide

## Project Overview

A complete, production-ready Flutter application demonstrating AI/ML concepts across 8 interactive chapters. Built with Riverpod for state management and Material 3 design.

## What's Included

### 1. Complete Project Structure
```
FLUTTER_AI_DEMO/
├── lib/
│   ├── main.dart                          # App entry with ProviderScope
│   ├── models/
│   │   ├── chat_message.dart             # Message data model
│   │   └── detection_result.dart         # Detection data model
│   ├── providers/
│   │   ├── chat_provider.dart            # Chapter 1 state
│   │   ├── ml_provider.dart              # Chapter 2 state
│   │   ├── rag_provider.dart             # Chapter 5 state
│   │   ├── image_gen_provider.dart       # Chapter 6 state
│   │   ├── detection_provider.dart       # Chapter 8 state
│   │   └── theme_provider.dart           # Theme management
│   ├── screens/
│   │   ├── home_screen.dart              # Main navigation hub
│   │   ├── ch1_ai_agent_screen.dart      # AI Chat demo
│   │   ├── ch2_on_device_ml_screen.dart  # ML Classification
│   │   ├── ch3_ml_kit_screen.dart        # ML Kit vision APIs
│   │   ├── ch4_ai_ui_ux_screen.dart      # Generative UI
│   │   ├── ch5_rag_screen.dart           # RAG Q&A system
│   │   ├── ch6_image_gen_screen.dart     # Text-to-Image
│   │   ├── ch7_speech_screen.dart        # STT/TTS
│   │   └── ch8_camera_ar_screen.dart     # Object Detection
│   ├── services/                         # Service layer (ready for extension)
│   └── widgets/                          # Reusable components (ready for expansion)
├── assets/                               # Image & resource directory
├── pubspec.yaml                          # Dependencies configuration
├── analysis_options.yaml                 # Lint rules
├── .gitignore                            # Git ignore patterns
├── README.md                             # User documentation
└── SETUP_GUIDE.md                        # This file
```

### 2. Implemented Features

#### Chapter 1: AI Agent (LLM Chat)
- Real-time message UI with bubbles
- Typing indicator animation
- Message timestamp display
- Simulated AI responses
- Clear chat history
- Uses Riverpod StateNotifier

#### Chapter 2: On-device ML
- Sample image classification buttons
- Confidence percentage visualization
- Bar chart using fl_chart
- Model loading simulation
- Reset functionality

#### Chapter 3: Google ML Kit
- 3-tab interface (OCR, Face, Barcode)
- Placeholder camera view
- Simulated scanning results
- Result card display

#### Chapter 4: AI-powered UI/UX
- Text prompt input
- Dynamic UI generation based on keywords
- Live widget preview
- Generated Dart code display
- Form and grid templates

#### Chapter 5: RAG for Flutter
- Knowledge base document chips
- Q&A query interface
- Document retrieval simulation
- Relevance-based context display
- Combined answer generation

#### Chapter 6: AI Image Generation
- Text-to-image prompt input
- Progress indicator during generation
- Simulated image preview (gradient)
- Generation history gallery
- Timestamp tracking

#### Chapter 7: Speech & Voice AI
- 2-tab interface (STT, TTS)
- Large circular mic button
- Listening animation
- Simulated recognition results
- Waveform animation for TTS

#### Chapter 8: AI Camera & AR
- Simulated camera view with grid
- Object detection visualization
- Animated bounding boxes
- Confidence progress bars
- Detection history with icons

### 3. State Management (Riverpod)

All chapters use clean Riverpod patterns:
- **StateNotifier**: Encapsulates mutable state logic
- **State Providers**: Expose state for UI consumption
- **ProviderScope**: Wraps MaterialApp for Riverpod integration

Example pattern:
```dart
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  void addMessage(String content, String role) {
    // State updates
  }
}

final chatProvider = StateNotifierProvider((ref) => ChatNotifier());
```

### 4. UI/UX Design
- Material 3 with indigo color scheme
- Dark/Light theme support
- Responsive layouts
- Smooth animations
- Thai language throughout
- Consistent spacing and typography

### 5. Dependencies

```yaml
flutter_riverpod: ^2.4.9   # State management
fl_chart: ^0.66.0          # Chart visualization
google_fonts: ^6.1.0       # Font library
flutter_markdown: ^0.6.18  # Markdown support
animated_text_kit: ^4.2.2  # Text animations
lottie: ^3.0.0             # Animation library
url_launcher: ^6.2.2       # URL handling
image_picker: ^1.0.7       # Image selection
path_provider: ^2.1.2      # File system access
```

## Getting Started

### Prerequisites
- Flutter SDK >= 3.2.0
- Dart SDK compatible with Flutter
- IDE: VS Code, Android Studio, or IntelliJ

### Installation Steps

1. **Navigate to project:**
   ```bash
   cd /sessions/nifty-peaceful-feynman/mnt/FLUTTER_AI/FLUTTER_AI_DEMO
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Build for different platforms:**
   ```bash
   # Android APK
   flutter build apk

   # iOS
   flutter build ios

   # Web
   flutter build web
   ```

## Code Quality

### Analysis Configuration
- Includes `flutter_lints` for Dart analysis
- Custom rules configured in `analysis_options.yaml`
- Relaxed const constructor rules for demo flexibility

### Running Analysis
```bash
flutter analyze
```

### Code Style
- Follows Dart conventions
- Proper null safety usage
- Clear separation of concerns
- Reusable components

## Extension Points

The project is structured for easy extension:

### Adding New Screens
1. Create new file in `lib/screens/`
2. Create corresponding provider in `lib/providers/`
3. Add to home screen navigation
4. Update imports in main.dart if needed

### Adding New Models
1. Create model file in `lib/models/`
2. Implement equality and toString
3. Use in providers for type safety

### Creating Custom Widgets
1. Add to `lib/widgets/` directory
2. Keep reusable and isolated
3. Document public APIs

### Integrating Real APIs
1. Create service in `lib/services/`
2. Update providers to use services
3. Handle network errors gracefully
4. Add proper logging

## Testing

To add tests (structure ready):
```bash
flutter test
```

Create test files in `test/` directory following Flutter conventions.

## Performance Considerations

1. **Animation Performance**: Uses AnimatedContainer and Transform for smooth 60fps
2. **Build Optimization**: Separates concerns with StatefulWidget and ConsumerWidget
3. **Memory**: Providers are properly disposed through Riverpod lifecycle
4. **UI Responsiveness**: Async operations use Future.delayed with proper state updates

## Debugging

### Console Logging
```dart
print('Debug message'); // Simple logging
debugPrint('Debug'); // Uses Dart's debug output
```

### Device Logging
```bash
flutter logs
```

### Devtools
```bash
flutter pub global activate devtools
devtools
```

## Common Tasks

### Change Theme Color
1. Edit `lib/main.dart`
2. Modify `colorSchemeSeed: Colors.indigo` to another color
3. Hot reload to see changes

### Add New Chapter
1. Create `lib/screens/ch9_new_screen.dart`
2. Create `lib/providers/new_provider.dart`
3. Add chapter data to `chapters` list in `home_screen.dart`
4. Import screen at top of home_screen.dart

### Modify Thai Text
Search for Thai text strings in screen files and update as needed. All UI text is directly in Dart for easy modification.

## Troubleshooting

### Build Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Hot Reload Not Working
- Try hot restart: `R` key in CLI
- Or rebuild: `flutter run`

### Dependency Conflicts
```bash
flutter pub outdated
flutter pub upgrade
```

## Project Conventions

1. **File Naming**: snake_case for files (ch1_ai_agent_screen.dart)
2. **Class Naming**: PascalCase for classes (AIAgentScreen)
3. **Variable Naming**: camelCase for variables (_isLoading, _controller)
4. **Const Constructors**: Used where possible for performance
5. **Documentation**: Clear widget parameter documentation

## Next Steps

1. Integrate real AI/ML APIs (OpenAI, Google, etc.)
2. Add local data persistence with hive or sqflite
3. Implement real camera and microphone functionality
4. Add unit and widget tests
5. Deploy to App Store/Play Store
6. Add analytics and crash reporting

## Support Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## License

Educational project - modify as needed for learning purposes.

---

**Ready to run!** Execute `flutter run` from the project directory to start the demo app.
