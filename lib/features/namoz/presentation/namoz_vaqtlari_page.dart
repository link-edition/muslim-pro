import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/namoz/prayer_provider.dart';
import 'package:muslim_pro/features/namoz/data/prayer_times_service.dart';
import 'package:muslim_pro/features/namoz/data/prayer_model.dart';
import 'package:intl/intl.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';
import 'package:muslim_pro/features/namoz/data/prayer_calculation_method.dart';
import 'package:geocoding/geocoding.dart';
import 'package:muslim_pro/core/location_service.dart';
import 'package:muslim_pro/core/localization.dart';

// ═════════════════════════════════════════════════════════════
// MAIN PAGE — Solar Dashboard
// ═════════════════════════════════════════════════════════════

class NamozVaqtlariPage extends ConsumerStatefulWidget {
  const NamozVaqtlariPage({super.key});

  @override
  ConsumerState<NamozVaqtlariPage> createState() => _NamozVaqtlariPageState();
}

class _NamozVaqtlariPageState extends ConsumerState<NamozVaqtlariPage>
    with TickerProviderStateMixin {
  late AnimationController _tickController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _resolvedCity;

  @override
  void initState() {
    super.initState();
    _resolveLocation();

    // Main tick — drives sun position recalc every frame
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Sun pulse glow — subtle breathing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _resolveLocation() async {
    final settings = ref.read(settingsProvider);
    if (!settings.isAutoLocation) {
      if (mounted) setState(() => _resolvedCity = settings.cityName);
      return;
    }
    
    try {
      final pos = await LocationService.getCurrentLocation();
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Eng kichik mintaqa (shahar, tuman, mahalla nomi)
        final city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? 'Noma\'lum hudud';
        if (mounted) setState(() => _resolvedCity = city);
      }
    } catch (e) {
      if (mounted) setState(() => _resolvedCity = settings.cityName);
    }
  }

  @override
  void dispose() {
    _tickController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerProvider);
    final l10n = ref.watch(localizationProvider);
    final prayers = prayerState.prayerTimes?.prayers ?? [];
    final settings = ref.watch(settingsProvider);
    final methodState = ref.watch(prayerMethodProvider);
    final lang = settings.language;
    final now = DateTime.now();

    // Extract key times for solar arc
    DateTime? sunrise, sunset, fajr, isha;
    for (final p in prayers) {
      if (p.name == 'Quyosh') sunrise = p.time;
      if (p.name == 'Shom') sunset = p.time;
      if (p.name == 'Bomdod') fajr = p.time;
      if (p.name == 'Xufton') isha = p.time;
    }

    final skyColors = _getSkyGradient(now, fajr, sunrise, sunset, isha);

    String dateString;
    try {
      dateString = DateFormat('d-MMMM, yyyy', 'uz').format(now);
    } catch (e) {
      dateString = DateFormat('d-MM-yyyy').format(now);
    }

    final cityName = settings.isAutoLocation
        ? l10n.translate('current_location')
        : l10n.translate(settings.cityName);
    final methodName = methodState.method.displayName(lang);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: prayerState.isLoading && prayerState.prayerTimes == null
          ? Center(
              child: CircularProgressIndicator(color: context.colors.softGold))
          : Column(
              children: [
                // ── SOLAR ARC HEADER ──
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: skyColors,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // Top bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              
                              // MARKAZ: Shahar nomi faqat
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      _resolvedCity ?? cityName,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(dateString,
                                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _showMonthlyCalendar(context, ref, settings),
                                    icon: const Icon(Icons.calendar_month_rounded, size: 22, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _showMethodSelection(context, ref),
                                    icon: const Icon(Icons.tune_rounded, size: 22, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Solar arc — live animated
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            height: 140,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_tickController, _pulseController]),
                              builder: (context, _) {
                                double liveProgress = 0.0;
                                final n = DateTime.now();
                                if (sunrise != null && sunset != null) {
                                  final total = sunset.difference(sunrise).inSeconds.toDouble();
                                  final elapsed = n.difference(sunrise).inSeconds.toDouble();
                                  liveProgress = (elapsed / total).clamp(0.0, 1.0);
                                }
                                final isDay = sunrise != null && sunset != null &&
                                    n.isAfter(sunrise) && n.isBefore(sunset);
                                return CustomPaint(
                                  size: Size(MediaQuery.of(context).size.width - 40, 140),
                                  painter: _SolarArcPainter(
                                    progress: liveProgress,
                                    isDaytime: isDay,
                                    pulseValue: _pulseAnimation.value,
                                    sunriseLabel: sunrise != null
                                        ? '${sunrise.hour.toString().padLeft(2, '0')}:${sunrise.minute.toString().padLeft(2, '0')}'
                                        : '--:--',
                                    sunsetLabel: sunset != null
                                        ? '${sunset.hour.toString().padLeft(2, '0')}:${sunset.minute.toString().padLeft(2, '0')}'
                                        : '--:--',
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Countdown
                        if (prayerState.countdown != null) ...[
                          _buildCountdown(
                              prayerState.countdown!, prayers, l10n),
                          const SizedBox(height: 14),
                        ] else
                          const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // Error banner
                if (prayerState.error != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orangeAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(prayerState.error!,
                                style: const TextStyle(
                                    color: Colors.orangeAccent, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── COMPACT PRAYER LIST ──
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: prayers.length,
                    itemExtent: 68.0, // Hardcoded extent: 60 height + 8 margin = 120 FPS O(1) layout
                    itemBuilder: (context, index) {
                      final prayer = prayers[index];
                      return _CompactPrayerCard(
                        prayer: prayer,
                        l10n: l10n,
                        isEnabled:
                            settings.enabledPrayers[prayer.name] ?? true,
                        onBellTap: () {
                          final enabled =
                              settings.enabledPrayers[prayer.name] ?? true;
                          ref
                              .read(settingsProvider.notifier)
                              .togglePrayerNotification(
                                  prayer.name, !enabled);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ── Countdown widget ──
  Widget _buildCountdown(
      Duration countdown, List<PrayerModel> prayers, AppLocalization l10n) {
    final nextPrayer = prayers.where((p) => p.isNext).firstOrNull;
    final h = countdown.inHours;
    final m = countdown.inMinutes.remainder(60);
    final s = countdown.inSeconds.remainder(60);

    final isUrgent = countdown.inMinutes < 10 && countdown.inHours == 0;

    return Column(
      children: [
        if (nextPrayer != null)
          Text(
            '${l10n.translate(nextPrayer.name)} boshlanishiga qoldi',
            style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isUrgent ? Colors.redAccent.withOpacity(0.8) : const Color(0xFFD4AF37).withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isUrgent ? Colors.redAccent.withOpacity(0.2) : const Color(0xFFD4AF37).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: isUrgent ? 6 : 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _cBlock(h.toString().padLeft(2, '0')),
              _cSep(),
              _cBlock(m.toString().padLeft(2, '0')),
              _cSep(),
              _cBlock(s.toString().padLeft(2, '0')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cBlock(String val) {
    return SizedBox(
      width: 46,
      child: Center(
        child: Text(val,
            style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD4AF37),
                height: 1,
                letterSpacing: 1)),
      ),
    );
  }

  Widget _cSep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _pulseAnimation.value,
            child: Text(':',
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4AF37).withOpacity(0.7),
                  height: 1)),
          );
        }
      ),
    );
  }

  // ── Dynamic sky gradient ──
  List<Color> _getSkyGradient(DateTime now, DateTime? fajr, DateTime? sunrise,
      DateTime? sunset, DateTime? isha) {
    if (fajr == null || sunrise == null || sunset == null || isha == null) {
      return const [Color(0xFF0D1B2A), Color(0xFF1B263B)];
    }

    // Find Peshin/Asr times from prayers
    DateTime? peshin, asr;
    final prayers = ref.read(prayerProvider).prayerTimes?.prayers ?? [];
    for (final p in prayers) {
      if (p.name == 'Peshin') peshin = p.time;
      if (p.name == 'Asr') asr = p.time;
    }
    peshin ??= sunrise.add(Duration(minutes: ((sunset.difference(sunrise).inMinutes) * 0.45).round()));
    asr ??= sunrise.add(Duration(minutes: ((sunset.difference(sunrise).inMinutes) * 0.7).round()));

    if (now.isBefore(fajr)) {
      // Deep night → pre-fajr
      return const [Color(0xFF0A0E27), Color(0xFF0D1B2A)];
    } else if (now.isBefore(sunrise)) {
      // Fajr → Sunrise: deep blue → orange-pink dawn
      final t = _timeFraction(now, fajr, sunrise);
      return [
        Color.lerp(const Color(0xFF0D1B2A), const Color(0xFF2D1B4E), t)!,
        Color.lerp(const Color(0xFF1B263B), const Color(0xFFE65100), t)!,
      ];
    } else if (now.isBefore(peshin)) {
      // Sunrise → Dhuhr: orange-pink → bright sky
      final t = _timeFraction(now, sunrise, peshin);
      return [
        Color.lerp(const Color(0xFF2D1B4E), const Color(0xFF1976D2), t)!,
        Color.lerp(const Color(0xFFE65100), const Color(0xFF42A5F5), t)!,
      ];
    } else if (now.isBefore(asr)) {
      // Dhuhr → Asr: bright sky → warm afternoon
      final t = _timeFraction(now, peshin, asr);
      return [
        Color.lerp(const Color(0xFF1976D2), const Color(0xFF1565C0), t)!,
        Color.lerp(const Color(0xFF42A5F5), const Color(0xFF4DB6AC), t)!,
      ];
    } else if (now.isBefore(sunset)) {
      // Asr → Maghrib: warm → orange-red sunset
      final t = _timeFraction(now, asr, sunset);
      return [
        Color.lerp(const Color(0xFF1565C0), const Color(0xFFBF360C), t)!,
        Color.lerp(const Color(0xFF4DB6AC), const Color(0xFFFF6F00), t)!,
      ];
    } else if (now.isBefore(isha)) {
      // Maghrib → Isha: orange-red → dark navy
      final t = _timeFraction(now, sunset, isha);
      return [
        Color.lerp(const Color(0xFFBF360C), const Color(0xFF0D1B2A), t)!,
        Color.lerp(const Color(0xFFFF6F00), const Color(0xFF1B263B), t)!,
      ];
    } else {
      // Isha → deep navy night
      return const [Color(0xFF0A0E27), Color(0xFF0D1B2A)];
    }
  }

  double _timeFraction(DateTime now, DateTime from, DateTime to) {
    final total = to.difference(from).inSeconds;
    if (total <= 0) return 0.0;
    return (now.difference(from).inSeconds / total).clamp(0.0, 1.0);
  }

  void _showCitySearch(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _CitySearchSheet(settings: settings),
    );
  }

  void _showMethodSelection(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, sc) => SingleChildScrollView(
          controller: sc,
          child: const _MethodSelectionSheet(),
        ),
      ),
    );
  }

  void _showMonthlyCalendar(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MonthlyCalendarSheet(settings: settings),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// COMPACT PRAYER CARD — 60px height, 16dp radius
// ═════════════════════════════════════════════════════════════

class _CompactPrayerCard extends StatelessWidget {
  final PrayerModel prayer;
  final AppLocalization l10n;
  final bool isEnabled;
  final VoidCallback onBellTap;

  const _CompactPrayerCard({
    required this.prayer,
    required this.l10n,
    required this.isEnabled,
    required this.onBellTap,
  });

  Widget _buildPremiumIcon(String name, bool isNext) {
    // Elegant CustomPainter usage for icons
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _PremiumIconPainter(name: name, isNext: isNext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNext = prayer.isNext;
    final isQuyosh = prayer.name == 'Quyosh';

    return AnimatedScale(
      scale: isNext ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isNext
              ? context.colors.emeraldMid
              : (Theme.of(context).brightness == Brightness.dark
                  ? context.colors.cardBg.withOpacity(0.8)
                  : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isNext
                ? context.colors.softGold
                : (Theme.of(context).brightness == Brightness.dark
                    ? context.colors.emeraldLight.withOpacity(0.1)
                    : const Color(0xFFD4AF37).withOpacity(0.06)),
            width: isNext ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isNext
                  ? context.colors.softGold.withOpacity(0.15)
                  : Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.04 : 0.04),
              blurRadius: isNext ? 12 : 16,
              spreadRadius: isNext ? 1 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildPremiumIcon(prayer.name, isNext),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate(prayer.name),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isNext ? Colors.white : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    prayer.nameArabic,
                    style: GoogleFonts.amiri(
                      fontSize: 12,
                      color: isNext ? Colors.white70 : context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              prayer.formattedTime,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isNext ? context.colors.softGold : context.colors.textPrimary,
              ),
            ),
            if (!isQuyosh) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onBellTap,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    key: ValueKey(isEnabled),
                    size: 22,
                    color: isNext
                        ? (isEnabled ? context.colors.softGold : Colors.white38)
                        : (isEnabled
                            ? context.colors.softGold
                            : context.colors.textMuted.withOpacity(0.5)),
                  ),
                ),
              ),
            ] else
              const SizedBox(width: 34),
          ],
        ),
      ),
    );
  }
}

