import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';
import 'package:muslim_pro/core/spiritual_progress_provider.dart';

// ─── Colors ───
class _C {
  static const darkBg = Color(0xFF040E0A);
  static const softGold = Color(0xFFD4AF37);
  static const textWhite = Color(0xFFF5F5F0);
  static const textMuted = Color(0xFF7A8B84);
  static const deepEmerald = Color(0xFF0F3D2E);
  static const creamTop = Color(0xFFF8F3EA);
  static const lightMuted = Color(0xFF5E6D63);
}

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  ConsumerState<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  bool _loading = true;
  int _totalPrayers = 0;
  int _prayedCount = 0;
  int _missedCount = 0;
  int _qazaCount = 0;
  int _longestStreak = 0;
  double _completionRate = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final ym = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final records = await PrayerTrackerDB.getRecordsInMonth(ym);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    int prayed = 0, missed = 0, qaza = 0;
    int streak = 0, longestStreak = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final key = '$ym-${d.toString().padLeft(2, '0')}';
      final found = records.where((r) => r.date == key);
      if (found.isNotEmpty) {
        final r = found.first;
        for (var s in [r.fajr, r.dhuhr, r.asr, r.maghrib, r.isha]) {
          if (s == PrayerStatus.prayed) prayed++;
          if (s == PrayerStatus.missed) missed++;
          if (s == PrayerStatus.qazaCompleted) qaza++;
        }
        if (r.isAllCompleted) {
          streak++;
          if (streak > longestStreak) longestStreak = streak;
        } else {
          streak = 0;
        }
      } else {
        streak = 0;
      }
    }

    final total = daysInMonth * 5;

    if (mounted) {
      setState(() {
        _totalPrayers = total;
        _prayedCount = prayed;
        _missedCount = missed;
        _qazaCount = qaza;
        _longestStreak = longestStreak;
        _completionRate = total > 0 ? (prayed + qaza) / total : 0;
        _loading = false;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getReflectionMessage() {
    if (_completionRate >= 0.85) {
      return 'Izchilligingiz ruhiy yuksalish keltiradi.';
    } else if (_completionRate >= 0.5) {
      return 'Har bir kun — yangi imkoniyat.';
    } else {
      return 'Muloyim izchillik qalbni mustahkamlaydi.';
    }
  }

  String _getMonthName() {
    final now = DateTime.now();
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  String _getHijriApprox() {
    // Approximate Hijri month — simplified
    final now = DateTime.now();
    // Using a rough offset. For production, use hijri_calendar package.
    final hijriMonths = [
      'Muharram', 'Safar', 'Rabi\' al-Avval', 'Rabi\' al-Oxir',
      'Jumada al-Ula', 'Jumada al-Oxira', 'Rajab', 'Sha\'ban',
      'Ramazon', 'Shavvol', 'Zulqa\'da', 'Zulhijja',
    ];
    // Approximate: March 2026 ≈ Ramadan 1447
    final approxMonth = ((now.month + 5) % 12);
    return hijriMonths[approxMonth];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? _C.softGold : _C.deepEmerald;
    final sp = ref.watch(spiritualProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF061914),
                    const Color(0xFF071E17),
                    const Color(0xFF0B2B22),
                    const Color(0xFF061914),
                  ]
                : [
                    _C.creamTop,
                    const Color(0xFFF4EFE6),
                    const Color(0xFFEBE3D4),
                    _C.creamTop,
                  ],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: accent,
                    strokeWidth: 2,
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Close button ──
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark ? _C.textMuted : _C.lightMuted,
                              size: 22,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Month Title ──
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Oylik Tafakkur',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent.withOpacity(0.6),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getMonthName(),
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? _C.textWhite : _C.deepEmerald,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getHijriApprox(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? _C.textMuted : _C.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Main Percentage Circle ──
                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: _completionRate,
                                    strokeWidth: 4,
                                    backgroundColor: accent.withOpacity(0.08),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accent.withOpacity(0.6),
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${(_completionRate * 100).round()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? _C.textWhite : _C.deepEmerald,
                                      ),
                                    ),
                                    Text(
                                      'bajarildi',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: isDark ? _C.textMuted : _C.lightMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Gold divider ──
                        Center(
                          child: Container(
                            width: 60,
                            height: 1,
                            color: accent.withOpacity(0.15),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Stats Grid ──
                        _buildStatRow(
                          'Jami o\'qilgan',
                          '$_prayedCount / $_totalPrayers',
                          Icons.check_circle_outline_rounded,
                          accent,
                          isDark,
                        ),
                        _buildDivider(accent),
                        _buildStatRow(
                          'Qazo o\'qilgan',
                          '$_qazaCount',
                          Icons.restore_rounded,
                          accent,
                          isDark,
                        ),
                        _buildDivider(accent),
                        _buildStatRow(
                          'O\'tkazilgan',
                          '$_missedCount',
                          Icons.circle_outlined,
                          isDark ? _C.textMuted : _C.lightMuted,
                          isDark,
                        ),
                        _buildDivider(accent),
                        _buildStatRow(
                          'Eng uzun streak',
                          '$_longestStreak kun',
                          Icons.local_fire_department_rounded,
                          accent,
                          isDark,
                        ),
                        _buildDivider(accent),
                        _buildStatRow(
                          'Ruhiy daraja',
                          sp.level.nameUz,
                          Icons.terrain_rounded,
                          accent,
                          isDark,
                        ),

                        const SizedBox(height: 40),

                        // ── Gold divider ──
                        Center(
                          child: Container(
                            width: 40,
                            height: 1,
                            color: accent.withOpacity(0.12),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Reflection Message ──
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _getReflectionMessage(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: accent.withOpacity(0.7),
                                height: 1.5,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Subtle footnote ──
                        Center(
                          child: Text(
                            '— Amal',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? _C.textMuted.withOpacity(0.4)
                                  : _C.lightMuted.withOpacity(0.4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor.withOpacity(0.5)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? _C.textMuted : _C.lightMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? _C.textWhite : _C.deepEmerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color accent) {
    return Container(
      height: 0.5,
      color: accent.withOpacity(0.06),
    );
  }
}
