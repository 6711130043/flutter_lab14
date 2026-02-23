import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiService _geminiService = GeminiService();

  ChatNotifier() : super(ChatState(messages: [])) {
    _addInitialMessage();
  }

  void _addInitialMessage() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          role: 'assistant',
          content: _geminiService.isConfigured
              ? 'เมี๊ยว~ สวัสดีจ้า! ฉันเป็นแมว AI ร่าเริง ยินดีช่วยและเล่นด้วยนะ~ อยากให้ช่วยอะไรบอกมาได้เลยจ้า 🐾'
              : 'ยังไม่ได้ตั้งค่า GEMINI_API_KEY ในไฟล์ .env',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> addMessage(String content, String role) async {
    // Add user message
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          role: role,
          content: content,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: true,
    );

    if (role == 'user') {
      await _getAIResponse(content);
    }
  }

  Future<void> _getAIResponse(String userMessage) async {
    if (!_geminiService.isConfigured) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: 'assistant',
            content:
                'ไม่สามารถเรียก Gemini ได้ เพราะยังไม่ได้ตั้งค่า GEMINI_API_KEY ใน .env',
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
      );
      return;
    }

    try {
      final messagesForAPI = <Map<String, String>>[
        {
          'role': 'system',
          'content': 'คุณคือแมว AI ร่าเริงที่ตอบเป็นภาษาไทยอย่างเป็นมิตรและขี้เล่น แต่ให้ข้อมูลที่ถูกต้องและชัดเจน ตอบสั้นกระชับเมื่อเหมาะสม และสามารถใส่คำทักทายแบบแมวๆ (เช่น เมี๊ยว) ได้บ้างเพื่อเพิ่มบุคลิก',
        },
        ...state.messages
            .where((message) => message.content.trim().isNotEmpty)
            .map(
              (message) => {
                'role': message.role == 'assistant' ? 'assistant' : 'user',
                'content': message.content,
              },
            ),
      ];

      final responseText = await _geminiService.generateContent(
        messages: messagesForAPI,
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: 'assistant',
            content: responseText,
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: 'assistant',
            content: 'เกิดข้อผิดพลาด: $e',
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = ChatState(messages: []);
    _addInitialMessage();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
