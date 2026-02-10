import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('আপনার মোবাইলের লোকেশন চালু করুন।');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('আপনার মোবাইলের লোকেশন পারমিশন দেওয়া হয়নি।');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('আপনার মোবাইলের লোকেশন পারমিশন চিরতরে বন্ধ করা আছে।');
    }

    return await Geolocator.getCurrentPosition();
  }
}
