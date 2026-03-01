import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/tasbeh/data/zikr_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/core/localization.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  List<ZikrSession> _sessions = [];
  bool _isLoading = true;
  int _todayCount = 0;
  int _streak = 0;
  int _totalCount = 0;
  Map<String, int> _dailyCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sessions = await ZikrDatabase.getSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateStats() {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    
    _totalCount = 0;
    _dailyCounts = {};

    for (var s in _sessions) {
      _totalCount += s.count;
      final key = DateFormat('yyyy-MM-dd').format(s.date);
      _dailyCounts[key] = (_dailyCounts[key] ?? 0) + s.count;
    }
    
    _todayCount = _dailyCounts[todayStr] ?? 0;

    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(checkDate);
      if ((_dailyCounts[key] ?? 0) > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    _streak = streak;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: context.colors.textPrimary),
        ),
        title: Text(
          l10n.translate('history_stats'),
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.softGold))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatCard(title: l10n.translate('today'), value: '$_todayCount', icon: Icons.today),
                      const SizedBox(width: 12),
                      _StatCard(title: l10n.translate('streak'), value: '$_streak', icon: Icons.local_fire_department),
                      const SizedBox(width: 12),
                      _StatCard(title: l10n.translate('all'), value: '$_totalCount', icon: Icons.analytics),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.translate('last_7_days'),
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bar Chart
                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                    decoration: BoxDecoration(
                      color: context.colors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.colors.softGold.withOpacity(0.1)),
                    ),
                    child: _buildBarChart(l10n),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildBarChart(AppLocalization l10n) {
    final now = DateTime.now();
    List<double> values = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      values.add((_dailyCounts[key] ?? 0).toDouble());
    }

    double maxVal = values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 100;

    final weekDays = [
      l10n.translate('mon'),
      l10n.translate('tue'),
      l10n.translate('wed'),
      l10n.translate('thu'),
      l10n.translate('fri'),
      l10n.translate('sat'),
      l10n.translate('sun')
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
        final dayName = weekDays[date.weekday - 1];
        final heightFactor = values[index] / maxVal;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (values[index] > 0)
              Text(
                '${values[index].toInt()}',
                style: GoogleFonts.inter(color: context.colors.goldText, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: (heightFactor * 130).clamp(4, 130),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    index == 6 ? context.colors.goldText : context.colors.goldText.withOpacity(0.8),
                    index == 6 ? context.colors.goldText.withOpacity(0.7) : context.colors.goldText.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: index == 6 ? [BoxShadow(color: context.colors.cardShadow, blurRadius: 8)] : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayName,
              style: GoogleFonts.inter(
                color: index == 6 ? context.colors.goldText : context.colors.textMuted,
                fontSize: 10,
                fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: context.colors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.softGold.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.goldText, size: 22),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
            Text(title, style: GoogleFonts.inter(fontSize: 11, color: context.colors.textMuted)),
          ],
        ),
      ),
    );
  }
}
