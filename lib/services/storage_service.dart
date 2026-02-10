import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyLat = 'farm_lat';
  static const String keyLon = 'farm_lon';
  static const String keyLocationName = 'farm_location_name';

  Future<void> saveFarmLocation(double lat, double lon, String? name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyLat, lat);
    await prefs.setDouble(keyLon, lon);
    if (name != null) await prefs.setString(keyLocationName, name);
  }

  Future<Map<String, dynamic>?> getFarmLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(keyLat);
    final lon = prefs.getDouble(keyLon);
    final name = prefs.getString(keyLocationName);

    if (lat != null && lon != null) {
      return {'lat': lat, 'lon': lon, 'name': name};
    }
    return null;
  }
}
