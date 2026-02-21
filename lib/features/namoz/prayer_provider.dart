import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/core/location_service.dart';
import 'data/prayer_model.dart';
import 'data/prayer_times_service.dart';
import 'data/prayer_storage.dart';
import 'package:muslim_pro/core/notification_service.dart';
/// Namoz vaqtlari holati
class PrayerState {
  final DailyPrayerTimes? prayerTimes;
  final bool isLoading;
  final String? error;
  final Duration? countdown;

  const PrayerState({
    this.prayerTimes,
    this.isLoading = false,
    this.error,
    this.countdown,
  });

  PrayerState copyWith({
    DailyPrayerTimes? prayerTimes,
    bool? isLoading,
    String? error,
    Duration? countdown,
  }) {
    return PrayerState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      countdown: countdown ?? this.countdown,
    );
  }
}

/// Namoz vaqtlari Notifier — barcha logika shu yerda
class PrayerNotifier extends StateNotifier<PrayerState> {
  Timer? _countdownTimer;

  PrayerNotifier() : super(const PrayerState()) {
    _initialize();
  }

  /// Ilovani boshlashda: keshdan yuklash, keyin yangi hisoblash
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    // 1. Avval keshdan yuklash (oflayn rejim uchun)
    final isCacheValid = await PrayerStorage.isCacheValid();
    if (isCacheValid) {
      final cached = await PrayerStorage.loadPrayerTimes();
      if (cached != null) {
        state = state.copyWith(
          prayerTimes: cached,
          isLoading: false,
        );
        _startCountdown();
        // Bildirishnomalarni rejalashtirish
        NotificationService.schedulePrayerNotifications(cached);
        return;
      }
    }

    // 2. GPS dan yangi hisoblash
    await refreshPrayerTimes();
  }

  /// Namoz vaqtlarini yangilash (GPS dan qayta hisoblash)
  Future<void> refreshPrayerTimes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // GPS koordinatalarini olish
      final position = await LocationService.getCurrentLocation();

      // Namoz vaqtlarini hisoblash
      final prayerTimes = PrayerTimesService.calculateForToday(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Keshga saqlash
      await PrayerStorage.savePrayerTimes(prayerTimes);

      state = state.copyWith(
        prayerTimes: prayerTimes,
        isLoading: false,
      );

      // Bildirishnomalarni rejalashtirish
      NotificationService.schedulePrayerNotifications(prayerTimes);

      // Countdown taymerni boshlash
      _startCountdown();
    } on LocationException catch (e) {
      // Joylashuv xatoligi — keshdan yuklashga harakat
      final cached = await PrayerStorage.loadPrayerTimes();
      state = state.copyWith(
        prayerTimes: cached,
        isLoading: false,
        error: e.message,
      );
      if (cached != null) _startCountdown();
    } catch (e) {
      // Boshqa xatoliklar
      final cached = await PrayerStorage.loadPrayerTimes();
      state = state.copyWith(
        prayerTimes: cached,
        isLoading: false,
        error: 'Xatolik yuz berdi: ${e.toString()}',
      );
      if (cached != null) _startCountdown();
    }
  }

  /// Keyingi namozgacha countdown taymer
  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  /// Countdownni yangilash
  void _updateCountdown() {
    final prayerTimes = state.prayerTimes;
    if (prayerTimes == null) return;

    final now = DateTime.now();

    // Keyingi namozni qayta hisoblash (vaqt o'tgan bo'lishi mumkin)
    final updatedPrayers = prayerTimes.prayers.map((prayer) {
      return prayer.copyWith(isNext: false);
    }).toList();

    bool nextFound = false;
    for (int i = 0; i < updatedPrayers.length; i++) {
      if (!nextFound && updatedPrayers[i].time.isAfter(now)) {
        updatedPrayers[i] = updatedPrayers[i].copyWith(isNext: true);
        nextFound = true;
      }
    }

    final nextPrayer = nextFound
        ? updatedPrayers.firstWhere((p) => p.isNext)
        : null;

    final countdown = nextPrayer?.time.difference(now);

    state = state.copyWith(
      prayerTimes: DailyPrayerTimes(
        prayers: updatedPrayers,
        date: prayerTimes.date,
        latitude: prayerTimes.latitude,
        longitude: prayerTimes.longitude,
      ),
      countdown: countdown,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

/// Global Riverpod provider
final prayerProvider =
    StateNotifierProvider<PrayerNotifier, PrayerState>((ref) {
  return PrayerNotifier();
});
