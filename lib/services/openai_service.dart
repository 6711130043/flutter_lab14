import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> createChatCompletion({
    required List<Map<String, String>> messages,
    String model = 'gpt-4o-mini',
    double temperature = 0.7,
    bool jsonResponse = false,
  }) async {
    if (!isConfigured) {
      throw StateError('Missing OPENAI_API_KEY in .env');
    }

    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'temperature': temperature,
    };

    if (jsonResponse) {
      body['response_format'] = {'type': 'json_object'};
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message']?.toString() ?? 'OpenAI API error';
      throw Exception(message);
    }

    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('OpenAI response has no choices');
    }

    final content = (choices.first as Map<String, dynamic>)['message']
        as Map<String, dynamic>?;
    final text = content?['content']?.toString() ?? '';

    if (text.trim().isEmpty) {
      throw Exception('OpenAI returned empty content');
    }

    return text.trim();
  }

  Future<({Uint8List? imageBytes, String? imageUrl})> generateImage({
    required String prompt,
    String model = 'gpt-image-1',
    String size = '1024x1024',
  }) async {
    if (!isConfigured) {
      throw StateError('Missing OPENAI_API_KEY in .env');
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'size': size,
      }),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message']?.toString() ?? 'OpenAI image API error';
      throw Exception(message);
    }

    final data = decoded['data'] as List<dynamic>?;
    if (data == null || data.isEmpty) {
      throw Exception('OpenAI image response has no data');
    }

    final first = data.first as Map<String, dynamic>;
    final b64 = first['b64_json']?.toString();
    final url = first['url']?.toString();

    if (b64 != null && b64.isNotEmpty) {
      return (imageBytes: base64Decode(b64), imageUrl: null);
    }
    if (url != null && url.isNotEmpty) {
      return (imageBytes: null, imageUrl: url);
    }

    throw Exception('OpenAI image response missing b64_json/url');
  }
}
