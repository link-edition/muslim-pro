import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/core/location_service.dart';
import 'data/prayer_model.dart';
import 'data/prayer_times_service.dart';
import 'data/prayer_storage.dart';
import 'data/prayer_calculation_method.dart';
import 'package:muslim_pro/core/notification_service.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';
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
  final Ref ref;
  Timer? _countdownTimer;

  PrayerNotifier(this.ref) : super(const PrayerState()) {
    _initialize();
    _listenToSettings();
  }

  void _listenToSettings() {
    ref.listen(settingsProvider, (previous, next) {
      if (previous == null) return;
      
      bool shouldRefresh = false;

      if (previous.madhab != next.madhab) {
        shouldRefresh = true;
      }
      if (previous.isAutoLocation != next.isAutoLocation) {
        shouldRefresh = true;
      }
      if (previous.latitude != next.latitude || previous.longitude != next.longitude) {
        shouldRefresh = true;
      }
      
      if (shouldRefresh) {
        refreshPrayerTimes();
      }
    });

    ref.listen(prayerMethodProvider, (previous, next) {
      if (previous?.method != next.method) {
        refreshPrayerTimes();
      }
    });
  }

  /// Ilovani boshlashda: keshdan yuklash, keyin yangi hisoblash
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    // 1. Avval keshdan yuklash
    final cached = await PrayerStorage.loadPrayerTimes();
    if (cached != null) {
      final isCacheValid = await PrayerStorage.isCacheValid();
      if (isCacheValid) {
        state = state.copyWith(
          prayerTimes: cached,
          isLoading: false,
        );
        _startCountdown();
        NotificationService.schedulePrayerNotifications(cached);
        // Baribir bir marta yangilab qo'yamiz (fon rejimida)
        refreshPrayerTimes();
        return;
      }
    }

    // 2. Yangi hisoblash
    await refreshPrayerTimes();
  }

  /// Namoz vaqtlarini yangilash
  Future<void> refreshPrayerTimes() async {

    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = ref.read(settingsProvider);
      double lat = 41.2995;
      double lng = 69.2401;

      if (settings.isAutoLocation) {
        try {
          final position = await LocationService.getCurrentLocation();
          lat = position.latitude;
          lng = position.longitude;
        } catch (e) {

          if (settings.latitude != null && settings.longitude != null) {
            lat = settings.latitude!;
            lng = settings.longitude!;
          }
        }
      } else if (settings.latitude != null && settings.longitude != null) {
        lat = settings.latitude!;
        lng = settings.longitude!;
      }

      // Namoz vaqtlarini hisoblash
      final currentMethodState = ref.read(prayerMethodProvider);
      final prayerTimes = PrayerTimesService.calculateForToday(
        latitude: lat,
        longitude: lng,
        method: currentMethodState.method.apiName,
        madhab: settings.madhab,
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

    // Agar kun o'zgargan bo'lsa (yarim tundan o'tganda), hamma vaqtlarni yangilaymiz
    if (now.day != prayerTimes.date.day) {
      _countdownTimer?.cancel();
      Future.microtask(() => refreshPrayerTimes());
      return;
    }

    // Keyingi namozni qayta hisoblash
    int? currentNextIndex;
    for (int i = 0; i < prayerTimes.prayers.length; i++) {
      if (prayerTimes.prayers[i].isNext) {
        currentNextIndex = i;
        break;
      }
    }

    int? newNextIndex;
    for (int i = 0; i < prayerTimes.prayers.length; i++) {
      if (prayerTimes.prayers[i].time.isAfter(now)) {
        newNextIndex = i;
        break;
      }
    }

    List<PrayerModel> updatedPrayers = prayerTimes.prayers;
    if (newNextIndex != currentNextIndex) {
      updatedPrayers = prayerTimes.prayers.map((prayer) {
        return prayer.copyWith(isNext: false);
      }).toList();
      if (newNextIndex != null) {
        updatedPrayers[newNextIndex] = updatedPrayers[newNextIndex].copyWith(isNext: true);
      }
    }

    final nextPrayer = newNextIndex != null ? updatedPrayers[newNextIndex] : null;

    Duration? countdown;
    if (nextPrayer != null) {
      countdown = nextPrayer.time.difference(now);
    } else {
      // Bugun hamma namozlar o'tib bo'ldi, ertangi Bomdodni hisoblaymiz
      final settings = ref.read(settingsProvider);
      final currentMethodState = ref.read(prayerMethodProvider);
      final tomorrow = now.add(const Duration(days: 1));
      
      final tomorrowTimes = PrayerTimesService.calculateForDate(
        date: tomorrow,
        latitude: prayerTimes.latitude,
        longitude: prayerTimes.longitude,
        method: currentMethodState.method.apiName,
        madhab: settings.madhab,
      );
      
      final tomorrowFajr = tomorrowTimes.prayers.first; // Bomdod doim birinchi
      countdown = tomorrowFajr.time.difference(now);
    }

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
  return PrayerNotifier(ref);
});
