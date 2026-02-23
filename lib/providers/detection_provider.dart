import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../models/detection_result.dart';

class DetectionNotifier extends StateNotifier<DetectionState> {
  final ImagePicker _picker = ImagePicker();
  final ObjectDetector _detector = ObjectDetector(
    options: ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.single,
    ),
  );

  DetectionNotifier() : super(const DetectionState());

  Future<({double width, double height})> _decodeImageSize(
      Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return (
      width: frame.image.width.toDouble(),
      height: frame.image.height.toDouble()
    );
  }

  Future<void> detect() async {
    final captured = await _picker.pickImage(source: ImageSource.camera);
    if (captured == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final bytes = await captured.readAsBytes();
      final imageSize = await _decodeImageSize(bytes);
      final inputImage = InputImage.fromFilePath(captured.path);
      final objects = await _detector.processImage(inputImage);

      final results = objects.map((object) {
        final label = object.labels.isNotEmpty
            ? object.labels.first.text
            : 'Unknown Object';
        final confidence =
            object.labels.isNotEmpty ? object.labels.first.confidence : 0.5;
        final bbox = object.boundingBox;

        return DetectionResult(
          label: label,
          confidence: confidence,
          bbox: BoundingBox(
            left: bbox.left,
            top: bbox.top,
            width: bbox.width,
            height: bbox.height,
          ),
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        detectionResults: results,
        imagePath: captured.path,
        imageBytes: bytes,
        imageWidth: imageSize.width,
        imageHeight: imageSize.height,
        lastDetectionTime: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void clearDetections() {
    state = const DetectionState();
  }

  @override
  void dispose() {
    _detector.close();
    super.dispose();
  }
}

class DetectionState {
  final bool isLoading;
  final List<DetectionResult> detectionResults;
  final String? imagePath;
  final Uint8List? imageBytes;
  final double imageWidth;
  final double imageHeight;
  final String? error;
  final DateTime? lastDetectionTime;

  const DetectionState({
    this.isLoading = false,
    this.detectionResults = const [],
    this.imagePath,
    this.imageBytes,
    this.imageWidth = 1,
    this.imageHeight = 1,
    this.error,
    this.lastDetectionTime,
  });

  DetectionState copyWith({
    bool? isLoading,
    List<DetectionResult>? detectionResults,
    String? imagePath,
    Uint8List? imageBytes,
    double? imageWidth,
    double? imageHeight,
    String? error,
    DateTime? lastDetectionTime,
  }) {
    return DetectionState(
      isLoading: isLoading ?? this.isLoading,
      detectionResults: detectionResults ?? this.detectionResults,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      error: error,
      lastDetectionTime: lastDetectionTime ?? this.lastDetectionTime,
    );
  }
}

final detectionProvider =
    StateNotifierProvider<DetectionNotifier, DetectionState>((ref) {
  return DetectionNotifier();
});
