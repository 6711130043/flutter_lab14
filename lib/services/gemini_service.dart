import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  String get _apiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> generateContent({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) async {
    if (!isConfigured) {
      throw StateError('Missing GEMINI_API_KEY in .env');
    }

    // Convert OpenAI-style messages to Gemini format
    final contents = _convertMessagesToGeminiFormat(messages);

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': temperature,
      },
    };

    final uri = Uri.parse('$_endpoint?key=$_apiKey');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message']?.toString() ?? 'Gemini API error';
      throw Exception(message);
    }

    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini response has no candidates');
    }

    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini response has no parts');
    }

    final text = (parts.first as Map<String, dynamic>)['text']?.toString() ?? '';

    if (text.trim().isEmpty) {
      throw Exception('Gemini returned empty content');
    }

    return text.trim();
  }

  List<Map<String, dynamic>> _convertMessagesToGeminiFormat(
      List<Map<String, String>> messages) {
    final result = <Map<String, dynamic>>[];

    for (final message in messages) {
      final role = message['role'];
      final content = message['content'] ?? '';

      // Skip empty messages
      if (content.trim().isEmpty) continue;

      // Gemini uses 'user' and 'model' instead of 'user' and 'assistant'
      String geminiRole;
      if (role == 'system') {
        // For system messages, prepend to first user message
        if (result.isEmpty ||
            (result.last['role'] != null && result.last['role'] != 'user')) {
          // Add as user message with instruction prefix
          result.add({
            'role': 'user',
            'parts': [
              {'text': 'System instruction: $content'}
            ]
          });
        } else {
          // Prepend to existing user message
          final existingParts = result.last['parts'] as List<dynamic>;
          final existingText = (existingParts.first as Map<String, dynamic>)['text'] as String;
          (existingParts.first as Map<String, dynamic>)['text'] = 'System instruction: $content\n\n$existingText';
        }
        continue;
      } else if (role == 'assistant') {
        geminiRole = 'model';
      } else {
        geminiRole = 'user';
      }

      result.add({
        'role': geminiRole,
        'parts': [
          {'text': content}
        ]
      });
    }

    // Ensure we have at least one user message
    if (result.isEmpty) {
      result.add({
        'role': 'user',
        'parts': [
          {'text': 'Hello'}
        ]
      });
    }

    return result;
  }
}
