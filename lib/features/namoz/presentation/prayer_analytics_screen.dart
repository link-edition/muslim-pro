import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';
import 'package:muslim_pro/features/namoz/prayer_tracker_provider.dart';
import 'package:muslim_pro/features/namoz/streak_provider.dart';
import 'package:muslim_pro/features/namoz/qaza_manager_provider.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/features/namoz/presentation/monthly_summary_screen.dart';

// ─── Color Constants (mirrored from home_screen) ───
class _C {
  static const darkBg = Color(0xFF040E0A);
  static const cardDark = Color(0xFF0A1F17);
  static const softGold = Color(0xFFD4AF37);
  static const textWhite = Color(0xFFF5F5F0);
  static const textMuted = Color(0xFF7A8B84);
  static const deepEmerald = Color(0xFF0F3D2E);
  static const creamTop = Color(0xFFF8F3EA);
  static const creamBot = Color(0xFFEBE3D4);
  static const lightMuted = Color(0xFF5E6D63);
  static const goldRich = Color(0xFFD4AF37);
}

class PrayerAnalyticsScreen extends ConsumerStatefulWidget {
  const PrayerAnalyticsScreen({super.key});

  @override
  ConsumerState<PrayerAnalyticsScreen> createState() => _PrayerAnalyticsScreenState();
}

