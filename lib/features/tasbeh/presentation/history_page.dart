import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/tasbeh/data/zikr_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ZikrSession> _sessions = [];
  bool _isLoading = true;
  int _todayCount = 0;
  int _streak = 0;
  int _totalCount = 0;
  Map<DateTime, int> _heatmapData = {};
  Map<String, int> _dailyCounts = {};
  DateTime _currentMonth = DateTime.now();

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
    Map<DateTime, int> heatmap = {};

    for (var s in _sessions) {
      _totalCount += s.count;
      final key = DateFormat('yyyy-MM-dd').format(s.date);
      _dailyCounts[key] = (_dailyCounts[key] ?? 0) + s.count;
      
      final dateKey = DateTime(s.date.year, s.date.month, s.date.day);
      heatmap[dateKey] = (heatmap[dateKey] ?? 0) + s.count;
    }
    
    _heatmapData = heatmap;
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(
          'Tarix va Statistika v1.6',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.softGold))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatCard(title: 'Bugun', value: '$_todayCount', icon: Icons.today),
                      const SizedBox(width: 12),
                      _StatCard(title: 'Davomiylik', value: '$_streak', icon: Icons.local_fire_department),
                      const SizedBox(width: 12),
                      _StatCard(title: 'Jami', value: '$_totalCount', icon: Icons.analytics),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Oxirgi 7 kun',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bar Chart
                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.softGold.withOpacity(0.1)),
                    ),
                    child: _buildBarChart(),
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    'Faollik xaritasi',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  
                  // Heatmap with Uzbek Labels Overlaying English ones
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.softGold.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildHeatmapHeader(),
                        const SizedBox(height: 12),
                        _buildHeatmapWeekDays(),
                        const SizedBox(height: 5),
                        // We use a ClipRect and Transform to hide the package's English labels
                        ClipRect(
                          child: Transform.translate(
                            offset: const Offset(0, -78), // Hide header and week labels of package
                            child: SizedBox(
                              height: 250, // Fixed height to show the grid
                              child: HeatMapCalendar(
                                defaultColor: const Color(0xFF0F3D2E),
                                flexible: true,
                                colorMode: ColorMode.opacity,
                                datasets: _heatmapData,
                                initDate: _currentMonth,
                                colorsets: const {
                                  1: Color(0xFF0D4A36),
                                  500: Color(0xFF1DB386),
                                  1000: Color(0xFFD4AF37),
                                },
                                textColor: Colors.white,
                                showColorTip: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildBarChart() {
    final now = DateTime.now();
    List<double> values = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      values.add((_dailyCounts[key] ?? 0).toDouble());
    }

    double maxVal = values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
        final dayName = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'][date.weekday - 1];
        final heightFactor = values[index] / maxVal;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (values[index] > 0)
              Text(
                '${values[index].toInt()}',
                style: GoogleFonts.poppins(color: AppColors.softGold, fontSize: 9, fontWeight: FontWeight.bold),
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
                    index == 6 ? AppColors.goldLight : AppColors.softGold.withOpacity(0.8),
                    index == 6 ? AppColors.softGold : AppColors.softGold.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: index == 6 ? [BoxShadow(color: AppColors.softGold.withOpacity(0.3), blurRadius: 8)] : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayName,
              style: GoogleFonts.poppins(
                color: index == 6 ? AppColors.softGold : AppColors.textMuted,
                fontSize: 10,
                fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeatmapHeader() {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white),
          onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
        ),
        Text(
          '${months[_currentMonth.month]} ${_currentMonth.year}',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
        ),
      ],
    );
  }

  Widget _buildHeatmapWeekDays() {
    final days = ['Ya', 'Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) => Expanded(
          child: Center(
            child: Text(d, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11)),
          ),
        )).toList(),
      ),
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
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softGold.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.softGold, size: 22),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(title, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
