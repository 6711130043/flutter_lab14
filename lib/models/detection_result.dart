class DetectionResult {
  final String label;
  final double confidence;
  final BoundingBox bbox;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.bbox,
  });

  @override
  String toString() =>
      'DetectionResult(label: $label, confidence: $confidence, bbox: $bbox)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionResult &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          confidence == other.confidence &&
          bbox == other.bbox;

  @override
  int get hashCode => label.hashCode ^ confidence.hashCode ^ bbox.hashCode;
}

class BoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;

  BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  String toString() =>
      'BoundingBox(left: $left, top: $top, width: $width, height: $height)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoundingBox &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          top == other.top &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode =>
      left.hashCode ^ top.hashCode ^ width.hashCode ^ height.hashCode;
}
