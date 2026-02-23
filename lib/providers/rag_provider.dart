import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/openai_service.dart';

class RAGResult {
  final String query;
  final String answer;
  final List<String> retrievedDocs;
  final bool isLoading;

  RAGResult({
    required this.query,
    required this.answer,
    required this.retrievedDocs,
    required this.isLoading,
  });

  RAGResult copyWith({
    String? query,
    String? answer,
    List<String>? retrievedDocs,
    bool? isLoading,
  }) {
    return RAGResult(
      query: query ?? this.query,
      answer: answer ?? this.answer,
      retrievedDocs: retrievedDocs ?? this.retrievedDocs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RAGNotifier extends StateNotifier<RAGResult> {
  RAGNotifier()
      : super(RAGResult(
          query: '',
          answer: '',
          retrievedDocs: [],
          isLoading: false,
        ));

  final List<String> documents = [
    'Flutter คือเฟรมเวิร์กจาก Google สำหรับสร้างแอปข้ามแพลตฟอร์มด้วยโค้ดเดียว',
    'Dart เป็นภาษาโปรแกรมหลักของ Flutter และรองรับ async/await',
    'State management ยอดนิยมใน Flutter ได้แก่ Riverpod, Provider, BLoC',
    'Widget ใน Flutter แบ่งเป็น StatelessWidget และ StatefulWidget',
    'BuildContext ใช้สำหรับเข้าถึงตำแหน่งของ widget ใน tree และ inherited data',
    'Hot Reload ช่วยให้เห็นผลการแก้โค้ดทันทีโดยไม่รีสตาร์ททั้งแอป',
    'pubspec.yaml ใช้ประกาศ dependencies, assets และ metadata ของแอป',
    'Navigator และ GoRouter ใช้สำหรับการจัดการเส้นทางและหน้าจอในแอป',
  ];

  final OpenAIService _openAIService = OpenAIService();

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ก-๙\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  List<String> _retrieveDocs(String query, {int topK = 3}) {
    final queryTokens = _tokenize(query).toSet();
    if (queryTokens.isEmpty) return documents.take(topK).toList();

    final scored = documents.map((doc) {
      final docTokens = _tokenize(doc).toSet();
      final overlap = queryTokens.intersection(docTokens).length;
      final union = queryTokens.union(docTokens).length;
      final score = union == 0 ? 0.0 : overlap / union;
      return (doc, score);
    }).toList();

    scored.sort((a, b) => b.$2.compareTo(a.$2));
    final retrieved = scored
        .where((entry) => entry.$2 > 0)
        .take(topK)
        .map((entry) => entry.$1)
        .toList();

    if (retrieved.isEmpty) {
      return documents.take(topK).toList();
    }
    return retrieved;
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, query: query);
    final retrieved = _retrieveDocs(query);

    try {
      if (!_openAIService.isConfigured) {
        final fallbackAnswer =
            'สรุปจากเอกสารที่ค้นได้: ${retrieved.join(' | ')}\n\nคำตอบเบื้องต้น: "$query" เกี่ยวข้องกับหัวข้อด้านบน';
        state = RAGResult(
          query: query,
          answer: fallbackAnswer,
          retrievedDocs: retrieved,
          isLoading: false,
        );
        return;
      }

      final contextText = retrieved
          .asMap()
          .entries
          .map((entry) => '[เอกสาร ${entry.key + 1}] ${entry.value}')
          .join('\n');

      final prompt = '''
คุณคือผู้ช่วยสอน Flutter ภาษาไทย
ตอบคำถามโดยยึดข้อมูลจากบริบทที่ให้เป็นหลัก

บริบท:
$contextText

คำถาม: $query

ข้อกำหนด:
- ตอบภาษาไทย
- กระชับ เข้าใจง่าย
- ถ้าบริบทไม่พอ ให้บอกว่าข้อมูลไม่พอและแนะนำสิ่งที่ควรค้นเพิ่ม
''';

      final answer = await _openAIService.createChatCompletion(
        messages: [
          {
            'role': 'system',
            'content':
                'คุณคือผู้ช่วยสอน Flutter ภาษาไทยที่ตอบจากบริบทที่ได้รับเท่านั้น',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.3,
      );

      state = RAGResult(
        query: query,
        answer: answer,
        retrievedDocs: retrieved,
        isLoading: false,
      );
    } catch (error) {
      state = RAGResult(
        query: query,
        answer: 'เกิดข้อผิดพลาดระหว่างสร้างคำตอบ: $error',
        retrievedDocs: retrieved,
        isLoading: false,
      );
    }
  }

  void clearSearch() {
    state = RAGResult(
      query: '',
      answer: '',
      retrievedDocs: [],
      isLoading: false,
    );
  }
}

final ragProvider = StateNotifierProvider<RAGNotifier, RAGResult>((ref) {
  return RAGNotifier();
});

final documentsProvider = Provider<List<String>>((ref) {
  return ref.watch(ragProvider).retrievedDocs.isNotEmpty
      ? ref.watch(ragProvider).retrievedDocs
      : [];
});