class _PremiumIconPainter extends CustomPainter {
  final String name;
  final bool isNext;

  _PremiumIconPainter({required this.name, required this.isNext});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    final color = isNext ? Colors.white : const Color(0xFFD4AF37); // softGold
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    switch (name.toLowerCase()) {
      case 'bomdod':
        // Horizon light
        canvas.drawLine(Offset(2, cy + 4), Offset(size.width - 2, cy + 4), paint);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy + 4), radius: 6),
          pi,
          pi,
          false,
          paint..style = PaintingStyle.fill,
        );
        canvas.drawCircle(Offset(cx, cy + 4), 6, glowPaint);
        break;
      case 'quyosh':
        // Minimal sun
        canvas.drawCircle(center, 5, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center, 5, glowPaint);
        for (int i = 0; i < 8; i++) {
          final angle = i * pi / 4;
          canvas.drawLine(
            Offset(cx + 7 * cos(angle), cy + 7 * sin(angle)),
            Offset(cx + 10 * cos(angle), cy + 10 * sin(angle)),
            paint..style = PaintingStyle.stroke,
          );
        }
        break;
      case 'peshin':
        // Clean bright sun
        canvas.drawCircle(center, 6, paint..style = PaintingStyle.fill);
        canvas.drawCircle(center, 6, glowPaint);
        canvas.drawCircle(center, 9, paint..style = PaintingStyle.stroke..strokeWidth = 1.0);
        break;
      case 'asr':
        // Half sun + soft cloud
        canvas.drawCircle(Offset(cx - 2, cy - 2), 5, paint..style = PaintingStyle.fill);
        final cloudPath = Path()
          ..moveTo(6, cy + 4)
          ..quadraticBezierTo(cx, cy - 2, size.width - 4, cy + 4)
          ..lineTo(6, cy + 4);
        canvas.drawPath(cloudPath, paint..style = PaintingStyle.fill..color = color.withOpacity(0.8));
        break;
      case 'shom':
        // Sunset skyline
        canvas.drawLine(Offset(2, cy + 6), Offset(size.width - 2, cy + 6), paint);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy + 6), radius: 6),
          pi,
          pi,
          false,
          paint..style = PaintingStyle.stroke,
        );
        canvas.drawLine(Offset(cx - 3, cy), Offset(cx + 3, cy), paint);
        break;
      case 'xufton':
        // Crescent moon + star
        final moonPath = Path()
          ..addArc(Rect.fromCircle(center: center, radius: 7), -pi / 2, pi * 1.5);
        canvas.drawPath(moonPath, paint);
        canvas.drawCircle(center, 7, glowPaint);
        canvas.drawCircle(Offset(cx + 6, cy - 6), 1.5, paint..style = PaintingStyle.fill);
        break;
      default:
        canvas.drawCircle(center, 4, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumIconPainter old) => old.name != name || old.isNext != isNext;
}

