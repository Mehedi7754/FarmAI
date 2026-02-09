import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';

class AnalysisCacheService {
  static const String _prefix = 'analysis_cache_';
  static const int _ttlDays = 3;

  /// Normalizes symptoms text: lowercase, trim, collapse spaces, remove punctuation.
  static String normalizeSymptoms(String text) {
    return text.toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        // Remove common punctuation but keep spaces and alphanumeric (including Bengali)
        .replaceAll(RegExp(r'[^\w\s\u0980-\u09FF]'), '');
  }

  /// Generates a cache key based on animal properties, symptoms, and image hash.
  static Future<String> generateCacheKey({
    required String symptoms,
    required String animalType,
    required String duration,
    required String ageGroup,
    List<int>? imageBytes,
  }) async {
    final normSymptoms = normalizeSymptoms(symptoms);
    final imageHash = imageBytes != null ? sha256.convert(imageBytes).toString() : 'NO_IMAGE';
    
    // Combining parameters into a unique string for the cache key
    final keySource = '${animalType}_${ageGroup}_${duration}_${normSymptoms}_$imageHash';
    // Hash the combined string to keep the key length manageable for SharedPreferences
    return sha256.convert(utf8.encode(keySource)).toString();
  }

  /// Saves the result to local cache with a timestamp.
  static Future<void> saveToCache(String key, AnalysisResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'ts': DateTime.now().millisecondsSinceEpoch,
        'value': result.toJson(),
      };
      await prefs.setString(_prefix + key, jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Save Cache Error: $e');
    }
  }

  /// Retrieves a result from cache if it exists and hasn't expired.
  static Future<AnalysisResult?> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefix + key);
      if (jsonString == null) return null;

      final cacheData = jsonDecode(jsonString);
      final int ts = cacheData['ts'];
      final Map<String, dynamic> value = cacheData['value'];

      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - ts;
      final ttlMillis = _ttlDays * 24 * 60 * 60 * 1000;

      if (diff > ttlMillis) {
        // Expired
        await prefs.remove(_prefix + key);
        return null;
      }

      return AnalysisResult.fromJson(value);
    } catch (e) {
      debugPrint('Get Cache Error: $e');
      return null;
    }
  }
}
