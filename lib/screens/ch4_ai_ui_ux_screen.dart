import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class UIGenerationResult {
  final String layout;
  final String headline;
  final String primaryAction;
  final String secondaryAction;
  final String rationale;

  const UIGenerationResult({
    required this.layout,
    required this.headline,
    required this.primaryAction,
    required this.secondaryAction,
    required this.rationale,
  });
}

class AIUIUXScreen extends StatefulWidget {
  const AIUIUXScreen({super.key});

  @override
  State<AIUIUXScreen> createState() => _AIUIUXScreenState();
}

class _AIUIUXScreenState extends State<AIUIUXScreen> {
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _promptController = TextEditingController();
  UIGenerationResult? _generatedResult;
  String _generatedSpec = '';
  bool _isGenerating = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateUI() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      if (!_openAIService.isConfigured) {
        setState(() {
          _generatedResult = UIGenerationResult(
            layout: 'form',
            headline: 'ยังไม่ได้ตั้งค่า API Key',
            primaryAction: 'ตั้งค่า OPENAI_API_KEY',
            secondaryAction: 'เพิ่มในไฟล์ .env',
            rationale:
                'ต้องใช้ OpenAI เพื่อสร้าง UI recommendation แบบ dynamic',
          );
          _generatedSpec = '{"error":"missing OPENAI_API_KEY"}';
          _isGenerating = false;
        });
        return;
      }

      final promptSpec = '''
ผู้ใช้ต้องการ UI ตามข้อความนี้: "$prompt"

ให้ตอบเป็น JSON เท่านั้น ด้วย schema นี้:
{
  "layout": "form|cards|dashboard|chat",
  "headline": "short title",
  "primaryAction": "button text",
  "secondaryAction": "button text",
  "rationale": "short thai explanation"
}

ห้ามมีข้อความอื่นนอก JSON
''';

      final jsonText = await _openAIService.createChatCompletion(
        messages: [
          {
            'role': 'system',
            'content': 'You generate strict JSON only.',
          },
          {
            'role': 'user',
            'content': promptSpec,
          },
        ],
        jsonResponse: true,
        temperature: 0.3,
      );

      final result = _parseResult(jsonText);

      setState(() {
        _generatedResult = result;
        _generatedSpec = jsonText;
        _isGenerating = false;
      });
    } catch (error) {
      setState(() {
        _generatedResult = UIGenerationResult(
          layout: 'form',
          headline: 'เกิดข้อผิดพลาด',
          primaryAction: 'ลองใหม่',
          secondaryAction: 'ตรวจสอบอินเทอร์เน็ต',
          rationale: error.toString(),
        );
        _generatedSpec = '{"error":"$error"}';
        _isGenerating = false;
      });
    }
  }

  UIGenerationResult _parseResult(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
      final layout = decoded['layout']?.toString() ?? 'form';
      final headline = decoded['headline']?.toString() ?? 'Generated UI';
      final primaryAction = decoded['primaryAction']?.toString() ?? 'ยืนยัน';
      final secondaryAction =
          decoded['secondaryAction']?.toString() ?? 'ย้อนกลับ';
      final rationale =
          decoded['rationale']?.toString() ?? 'AI suggested this structure';

      return UIGenerationResult(
        layout: layout,
        headline: headline,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        rationale: rationale,
      );
    } catch (_) {
      return const UIGenerationResult(
        layout: 'form',
        headline: 'Generated UI',
        primaryAction: 'ยืนยัน',
        secondaryAction: 'ยกเลิก',
        rationale: 'ไม่สามารถ parse ค่าจาก AI ได้ครบถ้วน',
      );
    }
  }

  Widget _buildGeneratedWidget(UIGenerationResult result) {
    switch (result.layout.toLowerCase()) {
      case 'cards':
        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            4,
            (index) => Card(
              child: Center(child: Text('Card ${index + 1}')),
            ),
          ),
        );
      case 'dashboard':
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _MetricTile(label: 'Users', value: '1,240')),
                const SizedBox(width: 12),
                Expanded(child: _MetricTile(label: 'CTR', value: '4.7%')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MetricTile(label: 'Revenue', value: '฿82k')),
                const SizedBox(width: 12),
                Expanded(child: _MetricTile(label: 'NPS', value: '61')),
              ],
            ),
          ],
        );
      case 'chat':
        return Column(
          children: [
            const _Bubble(
                text: 'สวัสดีครับ ต้องการความช่วยเหลืออะไร?', isUser: false),
            const _Bubble(text: 'ขอ UI ที่เน้น conversion', isUser: true),
            _Bubble(text: result.rationale, isUser: false),
          ],
        );
      case 'form':
      default:
        return Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'ชื่อ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'อีเมล',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-powered UI/UX'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'พิมพ์คำอธิบาย UI',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: 'เช่น สร้างฟอร์มลงทะเบียน...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateUI,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('สร้าง UI'),
              ),
            ),
            const SizedBox(height: 32),
            if (_isGenerating)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text('กำลังสร้าง UI...'),
                  ],
                ),
              )
            else if (_generatedResult != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ตัวอย่าง:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _generatedResult!.headline,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildGeneratedWidget(_generatedResult!),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                child: Text(_generatedResult!.primaryAction),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text(_generatedResult!.secondaryAction),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'เหตุผลจาก AI: ${_generatedResult!.rationale}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'AI Spec (JSON):',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _generatedSpec,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
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
                  'ป้อนข้อความเพื่อสร้าง UI',
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }
}
