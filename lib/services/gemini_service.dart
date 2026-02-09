import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/gemini_config.dart';
import '../models/analysis_result.dart';

class GeminiService {
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Use v1beta because your ListModels came from v1beta and it is consistent
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<AnalysisResult> analyzeSymptoms({
    required String symptoms,
    required String animalType,
    required String duration,
    required String ageGroup,
    File? image,
  }) async {
    final modelsToTry = <String>[
      geminiPrimaryModel,
      ...geminiFallbackModels,
    ];

    Object? lastError;

    for (final model in modelsToTry) {
      try {
        return await _analyzeWithModel(
          model: model,
          symptoms: symptoms,
          animalType: animalType,
          duration: duration,
          ageGroup: ageGroup,
          image: image,
        );
      } catch (e) {
        lastError = e;

        // If it is not a 429/quota issue, do not try fallback models
        final msg = e.toString();
        final isQuota =
            msg.contains('429') || msg.contains('RESOURCE_EXHAUSTED');

        if (!isQuota) rethrow;
      }
    }

    throw Exception(lastError?.toString() ?? 'Gemini error (unknown)');
  }

  Future<AnalysisResult> _analyzeWithModel({
    required String model,
    required String symptoms,
    required String animalType,
    required String duration,
    required String ageGroup,
    File? image,
  }) async {
    final cleanModel = _normalizeModel(model);

    final url = Uri.parse('$_baseUrl/$cleanModel:generateContent?key=$geminiApiKey');

    final requestBody = _buildRequestBody(
      symptoms: symptoms,
      animalType: animalType,
      duration: duration,
      ageGroup: ageGroup,
      image: image,
    );

    final response = await _client.post(
      url,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(requestBody),
    );

    final rawBody = utf8.decode(response.bodyBytes);

    // Debug helpful logs (you can remove later)
     print('Gemini model: $cleanModel');
     print('Gemini status: ${response.statusCode}');
     print('Gemini body: $rawBody');

    if (response.statusCode == 200) {
      final data = jsonDecode(rawBody) as Map<String, dynamic>;

      // Optional: log usage tokens if present
      final usage = data['usageMetadata'];
      if (usage is Map) {
        // print('Gemini usage totalTokenCount: ${usage['totalTokenCount']}');
      }

      final textResponse = _extractText(data);
      final jsonString = _extractJsonObject(textResponse);

      final resultMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return AnalysisResult.fromJson(resultMap);
    }

    // Handle quota/rate limit
    if (response.statusCode == 429) {
      throw Exception(
        '429 RESOURCE_EXHAUSTED (model=$cleanModel): আজকের ফ্রি লিমিট শেষ বা রেট লিমিট হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।',
      );
    }

    // Some quota errors can also come as 403/400 with RESOURCE_EXHAUSTED in body
    if (rawBody.contains('RESOURCE_EXHAUSTED')) {
      throw Exception(
        'RESOURCE_EXHAUSTED (model=$cleanModel): আজকের ফ্রি লিমিট শেষ বা রেট লিমিট হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।',
      );
    }

    throw Exception('Gemini API Error (model=$cleanModel) '
        '${response.statusCode}: $rawBody');
  }

  Map<String, dynamic> _buildRequestBody({
    required String symptoms,
    required String animalType,
    required String duration,
    required String ageGroup,
    File? image,
  }) {
    final prompt = '''
আপনি একজন প্রাণিসম্পদ/পোল্ট্রি ভেট সহকারী। নিচের তথ্য দেখে সম্ভাব্য রোগের ধারণা দিন।
ডোজ/ব্র্যান্ড নাম দেবেন না—শুধু generic medicine names।
অ্যান্টিবায়োটিক (Antibiotics) কোনোভাবেই পরামর্শ দেওয়া যাবে না।
উত্তর শুধুমাত্র VALID JSON হবে (কোনো markdown/extra text নয়)।

ইনপুট:
প্রাণী: $animalType
বয়স: $ageGroup
স্থায়িত্ব: $duration
উপসর্গ: $symptoms

আউটপুট JSON:
{
  "সম্ভাব্য_রোগসমূহ": [
    { "রোগের_নাম": "", "সম্ভাবনা_শতাংশ": 0, "কারণ": "" }
  ],
  "প্রাথমিক_ওষুধ": ["", ""],
  "ঘরোয়া_চিকিৎসা": ["", "", ""],
  "যে_ব্যবস্থা_নিতে_হবে": ["", "", ""]
}

শর্ত:
- সম্ভাব্য_রোগসমূহ 2টি (সর্বোচ্চ 3টি)।
- কারণ ১ লাইনে।
- সব লেখা বাংলায়।
''';

    final parts = <Map<String, dynamic>>[
      {"text": prompt},
    ];

    if (image != null) {
      final base64Image = base64Encode(image.readAsBytesSync());
      parts.add({
        "inlineData": {
          "mimeType": "image/jpeg",
          "data": base64Image,
        }
      });
    }

    return {
      "contents": [
        {
          "role": "user",
          "parts": parts,
        }
      ],
      "generationConfig": {
        "temperature": 0.2,
        "maxOutputTokens": 450,
        "responseMimeType": "application/json",
      }
    };
  }

  String _normalizeModel(String model) {
    // user might accidentally pass "models/gemini-2.0-flash-lite"
    return model.replaceFirst(RegExp(r'^models\/'), '').trim();
  }

  String _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini response has no candidates');
    }

    final content = candidates[0]['content'];
    final parts = content?['parts'];
    if (parts is! List || parts.isEmpty) {
      throw Exception('Gemini response has no content parts');
    }

    final text = parts[0]['text'];
    if (text is! String) {
      throw Exception('Gemini response part[0].text is not a String');
    }

    return text;
    }

  String _extractJsonObject(String text) {
    var s = text.trim();

    // Remove common code fences
    s = s.replaceAll('```json', '').replaceAll('```', '').trim();

    // If model still returns extra text, extract first {...} block
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('Could not find JSON object in Gemini output: $s');
    }

    return s.substring(start, end + 1).trim();
  }
}