// ═════════════════════════════════════════════════════════════
// SOLAR ARC CUSTOM PAINTER
// ═════════════════════════════════════════════════════════════

class _SolarArcPainter extends CustomPainter {
  final double progress;
  final bool isDaytime;
  final double pulseValue; // 0..1 breathing
  final String sunriseLabel;
  final String sunsetLabel;

  _SolarArcPainter({
    required this.progress,
    required this.isDaytime,
    required this.pulseValue,
    required this.sunriseLabel,
    required this.sunsetLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h - 20;
    final r = w * 0.42;
    final arcRect = Rect.fromCircle(center: Offset(cx, baseY), radius: r);

    // ── 1. Future arc — thin soft emerald ──
    final futureArcPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(arcRect, pi, pi, false, futureArcPaint);

    // ── 2. Passed arc — gold gradient ──
    if (progress > 0) {
      final passedPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFF57F17)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, pi, pi * progress, false, passedPaint);
    }

    // ── 3. Dashed horizon line ──
    final hPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;
    const dashW = 6.0;
    const gapW = 4.0;
    double startX = cx - r - 8;
    final endX = cx + r + 8;
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, baseY),
        Offset((startX + dashW).clamp(startX, endX), baseY),
        hPaint,
      );
      startX += dashW + gapW;
    }

    // ── 4. Sun position on arc ──
    final angle = pi + pi * progress;
    final sx = cx + r * cos(angle);
    final sy = baseY + r * sin(angle);

    if (isDaytime) {
      // Outer pulse glow (breathing)
      final outerGlowRadius = 28.0 + 8.0 * pulseValue;
      final outerGlowPaint = Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFD54F).withOpacity(0.3 + 0.2 * pulseValue),
          const Color(0xFFFFD54F).withOpacity(0.0),
        ]).createShader(
            Rect.fromCircle(center: Offset(sx, sy), radius: outerGlowRadius));
      canvas.drawCircle(Offset(sx, sy), outerGlowRadius, outerGlowPaint);

      // Inner glow ring
      final innerGlowPaint = Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE082).withOpacity(0.6),
          const Color(0xFFFFD54F).withOpacity(0.0),
        ]).createShader(
            Rect.fromCircle(center: Offset(sx, sy), radius: 16));
      canvas.drawCircle(Offset(sx, sy), 16, innerGlowPaint);

      // Sun body
      canvas.drawCircle(
          Offset(sx, sy), 9, Paint()..color = const Color(0xFFFFD54F));
      // Bright center
      canvas.drawCircle(
          Offset(sx, sy), 4.5, Paint()..color = const Color(0xFFFFF8E1));

      // Tiny rays (4 directions, subtle)
      final rayPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.3 + 0.15 * pulseValue)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      const rayLen = 6.0;
      const rayGap = 14.0;
      for (int i = 0; i < 4; i++) {
        final a = i * pi / 2;
        canvas.drawLine(
          Offset(sx + rayGap * cos(a), sy + rayGap * sin(a)),
          Offset(sx + (rayGap + rayLen) * cos(a), sy + (rayGap + rayLen) * sin(a)),
          rayPaint,
        );
      }
    } else {
      // Moon — crescent effect
      final moonPaint = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(Offset(sx, sy), 8, moonPaint);
      // Dark cutout for crescent
      final cutPaint = Paint()..color = const Color(0xFF0D1B2A).withOpacity(0.8);
      canvas.drawCircle(Offset(sx + 4, sy - 3), 6, cutPaint);

      // Moon glow
      final moonGlow = Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withOpacity(0.15 + 0.1 * pulseValue),
          Colors.white.withOpacity(0.0),
        ]).createShader(
            Rect.fromCircle(center: Offset(sx, sy), radius: 20));
      canvas.drawCircle(Offset(sx, sy), 20, moonGlow);
    }

    // ── 5. Sunrise / Sunset labels & Icons ──
    final sTp = TextPainter(
      text: TextSpan(
          text: sunriseLabel,
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final eTp = TextPainter(
      text: TextSpan(
          text: sunsetLabel,
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final sX = cx - r;
    final eX = cx + r;
    final iconY = baseY + 10;

    // --- Sunrise Icon ---
    final sunColor = const Color(0xFFFFD54F);
    final iconPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(Rect.fromCircle(center: Offset(sX, iconY), radius: 5), pi, pi, false, iconPaint);
    canvas.drawLine(Offset(sX - 9, iconY), Offset(sX + 9, iconY), Paint()..color = sunColor..strokeWidth = 1.5..strokeCap=StrokeCap.round);
    canvas.drawLine(Offset(sX, iconY - 7), Offset(sX, iconY - 9), Paint()..color = sunColor..strokeWidth = 1.5..strokeCap=StrokeCap.round);
    canvas.drawLine(Offset(sX - 5, iconY - 5), Offset(sX - 6.5, iconY - 6.5), Paint()..color = sunColor..strokeWidth = 1.5..strokeCap=StrokeCap.round);
    canvas.drawLine(Offset(sX + 5, iconY - 5), Offset(sX + 6.5, iconY - 6.5), Paint()..color = sunColor..strokeWidth = 1.5..strokeCap=StrokeCap.round);
    
    sTp.paint(canvas, Offset(sX - sTp.width / 2, iconY + 8));

    // --- Sunset Icon ---
    final sunsetColor = const Color(0xFFFF8A65);
    canvas.drawArc(Rect.fromCircle(center: Offset(eX, iconY), radius: 5), pi, pi, false, Paint()..color = sunsetColor..style=PaintingStyle.fill);
    canvas.drawLine(Offset(eX - 9, iconY), Offset(eX + 9, iconY), Paint()..color = sunsetColor..strokeWidth = 1.5..strokeCap=StrokeCap.round);
    
    eTp.paint(canvas, Offset(eX - eTp.width / 2, iconY + 8));
  }

  @override
  bool shouldRepaint(_SolarArcPainter old) =>
      old.progress != progress ||
      old.isDaytime != isDaytime ||
      old.pulseValue != pulseValue;
}

// ═════════════════════════════════════════════════════════════
// CITY SEARCH SHEET  (unchanged)
// ═════════════════════════════════════════════════════════════

class _CitySearchSheet extends ConsumerStatefulWidget {
  final SettingsState settings;
  const _CitySearchSheet({required this.settings});

  @override
  ConsumerState<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends ConsumerState<_CitySearchSheet> {
  final List<Map<String, dynamic>> _cities = [
    {'name': 'Toshkent', 'lat': 41.2995, 'lng': 69.2401},
    {'name': 'Samarqand', 'lat': 39.6270, 'lng': 66.9750},
    {'name': 'Buxoro', 'lat': 39.7747, 'lng': 64.4286},
    {'name': 'Andijon', 'lat': 40.7821, 'lng': 72.3442},
    {'name': 'Namangan', 'lat': 40.9983, 'lng': 71.6726},
    {'name': 'Farg\'ona', 'lat': 40.3833, 'lng': 71.7833},
    {'name': 'Qarshi', 'lat': 38.8610, 'lng': 65.7847},
    {'name': 'Nukus', 'lat': 42.4533, 'lng': 59.6103},
    {'name': 'Urganch', 'lat': 41.5500, 'lng': 60.6333},
    {'name': 'Xiva', 'lat': 41.3783, 'lng': 60.3639},
    {'name': 'Termiz', 'lat': 37.2242, 'lng': 67.2783},
    {'name': 'Guliston', 'lat': 40.4897, 'lng': 68.7842},
    {'name': 'Jizzax', 'lat': 40.1158, 'lng': 67.8422},
    {'name': 'Navoiy', 'lat': 40.0844, 'lng': 65.3792},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCities = _cities
        .where((city) =>
            city['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ref.watch(localizationProvider).translate('select_city'),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.inter(color: context.colors.textPrimary),
            decoration: InputDecoration(
              hintText: ref.watch(localizationProvider).translate('search_city_hint'),
              hintStyle: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: context.colors.softGold),
              filled: true,
              fillColor: context.colors.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: () async {
              await ref.read(settingsProvider.notifier).setAutoLocation(true);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ref.read(localizationProvider).translate('gps_enabled'))),
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.softGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.my_location, color: context.colors.softGold, size: 20),
            ),
            title: Text(
              ref.watch(localizationProvider).translate('my_location_gps'),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: context.colors.softGold),
            ),
            subtitle: Text(
              ref.watch(localizationProvider).translate('auto_detection'),
              style: GoogleFonts.inter(fontSize: 12, color: context.colors.textMuted),
            ),
          ),
          Divider(height: 32, color: context.colors.emeraldLight),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                return ListTile(
                  onTap: () async {
                    await ref.read(settingsProvider.notifier).setCity(
                      name: city['name'],
                      lat: city['lat'],
                      lng: city['lng'],
                    );
                    Navigator.pop(context);
                  },
                  title: Text(
                    ref.watch(localizationProvider).translate(city['name']),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                  ),
                  trailing: Icon(Icons.chevron_right, size: 18, color: context.colors.textMuted),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// METHOD SELECTION SHEET
// ═════════════════════════════════════════════════════════════

class _MethodSelectionSheet extends ConsumerWidget {
  const _MethodSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentMethodState = ref.watch(prayerMethodProvider);
    final lang = ref.watch(settingsProvider).language;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.watch(localizationProvider).translate('calc_settings'),
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.watch(localizationProvider).translate('calc_method_hint'),
                        style: GoogleFonts.inter(fontSize: 12, color: context.colors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.colors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Auto Detect Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: currentMethodState.isAutoDetect
                    ? context.colors.softGold.withOpacity(0.1)
                    : context.colors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: currentMethodState.isAutoDetect
                      ? context.colors.softGold.withOpacity(0.5)
                      : context.colors.emeraldLight.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentMethodState.isAutoDetect
                          ? context.colors.softGold
                          : context.colors.textMuted.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome,
                        color: currentMethodState.isAutoDetect ? Colors.white : context.colors.textMuted, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ref.watch(localizationProvider).translate('auto_detect_method'),
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                        Text(ref.watch(localizationProvider).translate('auto_detect_hint'),
                            style: GoogleFonts.inter(fontSize: 12, color: context.colors.textMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: currentMethodState.isAutoDetect,
                    onChanged: (val) => ref.read(prayerMethodProvider.notifier).setAutoDetect(val),
                    activeColor: context.colors.softGold,
                    activeTrackColor: context.colors.softGold.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Method list grouped by region
            IgnorePointer(
              ignoring: currentMethodState.isAutoDetect,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: currentMethodState.isAutoDetect ? 0.4 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildGroupedMethodList(context, ref, currentMethodState, lang),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Madhab
            Text(ref.watch(localizationProvider).translate('madhab_title'),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.softGold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMadhabButton(context, ref, settings, 'Hanafi', ref.watch(localizationProvider).translate('hanafi')),
                const SizedBox(width: 12),
                _buildMadhabButton(context, ref, settings, 'Shafi', ref.watch(localizationProvider).translate('shafi')),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedMethodList(BuildContext context, WidgetRef ref, PrayerMethodState st, String lang) {
    final grouped = groupedMethods;
    final widgets = <Widget>[];
    for (final region in PrayerRegion.values) {
      final methods = grouped[region];
      if (methods == null || methods.isEmpty) continue;
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(getRegionHeader(region, lang),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.softGold, letterSpacing: 0.5)),
      ));
      for (final method in methods) {
        final isSelected = st.method == method;
        final title = method.displayName(lang);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => ref.read(prayerMethodProvider.notifier).updateMethod(method),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.colors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isSelected ? context.colors.softGold : context.colors.emeraldLight.withOpacity(0.1),
                      width: isSelected ? 2 : 1),
                  boxShadow: isSelected
                      ? [BoxShadow(color: context.colors.softGold.withOpacity(0.15), blurRadius: 15, spreadRadius: 2)]
                      : null,
                ),
                child: Row(children: [
                  Expanded(
                      child: Text(title,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? context.colors.softGold : context.colors.textPrimary))),
                  Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 22, color: isSelected ? context.colors.softGold : context.colors.textMuted),
                ]),
              ),
            ),
          ),
        ));
      }
    }
    return widgets;
  }

  Widget _buildMadhabButton(BuildContext context, WidgetRef ref, SettingsState settings, String value, String label) {
    final isSelected = settings.madhab == value;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(settingsProvider.notifier).setMadhab(value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? context.colors.emeraldMid : context.colors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? context.colors.softGold : context.colors.emeraldLight.withOpacity(0.1),
                  width: isSelected ? 2 : 1),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 16, color: isSelected ? context.colors.softGold : context.colors.textMuted),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : context.colors.textPrimary)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// MONTHLY CALENDAR SHEET
