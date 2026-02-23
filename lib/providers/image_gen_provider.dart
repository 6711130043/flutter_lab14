import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/openai_service.dart';

enum ImageGenMode { openAI, pollinations }

class GeneratedImage {
  final String prompt;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final ImageGenMode mode;
  final DateTime timestamp;

  GeneratedImage({
    required this.prompt,
    this.imageUrl,
    this.imageBytes,
    required this.mode,
    required this.timestamp,
  });
}

class ImageGenNotifier extends StateNotifier<ImageGenState> {
  final OpenAIService _openAIService = OpenAIService();

  ImageGenNotifier() : super(const ImageGenState());

  void setMode(ImageGenMode mode) {
    state = state.copyWith(mode: mode);
  }

  Future<void> generateImage(String prompt) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      late final GeneratedImage newImage;

      if (state.mode == ImageGenMode.openAI) {
        final result = await _openAIService.generateImage(prompt: prompt);
        newImage = GeneratedImage(
          prompt: prompt,
          imageUrl: result.imageUrl,
          imageBytes: result.imageBytes,
          mode: ImageGenMode.openAI,
          timestamp: DateTime.now(),
        );
      } else {
        final seed = DateTime.now().millisecondsSinceEpoch % 100000;
        final encodedPrompt = Uri.encodeComponent(prompt);
        final imageUrl =
            'https://image.pollinations.ai/prompt/$encodedPrompt?width=1024&height=1024&seed=$seed&nologo=true';

        newImage = GeneratedImage(
          prompt: prompt,
          imageUrl: imageUrl,
          imageBytes: null,
          mode: ImageGenMode.pollinations,
          timestamp: DateTime.now(),
        );
      }

      state = state.copyWith(
        isLoading: false,
        lastPrompt: prompt,
        generatedImages: [newImage, ...state.generatedImages],
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void clearHistory() {
    state = const ImageGenState();
  }
}

class ImageGenState {
  final bool isLoading;
  final String lastPrompt;
  final List<GeneratedImage> generatedImages;
  final String? error;
  final ImageGenMode mode;

  const ImageGenState({
    this.isLoading = false,
    this.lastPrompt = '',
    this.generatedImages = const [],
    this.error,
    this.mode = ImageGenMode.openAI,
  });

  ImageGenState copyWith({
    bool? isLoading,
    String? lastPrompt,
    List<GeneratedImage>? generatedImages,
    String? error,
    ImageGenMode? mode,
  }) {
    return ImageGenState(
      isLoading: isLoading ?? this.isLoading,
      lastPrompt: lastPrompt ?? this.lastPrompt,
      generatedImages: generatedImages ?? this.generatedImages,
      error: error,
      mode: mode ?? this.mode,
    );
  }
}

final imageGenProvider =
    StateNotifierProvider<ImageGenNotifier, ImageGenState>((ref) {
  return ImageGenNotifier();
});