class _PrayerAnalyticsScreenState extends ConsumerState<PrayerAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<DailyPrayerRecord> _allRecords = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await PrayerTrackerDB.getAllRecords();
    if (mounted) {
      setState(() {
        _allRecords = records;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streak = ref.watch(streakProvider);
    final qaza = ref.watch(qazaManagerProvider);

    return Scaffold(
      backgroundColor: isDark ? _C.darkBg : _C.creamTop,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            toolbarHeight: 64,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? _C.darkBg : _C.creamTop,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? _C.textWhite : _C.deepEmerald,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Statistika',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? _C.textWhite : _C.deepEmerald,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MonthlySummaryScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: isDark ? _C.softGold : _C.deepEmerald,
                ),
                tooltip: 'Oylik Tafakkur',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : _C.deepEmerald.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark
                        ? _C.softGold.withOpacity(0.15)
                        : _C.deepEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: isDark ? _C.softGold : _C.deepEmerald,
                  unselectedLabelColor: isDark ? _C.textMuted : _C.lightMuted,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Hafta'),
                    Tab(text: 'Oy'),
                    Tab(text: 'Yil'),
                  ],
                ),
              ),
            ),
          ),

          // ── Streak / Qaza Summary Bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  _MiniStatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Streak',
                    value: '${streak.currentStreak}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _MiniStatCard(
                    icon: Icons.emoji_events_outlined,
                    label: 'Rekord',
                    value: '${streak.longestStreak}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _MiniStatCard(
                    icon: Icons.restore_rounded,
                    label: 'Qazo',
                    value: '${qaza.remainingQaza}',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // ── Tab Content ──
          SliverFillRemaining(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: isDark ? _C.softGold : _C.deepEmerald,
                      strokeWidth: 2,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _WeeklyView(records: _allRecords, isDark: isDark),
                      _MonthlyView(records: _allRecords, isDark: isDark),
                      _YearlyView(records: _allRecords, isDark: isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MINI STAT CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? _C.softGold : _C.deepEmerald;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : _C.deepEmerald.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : _C.deepEmerald.withOpacity(0.06),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: accent.withOpacity(0.6)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? _C.textWhite : _C.deepEmerald,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? _C.textMuted : _C.lightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WEEKLY VIEW — 7-day horizontal scroll with micro dots
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _WeeklyView extends StatelessWidget {
  final List<DailyPrayerRecord> records;
  final bool isDark;

  const _WeeklyView({required this.records, required this.isDark});

  List<DailyPrayerRecord> _getLast7Days() {
    final now = DateTime.now();
    final List<DailyPrayerRecord> result = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final found = records.where((r) => r.date == key);
      if (found.isNotEmpty) {
        result.add(found.first);
      } else {
        result.add(DailyPrayerRecord(date: key));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getLast7Days();
    final accent = isDark ? _C.softGold : _C.deepEmerald;

    // Weekly completion %
    int totalPrayed = 0;
    int totalPossible = 35; // 7 * 5
    for (var d in days) {
      totalPrayed += d.completedCount;
    }
    final weeklyPct = (totalPrayed / totalPossible * 100).round();

    final dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Weekly Completion ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : _C.deepEmerald.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Haftalik natija',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? _C.textWhite : _C.deepEmerald,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$weeklyPct%',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalPrayed / $totalPossible namoz',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? _C.textMuted : _C.lightMuted,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: totalPrayed / totalPossible,
                    minHeight: 4,
                    backgroundColor: accent.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 7-Day Cards ──
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final record = days[index];
                final date = DateTime.parse(record.date);
                final dayName = dayNames[date.weekday - 1];
                final isToday = index == 6;
                final statuses = [
                  record.fajr, record.dhuhr, record.asr,
                  record.maghrib, record.isha,
                ];

                return Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isToday
                        ? accent.withOpacity(isDark ? 0.12 : 0.08)
                        : (isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday
                          ? accent.withOpacity(0.25)
                          : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : _C.deepEmerald.withOpacity(0.06)),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? accent
                              : (isDark ? _C.textMuted : _C.lightMuted),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? _C.textWhite : _C.deepEmerald,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ── 5 Micro dots ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: statuses.map((s) {
                          Color dotColor;
                          if (s == PrayerStatus.prayed) {
                            dotColor = accent;
                          } else if (s == PrayerStatus.qazaCompleted) {
                            dotColor = _C.softGold.withOpacity(0.6);
                          } else if (s == PrayerStatus.missed) {
                            dotColor = isDark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.1);
                          } else {
                            dotColor = isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.06);
                          }
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      // Completion
                      Text(
                        '${record.completedCount}/5',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? _C.textMuted : _C.lightMuted,
                        ),
                      ),
                      // 5/5 gold underline
                      if (record.isAllCompleted)
                        Container(
                          width: 20,
                          height: 1.5,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: _C.softGold,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MONTHLY VIEW — Calendar grid with 5-dot indicators
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MonthlyView extends StatefulWidget {
  final List<DailyPrayerRecord> records;
  final bool isDark;

  const _MonthlyView({required this.records, required this.isDark});

  @override
  State<_MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<_MonthlyView> {
  late DateTime _selectedMonth;
  late Map<String, DailyPrayerRecord> _recordMap;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _buildRecordMap();
  }

  void _buildRecordMap() {
    _recordMap = {};
    for (var r in widget.records) {
      _recordMap[r.date] = r;
    }
  }

  @override
  void didUpdateWidget(covariant _MonthlyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildRecordMap();
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() => _selectedMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isDark ? _C.softGold : _C.deepEmerald;
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
    final ym = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

    // Monthly stats
    int mPrayed = 0, mQaza = 0, mTotal = daysInMonth * 5;
    int longestStreak = 0, currentStreak = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final key = '$ym-${d.toString().padLeft(2, '0')}';
      final rec = _recordMap[key];
      if (rec != null) {
        mPrayed += rec.prayedCount;
        for (var s in [rec.fajr, rec.dhuhr, rec.asr, rec.maghrib, rec.isha]) {
          if (s == PrayerStatus.qazaCompleted) mQaza++;
        }
        if (rec.isAllCompleted) {
          currentStreak++;
          if (currentStreak > longestStreak) longestStreak = currentStreak;
        } else {
          currentStreak = 0;
        }
      } else {
        currentStreak = 0;
      }
    }

    final monthNames = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    final dayHeaders = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Month selector ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: widget.isDark ? _C.textWhite : _C.deepEmerald,
                ),
              ),
              Text(
                '${monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? _C.textWhite : _C.deepEmerald,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: widget.isDark ? _C.textWhite : _C.deepEmerald,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Day headers ──
          Row(
            children: dayHeaders.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? _C.textMuted : _C.lightMuted,
                  ),
                ),
              ),
            )).toList(),
          ),

          const SizedBox(height: 8),

          // ── Calendar Grid ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemCount: (firstWeekday - 1) + daysInMonth,
            itemBuilder: (context, index) {
              // Empty cells for offset
              if (index < firstWeekday - 1) return const SizedBox();

              final day = index - (firstWeekday - 1) + 1;
              if (day > daysInMonth) return const SizedBox();

              final key = '$ym-${day.toString().padLeft(2, '0')}';
              final rec = _recordMap[key];
              final now = DateTime.now();
              final isToday = day == now.day &&
                  _selectedMonth.month == now.month &&
                  _selectedMonth.year == now.year;

              final statuses = rec != null
                  ? [rec.fajr, rec.dhuhr, rec.asr, rec.maghrib, rec.isha]
                  : List.filled(5, PrayerStatus.unknown);

              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday
                      ? accent.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday
                      ? Border.all(color: accent.withOpacity(0.2))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? accent
                            : (widget.isDark ? _C.textWhite : _C.deepEmerald),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 5 micro dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: statuses.map((s) {
                        Color c;
                        if (s == PrayerStatus.prayed) {
                          c = accent;
                        } else if (s == PrayerStatus.qazaCompleted) {
                          c = _C.softGold.withOpacity(0.5);
                        } else if (s == PrayerStatus.missed) {
                          c = widget.isDark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.1);
                        } else {
                          c = widget.isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04);
                        }
                        return Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Monthly Stats ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.05)
                    : _C.deepEmerald.withOpacity(0.06),
              ),
            ),
            child: Column(
              children: [
                _StatRow(
                  label: 'Jami o\'qilgan',
                  value: '$mPrayed / $mTotal',
                  isDark: widget.isDark,
                ),
                const SizedBox(height: 10),
                _StatRow(
                  label: 'Bajarilish darajasi',
                  value: '${mTotal > 0 ? (mPrayed / mTotal * 100).round() : 0}%',
                  isDark: widget.isDark,
                ),
                const SizedBox(height: 10),
                _StatRow(
                  label: 'Qazo o\'qildi',
                  value: '$mQaza',
                  isDark: widget.isDark,
                ),
                const SizedBox(height: 10),
                _StatRow(
                  label: 'Eng uzun streak',
                  value: '$longestStreak kun',
                  isDark: widget.isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// YEARLY VIEW — Minimal bar chart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _YearlyView extends StatelessWidget {
  final List<DailyPrayerRecord> records;
  final bool isDark;

  const _YearlyView({required this.records, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? _C.softGold : _C.deepEmerald;
    final now = DateTime.now();
    final year = now.year;

    // Calculate monthly completion rates
    final List<double> monthlyRates = [];
    final monthAbbrs = ['Y', 'F', 'M', 'A', 'M', 'I', 'I', 'A', 'S', 'O', 'N', 'D'];

    int yearTotal = 0, yearPrayed = 0;

    for (int m = 1; m <= 12; m++) {
      final ym = '$year-${m.toString().padLeft(2, '0')}';
      final monthRecords = records.where((r) => r.date.startsWith(ym)).toList();
      final daysInMonth = DateTime(year, m + 1, 0).day;
      final total = daysInMonth * 5;
      int prayed = 0;
      for (var r in monthRecords) {
        prayed += r.completedCount;
      }
      yearTotal += total;
      yearPrayed += prayed;
      monthlyRates.add(total > 0 ? prayed / total : 0);
    }

    final yearPct = yearTotal > 0 ? (yearPrayed / yearTotal * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Year Summary ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : _C.deepEmerald.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$year yil',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? _C.textWhite : _C.deepEmerald,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$yearPct%',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$yearPrayed / $yearTotal namoz',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? _C.textMuted : _C.lightMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Bar Chart ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : _C.deepEmerald.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oylik natija',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? _C.textWhite : _C.deepEmerald,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(12, (i) {
                      final rate = monthlyRates[i];
                      final isCurrentMonth = i == now.month - 1;
                      final barHeight = math.max(4.0, rate * 130);

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Percentage label on top
                            if (rate > 0)
                              Text(
                                '${(rate * 100).round()}',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? _C.textMuted : _C.lightMuted,
                                ),
                              ),
                            const SizedBox(height: 4),
                            // Bar
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                              width: 14,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: isCurrentMonth
                                    ? accent
                                    : accent.withOpacity(rate > 0 ? 0.3 : 0.06),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Month label
                            Text(
                              monthAbbrs[i],
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: isCurrentMonth
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isCurrentMonth
                                    ? accent
                                    : (isDark ? _C.textMuted : _C.lightMuted),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STAT ROW — Simple label : value pair
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? _C.textMuted : _C.lightMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? _C.textWhite : _C.deepEmerald,
          ),
        ),
      ],
    );
  }
}
