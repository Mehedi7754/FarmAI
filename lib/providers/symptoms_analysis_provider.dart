import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../services/gemini_service.dart';
import '../utils/image_utils.dart';
import '../services/analysis_cache_service.dart';

class SymptomsAnalysisProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = false;
  String? _error;
  AnalysisResult? _result;
  File? _selectedImage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalysisResult? get result => _result;
  File? get selectedImage => _selectedImage;

  Future<void> setImage(File? image) async {
    if (image == null) {
      _selectedImage = null;
    } else {
      _isLoading = true;
      notifyListeners();
      
      // Compress image before storing
      final compressed = await ImageUtils.compressImage(image);
      _selectedImage = compressed ?? image;
      
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> analyze({
    required String symptoms,
    required String animalType,
    required String duration,
    required String ageGroup,
  }) async {
    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      // 1. Prepare image bytes for hashing if image exists
      List<int>? imageBytes;
      if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
      }

      // 2. Generate unique cache key
      final cacheKey = await AnalysisCacheService.generateCacheKey(
        symptoms: symptoms,
        animalType: animalType,
        duration: duration,
        ageGroup: ageGroup,
        imageBytes: imageBytes,
      );

      // 3. Check for cached result
      final cachedResult = await AnalysisCacheService.getFromCache(cacheKey);
      if (cachedResult != null) {
        _result = cachedResult;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 4. Cache miss: Perform Gemini analysis
      _result = await _geminiService.analyzeSymptoms(
        symptoms: symptoms,
        animalType: animalType,
        duration: duration,
        ageGroup: ageGroup,
        image: _selectedImage,
      );

      // 5. Save successful result to cache
      if (_result != null) {
        await AnalysisCacheService.saveToCache(cacheKey, _result!);
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') 
          ? e.toString().replaceAll('Exception: ', '') 
          : 'দুঃখিত, কোনো সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      print('Analysis Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _result = null;
    _selectedImage = null;
    notifyListeners();
  }
}
