import 'package:geolocator/geolocator.dart';

/// GPS orqali foydalanuvchi joylashuvini aniqlash xizmati
class LocationService {
  /// Joriy koordinatalarni olish (latitude, longitude)
  /// Ruxsat berilmagan bo'lsa, so'raydi
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. GPS xizmati yoqilganligini tekshirish
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'GPS xizmati o\'chirilgan. Iltimos, joylashuvni yoqing.',
        LocationErrorType.serviceDisabled,
      );
    }

    // 2. Ruxsatni tekshirish
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Ruxsat so'rash
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Joylashuv ruxsati rad etildi.',
          LocationErrorType.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Joylashuv ruxsati butunlay rad etilgan. Sozlamalardan ruxsat bering.',
        LocationErrorType.permissionDeniedForever,
      );
    }

    // 3. Joriy koordinatalarni olish
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Oxirgi ma'lum bo'lgan joylashuvni olish (tezroq)
  static Future<Position?> getLastKnownLocation() async {
    return await Geolocator.getLastKnownPosition();
  }
}

/// Joylashuv xatolik turlari
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

/// Joylashuv xatolik modeli
class LocationException implements Exception {
  final String message;
  final LocationErrorType type;

  LocationException(this.message, this.type);

  @override
  String toString() => 'LocationException: $message';
}
