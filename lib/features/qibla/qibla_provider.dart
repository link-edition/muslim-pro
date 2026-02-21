import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:muslim_pro/core/location_service.dart';
import 'qibla_service.dart';

/// Qibla holati
class QiblaState {
  final bool isLoading;
  final bool hasCompass;       // Qurilmada kompas bormi
  final double qiblaDirection; // Qibla burchagi (gradus)
  final double heading;        // Qurilma yo'nalishi
  final double? distanceKm;   // Makkagacha masofa (km)
  final CompassAccuracy accuracy;
  final String? error;
  final bool showCalibration;  // Kalibrlash ko'rsatmasini ko'rsatish

  const QiblaState({
    this.isLoading = true,
    this.hasCompass = true,
    this.qiblaDirection = 0,
    this.heading = 0,
    this.distanceKm,
    this.accuracy = CompassAccuracy.low,
    this.error,
    this.showCalibration = false,
  });

  QiblaState copyWith({
    bool? isLoading,
    bool? hasCompass,
    double? qiblaDirection,
    double? heading,
    double? distanceKm,
    CompassAccuracy? accuracy,
    String? error,
    bool? showCalibration,
  }) {
    return QiblaState(
      isLoading: isLoading ?? this.isLoading,
      hasCompass: hasCompass ?? this.hasCompass,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      heading: heading ?? this.heading,
      distanceKm: distanceKm ?? this.distanceKm,
      accuracy: accuracy ?? this.accuracy,
      error: error,
      showCalibration: showCalibration ?? this.showCalibration,
    );
  }
}

/// Qibla Notifier — kompas logikasi
class QiblaNotifier extends StateNotifier<QiblaState> {
  StreamSubscription<QiblahDirection>? _qiblahSubscription;

  QiblaNotifier() : super(const QiblaState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    // 1. Kompas sensori borligini tekshirish
    try {
      final hasCompass = await QiblaService.isCompassAvailable();
      if (!hasCompass) {
        state = state.copyWith(
          isLoading: false,
          hasCompass: false,
          error: 'Qurilmangizda kompas sensori mavjud emas',
        );
        return;
      }
    } catch (_) {
      // iOS yoki boshqa platformalarda xato bo'lishi mumkin, davom etamiz
    }

    // 2. Joylashuv ruxsatini tekshirish va masofani hisoblash
    try {
      final position = await LocationService.getCurrentLocation();
      final distance = QiblaService.distanceToMakkah(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      state = state.copyWith(distanceKm: distance);
    } on LocationException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      // Masofa hisoblanmasa ham kompas ishlayveradi
    }

    // 3. Qibla stream'ini boshlash
    _startListening();
  }

  /// Qibla stream'dan ma'lumotlarni tinglash
  void _startListening() {
    _qiblahSubscription?.cancel();
    _qiblahSubscription = QiblaService.qiblahStream.listen(
      (qiblahDirection) {
        state = state.copyWith(
          isLoading: false,
          qiblaDirection: qiblahDirection.qiblah,
          heading: qiblahDirection.direction,
          hasCompass: true,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Kompas xatoligi: $error',
        );
      },
    );
  }

  /// Kalibrlash ko'rsatmasini yoqish/o'chirish
  void toggleCalibration() {
    state = state.copyWith(showCalibration: !state.showCalibration);
  }

  /// Kalibrlash ko'rsatmasini yopish
  void hideCalibration() {
    state = state.copyWith(showCalibration: false);
  }

  /// Qayta ulanish
  Future<void> reconnect() async {
    state = state.copyWith(isLoading: true, error: null);
    await _initialize();
  }

  @override
  void dispose() {
    _qiblahSubscription?.cancel();
    super.dispose();
  }
}

/// Global Qibla provider
final qiblaProvider =
    StateNotifierProvider<QiblaNotifier, QiblaState>((ref) {
  return QiblaNotifier();
});
