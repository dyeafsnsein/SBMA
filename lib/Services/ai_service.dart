import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  Future<List<String>> generateBudgetTips({
    required double income,
    required double expenses,
    required Map<String, double> categories,
    String? timestamp,
  }) async {
    debugPrint(
        'AiService: Generating budget tips with income=$income, expenses=$expenses, categories=$categories, timestamp=$timestamp');
    try {
      // Validate input
      if (income <= 0 || expenses <= 0 || categories.isEmpty) {
        debugPrint('AiService: Invalid input data, returning empty tips');
        return ['No tips generated due to invalid data.'];
      }

      // Initialize Gemini model
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('AiService: GEMINI_API_KEY is missing');
        return ['Error: Missing API key.'];
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Randomize tip focus
      final tipFocusOptions = [
        'prioritizing savings',
        'reducing discretionary spending',
        'optimizing essential expenses',
        'increasing financial security',
        'planning for long-term goals',
      ];
      final randomFocus =
          (DateTime.now().millisecondsSinceEpoch % tipFocusOptions.length)
              .toInt();
      final selectedFocus = tipFocusOptions[randomFocus];

      // Create a dynamic prompt
      final prompt = '''
You are a financial advisor. Based on the following financial data, provide 3-5 concise budget tips to help optimize spending and savings, focusing on $selectedFocus. Each tip should be a single sentence, practical, and tailored to the data. Vary the advice to ensure unique suggestions each time, using the timestamp $timestamp for context.

- Monthly Income: \$${income.toStringAsFixed(2)}
- Monthly Expenses: \$${expenses.toStringAsFixed(2)}
- Spending by Category: ${categories.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}
- Timestamp: $timestamp

Please format the response as a list of tips, one per line, starting with an asterisk (*).
''';

      debugPrint('AiService: Sending prompt to Gemini: $prompt');

      // Call Gemini API
      final response = await model.generateContent([Content.text(prompt)]);
      final tips = response.text
              ?.split('\n')
              .map((line) => line.trim())
              .where((line) => line.startsWith('*') && line.length > 2)
              .map((line) => line.substring(2).trim())
              .toList() ??
          [];

      debugPrint('AiService: Generated tips: $tips');

      if (tips.isEmpty) {
        debugPrint('AiService: Gemini returned empty tips');
        return ['Review your spending for potential savings.'];
      }

      return tips;
    } catch (e, stackTrace) {
      debugPrint('AiService: Error generating tips: $e\n$stackTrace');
      return ['Error generating tips: $e'];
    }
  }
}
