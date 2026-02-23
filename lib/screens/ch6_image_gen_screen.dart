import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/image_gen_provider.dart';

class ImageGenScreen extends ConsumerStatefulWidget {
  const ImageGenScreen({super.key});

  @override
  ConsumerState<ImageGenScreen> createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends ConsumerState<ImageGenScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _generate() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    ref.read(imageGenProvider.notifier).generateImage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final imageGenState = ref.watch(imageGenProvider);
    final notifier = ref.read(imageGenProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Generation'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              notifier.clearHistory();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'พิมพ์คำอธิบายรูปภาพ',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ImageGenMode>(
              segments: const [
                ButtonSegment(
                  value: ImageGenMode.openAI,
                  label: Text('OpenAI'),
                ),
                ButtonSegment(
                  value: ImageGenMode.pollinations,
                  label: Text('Pollinations'),
                ),
              ],
              selected: {imageGenState.mode},
              onSelectionChanged: imageGenState.isLoading
                  ? null
                  : (selection) {
                      ref
                          .read(imageGenProvider.notifier)
                          .setMode(selection.first);
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'เช่น สัสยาสวรรค์สีม่วง...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              onSubmitted: (_) => _generate(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: imageGenState.isLoading ? null : _generate,
                icon: const Icon(Icons.generating_tokens),
                label: const Text('สร้างรูปภาพ'),
              ),
            ),
            if (imageGenState.error != null) ...[
              const SizedBox(height: 12),
              Text(
                'เกิดข้อผิดพลาด: ${imageGenState.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 32),
            if (imageGenState.isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text('กำลังสร้างรูปภาพ...'),
                  ],
                ),
              )
            else if (imageGenState.lastPrompt.isNotEmpty &&
                !imageGenState.isLoading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รูปภาพที่สร้างสำเร็จ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    imageGenState.generatedImages.first.mode ==
                            ImageGenMode.openAI
                        ? 'Source: OpenAI'
                        : 'Source: Pollinations',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _ImagePreview(
                          image: imageGenState.generatedImages.first),
                    ),
                  ),
                ],
              ),
            if (imageGenState.generatedImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'ประวัติการสร้าง',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: imageGenState.generatedImages.length,
                    itemBuilder: (context, index) {
                      final image = imageGenState.generatedImages[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _ImagePreview(image: image),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  color: Colors.black.withValues(alpha: 0.35),
                                  child: Text(
                                    image.prompt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
}

class _ImagePreview extends StatelessWidget {
  final GeneratedImage image;

  const _ImagePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.imageBytes != null) {
      return Image.memory(image.imageBytes!, fit: BoxFit.cover);
    }

    if (image.imageUrl != null && image.imageUrl!.isNotEmpty) {
      return Image.network(
        image.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const Icon(Icons.image_not_supported),
    );
  }
}
