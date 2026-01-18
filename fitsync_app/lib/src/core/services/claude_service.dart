import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  // TODO: Replace with your actual API key or move to .env
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  Future<Map<String, dynamic>> generateSimpleResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 1000,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'] as List;
        final textBlock = content.firstWhere(
          (item) => item['type'] == 'text',
          orElse: () => null,
        );

        if (textBlock != null) {
          String text = textBlock['text'];
          // Extract JSON if wrapped in code blocks or other text
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
          if (jsonMatch != null) {
            return jsonDecode(jsonMatch.group(0)!);
          }
          // Fallback if strict JSON isn't found but response is valid
          // This might need better handling for non-JSON responses
          throw Exception('No JSON found in response');
        }
      }

      throw Exception(
        'Failed to generate response: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('Claude API Error: $e');
      rethrow;
    }
  }
}