// ═════════════════════════════════════════════════════════════

class _MonthlyCalendarSheet extends StatefulWidget {
  final SettingsState settings;
  const _MonthlyCalendarSheet({required this.settings});

  @override
  State<_MonthlyCalendarSheet> createState() => _MonthlyCalendarSheetState();
}

class _MonthlyCalendarSheetState extends State<_MonthlyCalendarSheet> {
  late List<DailyPrayerTimes> monthlyPrayers;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateMonthly();
  }

  Future<void> _calculateMonthly() async {
    double lat = 41.2995;
    double lng = 69.2401;

    if (widget.settings.isAutoLocation) {
      try {
        final pos = await LocationService.getCurrentLocation();
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (e) {
        if (widget.settings.latitude != null && widget.settings.longitude != null) {
          lat = widget.settings.latitude!;
          lng = widget.settings.longitude!;
        }
      }
    } else if (widget.settings.latitude != null && widget.settings.longitude != null) {
      lat = widget.settings.latitude!;
      lng = widget.settings.longitude!;
    }

    await Future.delayed(const Duration(milliseconds: 100));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final container = ProviderScope.containerOf(context);
    final currentMethodState = container.read(prayerMethodProvider);

    List<DailyPrayerTimes> list = [];
    for (int i = 0; i < 30; i++) {
      final d = today.add(Duration(days: i));
      final prayers = PrayerTimesService.calculateForDate(
        date: d,
        latitude: lat,
        longitude: lng,
        method: currentMethodState.method.apiName,
        madhab: widget.settings.madhab,
      );
      list.add(prayers);
    }

    if (mounted) {
      setState(() {
        monthlyPrayers = list;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // ── TOP HEADER ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            IconButton(
              icon: Icon(Icons.close_rounded, color: context.colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Oylik Taqvim",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ]),
        ),

        if (isLoading)
          Expanded(child: Center(child: CircularProgressIndicator(color: context.colors.softGold)))
        else
          Expanded(child: _buildTable(isDark)),
      ]),
    );
  }

  Widget _buildTable(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(children: [
            // ── Oylik yozuv ustunlari (Header) ──
            Container(
              color: context.colors.emeraldMid,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                _headerCell('Sana', flex: 2),
                _headerCell('Bomdod'),
                _headerCell('Quyosh'),
                _headerCell('Peshin'),
                _headerCell('Asr'),
                _headerCell('Shom'),
                _headerCell('Xufton'),
              ]),
            ),
            
            // ── Kunlik namozlar (Body) ──
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: monthlyPrayers.length,
                itemExtent: 52.0, // Hardcoded extent for 120 FPS scrolling O(1) layout
                itemBuilder: (context, index) {
                  final day = monthlyPrayers[index];
                  final date = day.date;
                  final dateStr = "${date.day} ${_getMonthName(date.month)}";
                  final p = day.prayers;

                  final now = DateTime.now();
                  final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? context.colors.softGold.withOpacity(0.15)
                          : (index.isEven ? Colors.transparent : context.colors.textMuted.withOpacity(0.04)),
                      border: Border(bottom: BorderSide(color: context.colors.emeraldLight.withOpacity(0.1), width: 1)),
                    ),
                    child: Row(children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                              color: isToday ? context.colors.softGold : context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      _timeCell(p[0].formattedTime, isToday),
                      _timeCell(p[1].formattedTime, isToday),
                      _timeCell(p[2].formattedTime, isToday),
                      _timeCell(p[3].formattedTime, isToday),
                      _timeCell(p[4].formattedTime, isToday),
                      _timeCell(p[5].formattedTime, isToday),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _headerCell(String title, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(title,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _timeCell(String time, bool isToday) {
    return Expanded(
      flex: 2,
      child: Center(
        child: Text(time,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? context.colors.softGold : context.colors.textSecondary)),
      ),
    );
  }

  String _getMonthName(int m) {
    const months = ['yan', 'fev', 'mar', 'apr', 'may', 'iun', 'iul', 'avg', 'sen', 'okt', 'noy', 'dek'];
    return months[m - 1];
  }
}
