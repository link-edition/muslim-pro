import 'dart:async';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

/// Ka'ba koordinatalari (Makka, Saudiya Arabistoni)
class KaabaLocation {
  static const double latitude = 21.4225;
  static const double longitude = 39.8262;
}

/// Qibla kompas xizmati
class QiblaService {
  /// Qurilmada kompas sensori bormi yoki yo'qligini tekshirish
  static Future<bool> isCompassAvailable() async {
    final result = await FlutterQiblah.androidDeviceSensorSupport();
    return result ?? true; // null bo'lsa (iOS), true qaytaramiz
  }

  /// Qibla yo'nalish ma'lumotlari stream'i
  static Stream<QiblahDirection> get qiblahStream {
    return FlutterQiblah.qiblahStream;
  }

  /// Foydalanuvchi joylashuvidan Makkagacha masofa (km)
  static double distanceToMakkah({
    required double latitude,
    required double longitude,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      latitude,
      longitude,
      KaabaLocation.latitude,
      KaabaLocation.longitude,
    );
    return distanceInMeters / 1000; // metrdan km ga
  }
}

/// Kompas sensori aniqlik darajasi
enum CompassAccuracy {
  low,
  medium,
  high,
}

/// Aniqlik darajasini aniqlash (heading accuracy asosida)
CompassAccuracy getCompassAccuracy(double? accuracy) {
  if (accuracy == null || accuracy > 25) return CompassAccuracy.low;
  if (accuracy > 10) return CompassAccuracy.medium;
  return CompassAccuracy.high;
}
