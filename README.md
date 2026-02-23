# Flutter AI Demo

A comprehensive Flutter teaching application demonstrating AI/ML concepts with interactive demos for 8 different chapters.

## Features

- **Chapter 1: AI Agent (LLM Chat)** - Interactive chat interface with simulated AI responses
- **Chapter 2: On-device ML** - Image classification demo with confidence visualization
- **Chapter 3: Google ML Kit** - Vision APIs including text recognition, face detection, and barcode scanning
- **Chapter 4: AI-powered UI/UX** - Generative UI that creates widgets from text prompts
- **Chapter 5: RAG for Flutter** - Question answering system with knowledge base retrieval
- **Chapter 6: AI Image Generation** - Text-to-image generation with history gallery
- **Chapter 7: Speech & Voice AI** - Speech-to-text and text-to-speech demos
- **Chapter 8: AI Camera & AR** - Object detection with bounding box visualization

## Tech Stack

- **Framework**: Flutter 3.2+
- **State Management**: Riverpod 2.4.9
- **UI Components**: Material 3 design
- **Language**: Thai language UI

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK compatible with Flutter version

### Installation

1. Navigate to the project directory:
```bash
cd /sessions/nifty-peaceful-feynman/mnt/FLUTTER_AI/FLUTTER_AI_DEMO
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── chat_message.dart    # Chat message model
│   └── detection_result.dart # Detection result model
├── providers/
│   ├── chat_provider.dart       # Chat state management
│   ├── ml_provider.dart         # ML classification state
│   ├── rag_provider.dart        # RAG Q&A state
│   ├── image_gen_provider.dart  # Image generation state
│   ├── detection_provider.dart  # Object detection state
│   └── theme_provider.dart      # Theme state
├── screens/
│   ├── home_screen.dart         # Main navigation
│   ├── ch1_ai_agent_screen.dart
│   ├── ch2_on_device_ml_screen.dart
│   ├── ch3_ml_kit_screen.dart
│   ├── ch4_ai_ui_ux_screen.dart
│   ├── ch5_rag_screen.dart
│   ├── ch6_image_gen_screen.dart
│   ├── ch7_speech_screen.dart
│   └── ch8_camera_ar_screen.dart
└── widgets/
    └── (shared UI components)
```

## Key Features

### Riverpod State Management
Each chapter uses Riverpod's StateNotifier pattern for clean, reactive state management:
- Chat messages and responses
- ML classification results
- RAG search results
- Generated images
- Object detections

### Thai Language Support
All UI text is in Thai language with proper Material 3 theming.

### Interactive Demos
All 8 chapters feature fully interactive demos that simulate real AI/ML operations with:
- Loading states
- Animated transitions
- Result visualization
- History tracking

### Material 3 Design
Modern Material 3 design with:
- Indigo color scheme
- Dark/Light theme support
- Responsive layouts
- Smooth animations

## Usage

1. **Home Screen**: Browse all 8 chapters with visual cards
2. **Chapter Selection**: Tap any chapter card to enter the demo
3. **Interactive Demos**: Each chapter allows you to:
   - Input prompts/queries
   - Trigger AI operations
   - View simulated results
   - Manage history/cache

## Notes

- All AI/ML operations are simulated for demo purposes
- No external API keys or credentials required
- All data is local to the app session
- Demos reset when returning to home screen

## Build for Production

### Android
```bash
flutter build apk
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## License

This project is for educational purposes.

## Support

For issues or questions about the app structure or Flutter implementation, refer to the official Flutter documentation at https://flutter.dev.
