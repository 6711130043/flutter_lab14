import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/detection_provider.dart';

class CameraARScreen extends ConsumerWidget {
  const CameraARScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectionState = ref.watch(detectionProvider);
    final notifier = ref.read(detectionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Camera & AR'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              notifier.clearDetections();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'กล้อง AI (ถ่ายภาพและตรวจจับวัตถุจริง)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final displayWidth = constraints.maxWidth;
                    final displayHeight = constraints.maxHeight;

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: detectionState.imageBytes == null
                              ? Container(
                                  color: Colors.black,
                                  child: const Center(
                                    child: Text(
                                      'ยังไม่มีภาพ\nกดปุ่มเพื่อตรวจจับ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              : Image.memory(
                                  detectionState.imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        if (detectionState.detectionResults.isNotEmpty)
                          ..._buildDetectionBoxes(
                            detectionState.detectionResults,
                            displayWidth,
                            displayHeight,
                            detectionState.imageWidth,
                            detectionState.imageHeight,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (detectionState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Error: ${detectionState.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: detectionState.isLoading
                  ? ElevatedButton.icon(
                      onPressed: null,
                      icon: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      label: const Text('กำลังตรวจจับ...'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        notifier.detect();
                      },
                      icon: const Icon(Icons.camera),
                      label: const Text('ถ่ายภาพและตรวจจับวัตถุ'),
                    ),
            ),
            const SizedBox(height: 32),
            if (detectionState.detectionResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ผลการตรวจจับ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ...detectionState.detectionResults.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final result = entry.value;

                      return _DetectionResultCard(
                        label: result.label,
                        confidence: result.confidence,
                        index: index,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetectionBoxes(
    List detections,
    double displayWidth,
    double displayHeight,
    double sourceWidth,
    double sourceHeight,
  ) {
    final scaleX = sourceWidth == 0 ? 1.0 : displayWidth / sourceWidth;
    final scaleY = sourceHeight == 0 ? 1.0 : displayHeight / sourceHeight;

    return detections.asMap().entries.map((entry) {
      final detection = entry.value;
      final index = entry.key;

      return Positioned(
        left: detection.bbox.left * scaleX,
        top: detection.bbox.top * scaleY,
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: Container(
            width: detection.bbox.width * scaleX,
            height: detection.bbox.height * scaleY,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${detection.label} ${(detection.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _DetectionResultCard extends StatelessWidget {
  final String label;
  final double confidence;
  final int index;

  const _DetectionResultCard({
    required this.label,
    required this.confidence,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(confidence * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
