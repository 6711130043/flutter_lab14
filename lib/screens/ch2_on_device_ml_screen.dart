import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ml_provider.dart';

class OnDeviceMLScreen extends ConsumerWidget {
  const OnDeviceMLScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mlResult = ref.watch(mlProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('On-device ML'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'เลือกรูปภาพจากเครื่องเพื่อทำ Image Labeling',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: mlResult.isLoading
                    ? null
                    : () => ref.read(mlProvider.notifier).classifyFromGallery(),
                icon: const Icon(Icons.photo_library),
                label: const Text('เลือกรูปภาพ'),
              ),
            ),
            if (mlResult.imageBytes != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  mlResult.imageBytes!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child:
                          const Center(child: Text('ไม่สามารถแสดงรูปภาพได้')),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 40),
            if (mlResult.isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'กำลังวิเคราะห์รูปภาพ...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            else if (mlResult.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'เกิดข้อผิดพลาด: ${mlResult.error}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else if (mlResult.label.isNotEmpty)
              Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'ผลการจำแนก',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            mlResult.label,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const titles = ['ความเชื่อมั่น'];
                                        return Text(titles[value.toInt()]);
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${(value * 100).toStringAsFixed(0)}%',
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: mlResult.confidence,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 60,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ความแม่นยำ:'),
                                Text(
                                  '${(mlResult.confidence * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(mlProvider.notifier).reset();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('ทดสอบอีกครั้ง'),
                  ),
                  if (mlResult.labels.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Top Labels',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...mlResult.labels.map(
                      (label) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.label_outline),
                        title: Text(label.text),
                        trailing: Text(
                            '${(label.confidence * 100).toStringAsFixed(1)}%'),
                      ),
                    ),
                  ],
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kIsWeb
                      ? 'เลือกรูปภาพเพื่อเริ่มการจำแนกด้วย On-device ML'
                      : 'เลือกรูปภาพด้านบนเพื่อเริ่มการจำแนก',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
