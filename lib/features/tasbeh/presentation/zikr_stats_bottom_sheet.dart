import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/tasbeh/data/zikr_database.dart';
import 'package:intl/intl.dart';

class ZikrStatsBottomSheet extends StatefulWidget {
  const ZikrStatsBottomSheet({super.key});

  @override
  State<ZikrStatsBottomSheet> createState() => _ZikrStatsBottomSheetState();
}

class _ZikrStatsBottomSheetState extends State<ZikrStatsBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ZikrSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sessions = await ZikrDatabase.getSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Zikrlar Statistikasi',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.softGold,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.softGold,
            tabs: const [
              Tab(text: 'Haftalik'),
              Tab(text: 'Oylik'),
              Tab(text: 'Yillik'),
            ],
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.softGold))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeeklyChart(),
                    _buildMonthlyChart(),
                    _buildYearlyList(),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    
    Map<int, double> dailyCounts = {for (var i = 0; i < 7; i++) i: 0};
    
    for (var session in _sessions) {
      if (session.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && 
          session.date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
        int dayIndex = session.date.weekday - 1;
        dailyCounts[dayIndex] = (dailyCounts[dayIndex] ?? 0) + session.count;
      }
    }

    if (dailyCounts.values.every((v) => v == 0)) {
      return Center(
        child: Text(
          'Bu hafta hali zikr qilinmagan',
          style: GoogleFonts.poppins(color: AppColors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: dailyCounts.values.reduce((a, b) => a > b ? a : b) + 10,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['D', 'S', 'C', 'P', 'J', 'S', 'Y'];
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) return const SizedBox();
                  return Text(
                    days[index],
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: dailyCounts[i]!,
                  color: AppColors.softGold,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    Map<int, double> weekCounts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0};
    
    for (var session in _sessions) {
      if (session.date.isAfter(firstDayOfMonth.subtract(const Duration(seconds: 1))) && 
          session.date.isBefore(lastDayOfMonth.add(const Duration(seconds: 1)))) {
        int weekIndex = ((session.date.day - 1) / 7).floor();
        if (weekIndex > 4) weekIndex = 4;
        weekCounts[weekIndex] = (weekCounts[weekIndex] ?? 0) + session.count;
      }
    }

    if (weekCounts.values.every((v) => v == 0)) {
      return Center(
        child: Text(
          'Bu oy hali zikr qilinmagan',
          style: GoogleFonts.poppins(color: AppColors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: weekCounts.values.reduce((a, b) => a > b ? a : b) + 20,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt() + 1}-h',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(5, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weekCounts[i]!,
                  color: AppColors.softGold,
                  width: 30,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildYearlyList() {
    final now = DateTime.now();
    Map<String, int> monthlyTotals = {};
    
    for (var session in _sessions) {
      if (session.date.year == now.year) {
        String month = DateFormat.MMMM('uz').format(session.date);
        monthlyTotals[month] = (monthlyTotals[month] ?? 0) + session.count;
      }
    }

    final sortedMonths = monthlyTotals.entries.toList()
      ..sort((a, b) => DateFormat.MMMM('uz').parse(a.key).month.compareTo(DateFormat.MMMM('uz').parse(b.key).month));

    if (sortedMonths.isEmpty) {
      return Center(
        child: Text(
          'Bu yil hali zikr qilinmagan',
          style: GoogleFonts.poppins(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final entry = sortedMonths[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.softGold.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${entry.value} marta',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
