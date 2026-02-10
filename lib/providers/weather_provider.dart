import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  WeatherData? _weatherData;
  Map<String, dynamic>? _farmLocation;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  Map<String, dynamic>? get farmLocation => _farmLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFarmLocation() async {
    _farmLocation = await _storageService.getFarmLocation();
    notifyListeners();
    if (_farmLocation != null) {
      await refreshWeather();
    }
  }

  Future<void> setFarmLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _storageService.saveFarmLocation(
          position.latitude,
          position.longitude,
          'আপনার খামার',
        );
        _farmLocation = {
          'lat': position.latitude,
          'lon': position.longitude,
          'name': 'আপনার খামার',
        };
        await refreshWeather();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_farmLocation == null) return;

    _isLoading = true;
    notifyListeners();

    final data = await _weatherService.fetchWeather(
      _farmLocation!['lat'],
      _farmLocation!['lon'],
    );

    if (data != null) {
      _weatherData = data;
      _error = null;
    } else {
      _error = 'আবহাওয়ার তথ্য পাওয়া যায়নি।';
    }

    _isLoading = false;
    notifyListeners();
  }
}
