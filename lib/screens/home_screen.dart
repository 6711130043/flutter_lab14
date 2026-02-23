import 'package:flutter/material.dart';
import 'ch1_ai_agent_screen.dart';
import 'ch2_on_device_ml_screen.dart';
import 'ch3_ml_kit_screen.dart';
import 'ch4_ai_ui_ux_screen.dart';
import 'ch5_rag_screen.dart';
import 'ch6_image_gen_screen.dart';
import 'ch7_speech_screen.dart';
import 'ch8_camera_ar_screen.dart';

class Chapter {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> tags;
  final Widget Function() screenBuilder;

  Chapter({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tags,
    required this.screenBuilder,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chapters = [
      Chapter(
        number: '1',
        title: 'AI Agent (LLM Chat)',
        subtitle: 'แชทกับตัวช่วย AI',
        icon: Icons.smart_toy,
        tags: ['LLM', 'Chat', 'Conversation'],
        screenBuilder: () => const AIAgentScreen(),
      ),
      Chapter(
        number: '2',
        title: 'On-device ML',
        subtitle: 'การเรียนรู้บนอุปกรณ์',
        icon: Icons.phone_android,
        tags: ['Classification', 'Model', 'Inference'],
        screenBuilder: () => const OnDeviceMLScreen(),
      ),
      Chapter(
        number: '3',
        title: 'Google ML Kit',
        subtitle: 'เครื่องมือ ML ของ Google',
        icon: Icons.visibility,
        tags: ['Vision', 'Text', 'Barcode'],
        screenBuilder: () => const MLKitScreen(),
      ),
      Chapter(
        number: '4',
        title: 'AI-powered UI/UX',
        subtitle: 'สร้าง UI ด้วย AI',
        icon: Icons.palette,
        tags: ['Generative', 'UI', 'Design'],
        screenBuilder: () => const AIUIUXScreen(),
      ),
      Chapter(
        number: '5',
        title: 'RAG for Flutter',
        subtitle: 'ตอบคำถามจากเอกสาร',
        icon: Icons.library_books,
        tags: ['RAG', 'Q&A', 'Knowledge'],
        screenBuilder: () => const RAGScreen(),
      ),
      Chapter(
        number: '6',
        title: 'AI Image Generation',
        subtitle: 'สร้างรูปภาพด้วย AI',
        icon: Icons.image,
        tags: ['Text-to-Image', 'Generation'],
        screenBuilder: () => const ImageGenScreen(),
      ),
      Chapter(
        number: '7',
        title: 'Speech & Voice AI',
        subtitle: 'เสียง และ Text-to-Speech',
        icon: Icons.mic,
        tags: ['STT', 'TTS', 'Voice'],
        screenBuilder: () => const SpeechScreen(),
      ),
      Chapter(
        number: '8',
        title: 'AI Camera & AR',
        subtitle: 'ตรวจจับวัตถุและ AR',
        icon: Icons.camera_alt,
        tags: ['Detection', 'AR', 'Camera'],
        screenBuilder: () => const CameraARScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter AI Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.95,
        ),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ChapterCard(
            chapter: chapter,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => chapter.screenBuilder()),
              );
            },
          );
        },
      ),
    );
  }
}

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: Text(
                          chapter.number,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ),
                    Icon(
                      chapter.icon,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  chapter.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  chapter.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: chapter.tags
                      .take(2)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
