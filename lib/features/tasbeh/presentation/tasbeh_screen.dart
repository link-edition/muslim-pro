import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_pro/features/tasbeh/data/zikr_database.dart';
import 'package:muslim_pro/features/tasbeh/presentation/zikr_stats_bottom_sheet.dart';
import 'package:muslim_pro/features/tasbeh/presentation/history_page.dart';
import 'package:flutter/cupertino.dart';

class TasbehScreen extends StatefulWidget {
  const TasbehScreen({super.key});

  @override
  State<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends State<TasbehScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _total = 0;
  int _target = 33;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late TextEditingController _customZikrController;

  final List<int> _targets = [33, 99, 0]; // 0 represents infinity mode
  final List<String> _zikrNames = [
    'Subhanalloh',
    'Alhamdulillah',
    'Allohu Akbar',
    'La ilaha illalloh',
    'Astaghfirulloh',
  ];
  int _selectedZikr = 0;

  @override
  void initState() {
    super.initState();
    _customZikrController = TextEditingController();
    _loadSettings();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('tasbeh_vibration') ?? true;
      _soundEnabled = prefs.getBool('tasbeh_sound') ?? true;
      _total = prefs.getInt('tasbeh_total') ?? 0;
      _customZikrController.text = prefs.getString('custom_zikr') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tasbeh_vibration', _vibrationEnabled);
    await prefs.setBool('tasbeh_sound', _soundEnabled);
    await prefs.setInt('tasbeh_total', _total);
    await prefs.setString('custom_zikr', _customZikrController.text);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _customZikrController.dispose();
    super.dispose();
  }

  void _increment() async {
    _pulseController.forward().then((_) => _pulseController.reverse());

    if (_vibrationEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 25);
      }
    }

    if (_soundEnabled) {
       // AudioPlayer().setAsset('assets/audio/click.mp3').then((p) => p.play());
    }

    setState(() {
      _count++;
      _total++;
      
      if (_target == 0) {
        // Cheksizlik rejimi: Har 100 tada statistika saqlab signal beramiz
        if (_count > 0 && _count % 100 == 0) {
          HapticFeedback.heavyImpact();
          _saveSession(100);
        }
      } else if (_count >= _target) {
        // Oddiy rejim: Targetga yetganda nollaymiz
        HapticFeedback.heavyImpact();
        _saveSession(_target);
        _count = 0;
      }
    });
    _saveSettings();
  }

  void _saveSession(int count) {
    final String currentZikr = _customZikrController.text.isNotEmpty 
        ? _customZikrController.text 
        : _zikrNames[_selectedZikr];
        
    ZikrDatabase.insertSession(ZikrSession(
      zikrName: currentZikr,
      count: count,
      date: DateTime.now(),
    ));
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
  }

  void _resetAll() {
    HapticFeedback.heavyImpact();
    setState(() {
      _count = 0;
      _total = 0;
    });
    _saveSettings();
  }

  void _showStats() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _target == 0 ? 1.0 : (_count / _target);
    final String currentZikr = _customZikrController.text.isNotEmpty 
        ? _customZikrController.text 
        : _zikrNames[_selectedZikr];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          'Tasbeh',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showStats,
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.softGold),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          child: Column(
            children: [
              const SizedBox(height: 16),
          
              // Zikr tanlash
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _zikrNames.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedZikr == index && _customZikrController.text.isEmpty;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedZikr = index;
                            _customZikrController.clear();
                          });
                          _saveSettings();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.softGold.withOpacity(0.2)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.softGold
                                  : AppColors.emeraldLight.withOpacity(0.15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _zikrNames[index],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.softGold
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          
              const SizedBox(height: 12),
          
              // Target tanlash
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _targets.map((t) {
                  final isSelected = _target == t;
                  final String label = t == 0 ? '∞' : '$t';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _target = t;
                        _count = 0;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.emeraldMid
                              : AppColors.cardBg.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.softGold.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ] : null,
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: t == 0 ? 32 : 24,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.softGold
                                : AppColors.textMuted.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Shaxsiy zikr TextField (Central aylananing tepasiga ko'chirildi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _customZikrController,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    setState(() {});
                    _saveSettings();
                  },
                  style: GoogleFonts.poppins(
                    color: AppColors.softGold,
                    fontSize: 15,
                  ),
                  cursorColor: AppColors.softGold,
                  decoration: InputDecoration(
                    hintText: 'Shaxsiy zikr yozish...',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.textMuted.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    filled: true,
                    fillColor: AppColors.cardBg.withOpacity(0.3),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: AppColors.softGold.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: AppColors.softGold.withOpacity(0.7),
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: _customZikrController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.softGold),
                            onPressed: () {
                              setState(() => _customZikrController.clear());
                              _saveSettings();
                            },
                          )
                        : null,
                  ),
                ),
              ),
          
              const Spacer(),
          
              // Asosiy tasbeh doirasi
              Center(
                child: RepaintBoundary(
                  child: GestureDetector(
                    onTap: _increment,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Progress doira
                            SizedBox(
                              width: 240,
                              height: 240,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                backgroundColor:
                                    AppColors.emeraldLight.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.softGold,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            // Ichki doira
                            Container(
                              width: 210,
                              height: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.cardGradient,
                                border: Border.all(
                                  color: AppColors.softGold.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.softGold.withOpacity(0.05),
                                    blurRadius: 40,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_count',
                                    style: GoogleFonts.poppins(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.softGold,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '/ ${_target == 0 ? "∞" : _target}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      currentZikr,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.softGold.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
          
              // Jami hisoblagich
              Text(
                'Jami: $_total',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 35),

              // Boshqaruv tugmalari (Ekranning eng pastiga tushirildi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: _vibrationEnabled ? Icons.vibration : Icons.mobile_off_outlined,
                      onTap: () {
                        setState(() => _vibrationEnabled = !_vibrationEnabled);
                        _saveSettings();
                      },
                      isActive: _vibrationEnabled,
                    ),
                    _ActionButton(
                      icon: Icons.refresh_rounded,
                      onTap: _resetAll,
                      isActive: true,
                    ),
                    _ActionButton(
                      icon: _soundEnabled ? Icons.volume_up : Icons.volume_off_outlined,
                      onTap: () {
                        setState(() => _soundEnabled = !_soundEnabled);
                        _saveSettings();
                      },
                      isActive: _soundEnabled,
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive 
            ? AppColors.softGold.withOpacity(0.1)
            : AppColors.cardBg,
          border: Border.all(
            color: isActive 
              ? AppColors.softGold.withOpacity(0.2)
              : AppColors.emeraldLight.withOpacity(0.05),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.softGold : AppColors.textMuted,
          size: 24,
        ),
      ),
    );
  }
}
