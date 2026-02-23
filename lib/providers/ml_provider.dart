import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class MLLabel {
  final String text;
  final double confidence;

  const MLLabel({required this.text, required this.confidence});
}

class MLResult {
  final String label;
  final double confidence;
  final bool isLoading;
  final List<MLLabel> labels;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? error;

  MLResult({
    required this.label,
    required this.confidence,
    required this.isLoading,
    this.labels = const [],
    this.imagePath,
    this.imageBytes,
    this.error,
  });

  MLResult copyWith({
    String? label,
    double? confidence,
    bool? isLoading,
    List<MLLabel>? labels,
    String? imagePath,
    Uint8List? imageBytes,
    String? error,
  }) {
    return MLResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      isLoading: isLoading ?? this.isLoading,
      labels: labels ?? this.labels,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      error: error,
    );
  }
}

class MLNotifier extends StateNotifier<MLResult> {
  final ImagePicker _picker = ImagePicker();
  final ImageLabeler _imageLabeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  MLNotifier() : super(MLResult(label: '', confidence: 0.0, isLoading: false));

  Future<void> classifyFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final imageBytes = await picked.readAsBytes();
      final inputImage = InputImage.fromFilePath(picked.path);
      final labels = await _imageLabeler.processImage(inputImage);

      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      if (labels.isEmpty) {
        state = MLResult(
          label: 'ไม่พบวัตถุที่ชัดเจน',
          confidence: 0,
          isLoading: false,
          labels: const [],
          imagePath: picked.path,
          imageBytes: imageBytes,
        );
        return;
      }

      final mappedLabels = labels
          .take(5)
          .map((label) =>
              MLLabel(text: label.label, confidence: label.confidence))
          .toList();

      state = MLResult(
        label: mappedLabels.first.text,
        confidence: mappedLabels.first.confidence,
        isLoading: false,
        labels: mappedLabels,
        imagePath: picked.path,
        imageBytes: imageBytes,
      );
    } catch (error) {
      state = MLResult(
        label: '',
        confidence: 0,
        isLoading: false,
        labels: const [],
        imagePath: picked.path,
        imageBytes: null,
        error: error.toString(),
      );
    }
  }

  void reset() {
    state = MLResult(
        label: '', confidence: 0.0, isLoading: false, labels: const []);
  }

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }
}

final mlProvider = StateNotifierProvider<MLNotifier, MLResult>((ref) {
  return MLNotifier();
});
