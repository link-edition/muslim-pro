import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_pro/features/tasbeh/data/zikr_database.dart';
import 'package:muslim_pro/features/tasbeh/presentation/history_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/core/localization.dart';

// ─── Premium Color Constants ───
class _K {
  // Dark
  static const deepBg = Color(0xFF061914);
  static const emeraldMid = Color(0xFF0B2B22);
  static const emeraldTop = Color(0xFF071E17);
  static const mountainStroke = Color(0xFF1E4D3E);
  static const cardDark = Color(0xFF0F3D2E);
  static const softGold = Color(0xFFD4AF37);
  static const goldTop = Color(0xFFE6C76A);
  static const goldBot = Color(0xFFC9A227);
  static const textWhite = Color(0xFFF5F5F0);
  static const textMuted = Color(0xFF7A8B84);

  // Light
  static const creamTop = Color(0xFFF8F3EA);
  static const creamBot = Color(0xFFEBE3D4);
  static const deepEmerald = Color(0xFF0F3D2E);
  static const lightMuted = Color(0xFF5E6D63);
  static const mountainLight = Color(0xFF3D7A65);
}

class TasbehScreen extends ConsumerStatefulWidget {
  const TasbehScreen({super.key});

  @override
  ConsumerState<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends ConsumerState<TasbehScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  int _total = 0;
  int _target = 33;
  int _cyclesCompleted = 0;  // Tracks 33-cycles for mountain journey
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;

  late AnimationController _tapController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  late AnimationController _dotClimbController;
  late AnimationController _shimmerController;

  late Animation<double> _tapScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _rippleExpand;
  late Animation<double> _rippleFade;

  late TextEditingController _customZikrController;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _doneAudioPlayer;

  final List<int> _targets = [33, 99, 0];
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

    _audioPlayer = AudioPlayer();
    _doneAudioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _doneAudioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _audioPlayer.setSource(AssetSource('audio/tasbeh_click.wav'));
    _doneAudioPlayer.setSource(AssetSource('audio/tasbeh_done.wav'));

    // Tap scale: 1.0 → 1.04 → 1.0
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));

    // Gold number glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    // Ripple outward
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rippleExpand = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleFade = Tween<double>(begin: 0.12, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeIn),
    );

    // Dot climb animation
    _dotClimbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Shimmer for completion
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('tasbeh_vibration') ?? true;
      _soundEnabled = prefs.getBool('tasbeh_sound') ?? true;
      _total = prefs.getInt('tasbeh_total') ?? 0;
      _cyclesCompleted = prefs.getInt('tasbeh_cycles') ?? 0;
      _customZikrController.text = prefs.getString('custom_zikr') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tasbeh_vibration', _vibrationEnabled);
    await prefs.setBool('tasbeh_sound', _soundEnabled);
    await prefs.setInt('tasbeh_total', _total);
    await prefs.setInt('tasbeh_cycles', _cyclesCompleted);
    await prefs.setString('custom_zikr', _customZikrController.text);
  }

  @override
  void dispose() {
    _tapController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    _dotClimbController.dispose();
    _shimmerController.dispose();
    _customZikrController.dispose();
    _audioPlayer.dispose();
    _doneAudioPlayer.dispose();
    super.dispose();
  }

  void _increment() async {
    // Fire animations
    _tapController.forward(from: 0);
    _glowController.forward(from: 0).then((_) => _glowController.reverse());
    _rippleController.forward(from: 0);

    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    if (_soundEnabled) {
      _audioPlayer.stop();
      _audioPlayer.play(AssetSource('audio/tasbeh_click.wav'));
    }

    setState(() {
      _count++;
      _total++;

      if (_target == 0) {
        if (_count > 0 && _count % 100 == 0) {
          HapticFeedback.heavyImpact();
          if (_soundEnabled) {
            _doneAudioPlayer.stop();
            _doneAudioPlayer.play(AssetSource('audio/tasbeh_done.wav'));
          }
          _saveSession(100);
        } else if (_count == 33 || _count == 99) {
          HapticFeedback.mediumImpact();
          _onCycleComplete();
        }
      } else if (_count >= _target) {
        HapticFeedback.heavyImpact();
        if (_soundEnabled) {
          _doneAudioPlayer.stop();
          _doneAudioPlayer.play(AssetSource('audio/tasbeh_done.wav'));
        }
        _saveSession(_target);
        _onCycleComplete();
        _count = 0;
      }
    });
    _saveSettings();
  }

  void _onCycleComplete() {
    _cyclesCompleted++;
    if (_cyclesCompleted > 10) _cyclesCompleted = 0; // Reset journey
    _dotClimbController.forward(from: 0);
    _shimmerController.forward(from: 0);
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
    setState(() => _count = 0);
  }

  void _resetAll() {
    HapticFeedback.heavyImpact();
    setState(() {
      _count = 0;
      _total = 0;
      _cyclesCompleted = 0;
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _target == 0 ? 1.0 : (_count / _target);
    final l10n = ref.watch(localizationProvider);
    final mountainProgress = _cyclesCompleted / 10.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── BACKGROUND LAYERS ──
          _MountainBackground(
            isDark: isDark,
            mountainProgress: mountainProgress,
            shimmerController: _shimmerController,
          ),

          // ── CONTENT ──
          SafeArea(
            child: Column(
              children: [
                // ── APP BAR ──
                _TasbehAppBar(
                  isDark: isDark,
                  onBack: () => Navigator.pop(context),
                  onStats: () => Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const HistoryPage()),
                  ),
                  l10n: l10n,
                ),

                const SizedBox(height: 8),

                // ── ZIKR SELECTOR ──
                _ZikrSelector(
                  zikrNames: _zikrNames,
                  selectedZikr: _selectedZikr,
                  customText: _customZikrController.text,
                  isDark: isDark,
                  l10n: l10n,
                  onSelect: (index) {
                    setState(() {
                      _selectedZikr = index;
                      _customZikrController.clear();
                    });
                    _saveSettings();
                  },
                ),

                const SizedBox(height: 8),

                // ── TARGET SELECTOR ──
                _TargetSelector(
                  targets: _targets,
                  currentTarget: _target,
                  isDark: isDark,
                  onSelect: (t) => setState(() {
                    _target = t;
                    _count = 0;
                  }),
                ),

                const SizedBox(height: 12),

                // ── CUSTOM ZIKR INPUT ──
                _CustomZikrInput(
                  controller: _customZikrController,
                  isDark: isDark,
                  l10n: l10n,
                  onChanged: () {
                    setState(() {});
                    _saveSettings();
                  },
                ),

                const Spacer(),

                // ── MOUNTAIN PROGRESS DOT INFO ──
                _JourneyInfo(
                  cyclesCompleted: _cyclesCompleted,
                  isDark: isDark,
                  l10n: l10n,
                ),

                const SizedBox(height: 16),

                // ── MAIN TAP CIRCLE ──
                _TasbehTapCircle(
                  count: _count,
                  target: _target,
                  progress: progress,
                  isDark: isDark,
                  tapScale: _tapScale,
                  glowOpacity: _glowOpacity,
                  rippleExpand: _rippleExpand,
                  rippleFade: _rippleFade,
                  tapController: _tapController,
                  zikrName: _customZikrController.text.isNotEmpty
                      ? _customZikrController.text
                      : l10n.translate(_zikrNames[_selectedZikr]),
                  onTap: _increment,
                ),

                const Spacer(),

                // ── TOTAL COUNTER ──
                Text(
                  '${l10n.translate('total_count')}$_total',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? _K.textMuted : _K.lightMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ── BOTTOM CONTROLS ──
                _BottomControls(
                  isDark: isDark,
                  vibrationEnabled: _vibrationEnabled,
                  soundEnabled: _soundEnabled,
                  onToggleVibration: () {
                    setState(() => _vibrationEnabled = !_vibrationEnabled);
                    _saveSettings();
                  },
                  onReset: _resetAll,
                  onToggleSound: () {
                    setState(() => _soundEnabled = !_soundEnabled);
                    _saveSettings();
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MOUNTAIN BACKGROUND — Atmospheric spiritual landscape
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MountainBackground extends StatelessWidget {
  final bool isDark;
  final double mountainProgress;
  final AnimationController shimmerController;

  const _MountainBackground({
    required this.isDark,
    required this.mountainProgress,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Layer 1: Deep gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [_K.emeraldTop, _K.emeraldMid, _K.deepBg]
                  : const [_K.creamTop, Color(0xFFF4EFE6), _K.creamBot],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Layer 2: Radial emerald glow in mountain area
        Positioned(
          top: -30,
          left: -30,
          right: -30,
          height: size.height * 0.35,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, 0.3),
                radius: 0.9,
                colors: isDark
                    ? [
                        const Color(0xFF0F3D2E).withOpacity(0.15),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFFFFFFFF).withOpacity(0.6),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),

        // Layer 3: Mountain silhouette
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.30,
          child: CustomPaint(
            painter: _MountainPainter(
              isDark: isDark,
              progress: mountainProgress,
            ),
          ),
        ),

        // Layer 4: Soul dot on mountain path
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.30,
          child: CustomPaint(
            painter: _SoulDotPainter(
              isDark: isDark,
              progress: mountainProgress,
            ),
          ),
        ),

        // Layer 5: Shimmer wave on completion
        AnimatedBuilder(
          animation: shimmerController,
          builder: (context, _) {
            if (!shimmerController.isAnimating) return const SizedBox.shrink();
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.30,
              child: Opacity(
                opacity: (1.0 - shimmerController.value) * 0.12,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + shimmerController.value * 3, 0),
                      end: Alignment(-0.5 + shimmerController.value * 3, 0),
                      colors: [
                        Colors.transparent,
                        _K.softGold.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MOUNTAIN PAINTER — Pure vector outline
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MountainPainter extends CustomPainter {
  final bool isDark;
  final double progress;

  _MountainPainter({required this.isDark, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? _K.mountainStroke : _K.mountainLight)
          .withOpacity(isDark ? 0.10 : 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Main mountain range — elegant peaks
    final mainPath = Path();
    mainPath.moveTo(0, h * 0.85);
    mainPath.lineTo(w * 0.08, h * 0.72);
    mainPath.lineTo(w * 0.15, h * 0.60);
    mainPath.lineTo(w * 0.22, h * 0.50);
    mainPath.lineTo(w * 0.30, h * 0.38);
    mainPath.lineTo(w * 0.38, h * 0.28);
    mainPath.lineTo(w * 0.45, h * 0.20);
    mainPath.lineTo(w * 0.50, h * 0.15); // Peak
    mainPath.lineTo(w * 0.55, h * 0.20);
    mainPath.lineTo(w * 0.62, h * 0.28);
    mainPath.lineTo(w * 0.70, h * 0.38);
    mainPath.lineTo(w * 0.78, h * 0.50);
    mainPath.lineTo(w * 0.85, h * 0.60);
    mainPath.lineTo(w * 0.92, h * 0.72);
    mainPath.lineTo(w, h * 0.85);

    canvas.drawPath(mainPath, paint);

    // Secondary smaller peak — right side
    final secondPaint = Paint()
      ..color = (isDark ? _K.mountainStroke : _K.mountainLight)
          .withOpacity(isDark ? 0.06 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final secondPath = Path();
    secondPath.moveTo(w * 0.55, h * 0.85);
    secondPath.lineTo(w * 0.65, h * 0.65);
    secondPath.lineTo(w * 0.72, h * 0.52);
    secondPath.lineTo(w * 0.78, h * 0.45); // Smaller peak
    secondPath.lineTo(w * 0.84, h * 0.52);
    secondPath.lineTo(w * 0.90, h * 0.65);
    secondPath.lineTo(w, h * 0.85);

    canvas.drawPath(secondPath, secondPaint);

    // Subtle mountain ridge lines for depth
    final ridgePaint = Paint()
      ..color = (isDark ? _K.mountainStroke : _K.mountainLight)
          .withOpacity(isDark ? 0.04 : 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final ridgePath = Path();
    ridgePath.moveTo(w * 0.35, h * 0.32);
    ridgePath.quadraticBezierTo(w * 0.42, h * 0.26, w * 0.50, h * 0.15);
    ridgePath.quadraticBezierTo(w * 0.58, h * 0.26, w * 0.65, h * 0.32);

    canvas.drawPath(ridgePath, ridgePaint);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOUL DOT — Golden light climbing the mountain
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SoulDotPainter extends CustomPainter {
  final bool isDark;
  final double progress; // 0.0 to 1.0

  _SoulDotPainter({required this.isDark, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Calculate dot position along mountain path
    final t = progress.clamp(0.0, 1.0);

    // Path from bottom-left to peak (matching mountain path)
    final baseY = h * 0.85;
    final peakY = h * 0.15;
    final currentY = baseY - (baseY - peakY) * t;

    // X follows mountain slope toward center peak at w*0.5
    final startX = w * 0.08;
    final peakX = w * 0.50;
    final currentX = startX + (peakX - startX) * t;

    // Outer glow
    final glowPaint = Paint()
      ..color = _K.softGold.withOpacity(isDark ? 0.25 : 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(currentX, currentY), 12, glowPaint);

    // Main dot with gradient
    final dotPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_K.goldTop, _K.goldBot],
      ).createShader(Rect.fromCircle(center: Offset(currentX, currentY), radius: 4));
    canvas.drawCircle(Offset(currentX, currentY), isDark ? 4.5 : 4.0, dotPaint);

    // Bright center
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(isDark ? 0.7 : 0.5);
    canvas.drawCircle(Offset(currentX, currentY), 1.5, centerPaint);

    // Peak glow if near top
    if (t > 0.85) {
      final peakGlow = Paint()
        ..color = _K.softGold.withOpacity(0.15 * ((t - 0.85) / 0.15))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawCircle(Offset(peakX, peakY), 25, peakGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _SoulDotPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// APP BAR — Transparent with premium styling
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TasbehAppBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onStats;
  final AppLocalization l10n;

  const _TasbehAppBar({
    required this.isDark,
    required this.onBack,
    required this.onStats,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: isDark ? _K.textWhite : _K.deepEmerald,
            ),
          ),
          const Spacer(),
          Text(
            l10n.translate('tasbeh'),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? _K.textWhite : _K.deepEmerald,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onStats,
            icon: Icon(
              Icons.bar_chart_rounded,
              color: isDark ? _K.softGold : _K.deepEmerald,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZIKR SELECTOR — Horizontal chips
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ZikrSelector extends StatelessWidget {
  final List<String> zikrNames;
  final int selectedZikr;
  final String customText;
  final bool isDark;
  final AppLocalization l10n;
  final ValueChanged<int> onSelect;

  const _ZikrSelector({
    required this.zikrNames,
    required this.selectedZikr,
    required this.customText,
    required this.isDark,
    required this.l10n,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: zikrNames.length,
        itemBuilder: (context, index) {
          final isSelected = selectedZikr == index && customText.isEmpty;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? _K.softGold.withOpacity(0.15)
                          : _K.deepEmerald.withOpacity(0.08))
                      : (isDark
                          ? _K.cardDark.withOpacity(0.5)
                          : Colors.white.withOpacity(0.7)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark
                            ? _K.softGold.withOpacity(0.4)
                            : _K.deepEmerald.withOpacity(0.2))
                        : (isDark
                            ? _K.mountainStroke.withOpacity(0.15)
                            : _K.deepEmerald.withOpacity(0.08)),
                  ),
                ),
                child: Center(
                  child: Text(
                    l10n.translate(zikrNames[index]),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? _K.softGold : _K.deepEmerald)
                          : (isDark ? _K.textMuted : _K.lightMuted),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET SELECTOR — 33 / 99 / ∞
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TargetSelector extends StatelessWidget {
  final List<int> targets;
  final int currentTarget;
  final bool isDark;
  final ValueChanged<int> onSelect;

  const _TargetSelector({
    required this.targets,
    required this.currentTarget,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: targets.map((t) {
        final isSelected = currentTarget == t;
        final label = t == 0 ? '∞' : '$t';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => onSelect(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? _K.cardDark : _K.deepEmerald.withOpacity(0.08))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? (isDark
                          ? _K.softGold.withOpacity(0.25)
                          : _K.deepEmerald.withOpacity(0.15))
                      : Colors.transparent,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? _K.softGold : _K.deepEmerald)
                              .withOpacity(0.08),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: t == 0 ? 28 : 20,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? _K.softGold : _K.deepEmerald)
                      : (isDark ? _K.textMuted : _K.lightMuted).withOpacity(0.4),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CUSTOM ZIKR INPUT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CustomZikrInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final AppLocalization l10n;
  final VoidCallback onChanged;

  const _CustomZikrInput({
    required this.controller,
    required this.isDark,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        onChanged: (_) => onChanged(),
        style: GoogleFonts.inter(
          color: isDark ? _K.softGold : _K.deepEmerald,
          fontSize: 15,
        ),
        cursorColor: isDark ? _K.softGold : _K.deepEmerald,
        decoration: InputDecoration(
          hintText: l10n.translate('custom_zikr_hint'),
          hintStyle: GoogleFonts.inter(
            color: (isDark ? _K.textMuted : _K.lightMuted).withOpacity(0.5),
            fontSize: 14,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          filled: true,
          fillColor: isDark
              ? _K.cardDark.withOpacity(0.3)
              : Colors.white.withOpacity(0.6),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: isDark
                  ? _K.softGold.withOpacity(0.2)
                  : _K.deepEmerald.withOpacity(0.12),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: isDark
                  ? _K.softGold.withOpacity(0.5)
                  : _K.deepEmerald.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark ? _K.softGold : _K.deepEmerald,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// JOURNEY INFO — Mountain progress dots
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _JourneyInfo extends StatelessWidget {
  final int cyclesCompleted;
  final bool isDark;
  final AppLocalization l10n;

  const _JourneyInfo({
    required this.cyclesCompleted,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (i) {
        final isCompleted = i < cyclesCompleted;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? (isDark ? _K.softGold : _K.deepEmerald)
                : (isDark ? _K.mountainStroke : _K.lightMuted).withOpacity(0.2),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: (isDark ? _K.softGold : _K.deepEmerald)
                          .withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAP CIRCLE — Main tasbeh interaction with ripple + glow
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TasbehTapCircle extends StatelessWidget {
  final int count;
  final int target;
  final double progress;
  final bool isDark;
  final Animation<double> tapScale;
  final Animation<double> glowOpacity;
  final Animation<double> rippleExpand;
  final Animation<double> rippleFade;
  final AnimationController tapController;
  final String zikrName;
  final VoidCallback onTap;

  const _TasbehTapCircle({
    required this.count,
    required this.target,
    required this.progress,
    required this.isDark,
    required this.tapScale,
    required this.glowOpacity,
    required this.rippleExpand,
    required this.rippleFade,
    required this.tapController,
    required this.zikrName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: tapController,
          builder: (context, _) {
            return SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple ring
                  Transform.scale(
                    scale: rippleExpand.value,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isDark ? _K.softGold : _K.deepEmerald)
                              .withOpacity(rippleFade.value),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Main circle with scale
                  Transform.scale(
                    scale: tapScale.value,
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress ring
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              backgroundColor: (isDark
                                      ? _K.mountainStroke
                                      : _K.deepEmerald)
                                  .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? _K.softGold : _K.deepEmerald,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),

                          // Inner circle
                          Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        const Color(0xFF134D3A),
                                        _K.cardDark,
                                        const Color(0xFF0A2A1F),
                                      ]
                                    : [
                                        Colors.white,
                                        const Color(0xFFFCF9F3),
                                        const Color(0xFFF7F1E7),
                                      ],
                              ),
                              border: Border.all(
                                color: (isDark ? _K.softGold : _K.deepEmerald)
                                    .withOpacity(0.08),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.5 : 0.06),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                                if (isDark)
                                  BoxShadow(
                                    color:
                                        Colors.white.withOpacity(0.02),
                                    blurRadius: 1,
                                    spreadRadius: -1,
                                    offset: const Offset(0, -1),
                                  ),
                                // Gold glow on tap
                                BoxShadow(
                                  color: _K.softGold
                                      .withOpacity(glowOpacity.value * 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Count number
                                Text(
                                  '$count',
                                  style: GoogleFonts.inter(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? _K.softGold
                                        : _K.deepEmerald,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '/ ${target == 0 ? "∞" : target}',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? _K.textMuted
                                        : _K.lightMuted,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    zikrName,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: (isDark
                                              ? _K.softGold
                                              : _K.deepEmerald)
                                          .withOpacity(0.6),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOTTOM CONTROLS — Vibration, Reset, Sound
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _BottomControls extends StatelessWidget {
  final bool isDark;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final VoidCallback onToggleVibration;
  final VoidCallback onReset;
  final VoidCallback onToggleSound;

  const _BottomControls({
    required this.isDark,
    required this.vibrationEnabled,
    required this.soundEnabled,
    required this.onToggleVibration,
    required this.onReset,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: vibrationEnabled
                ? Icons.vibration
                : Icons.mobile_off_outlined,
            isActive: vibrationEnabled,
            isDark: isDark,
            onTap: onToggleVibration,
          ),
          _ControlButton(
            icon: Icons.refresh_rounded,
            isActive: true,
            isDark: isDark,
            onTap: onReset,
          ),
          _ControlButton(
            icon: soundEnabled
                ? Icons.volume_up
                : Icons.volume_off_outlined,
            isActive: soundEnabled,
            isDark: isDark,
            onTap: onToggleSound,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDark;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? (isDark
                  ? _K.softGold.withOpacity(0.1)
                  : _K.deepEmerald.withOpacity(0.06))
              : (isDark
                  ? _K.cardDark.withOpacity(0.3)
                  : Colors.white.withOpacity(0.5)),
          border: Border.all(
            color: isActive
                ? (isDark
                    ? _K.softGold.withOpacity(0.2)
                    : _K.deepEmerald.withOpacity(0.12))
                : (isDark ? _K.mountainStroke : _K.deepEmerald)
                    .withOpacity(0.05),
          ),
        ),
        child: Icon(
          icon,
          color: isActive
              ? (isDark ? _K.softGold : _K.deepEmerald)
              : (isDark ? _K.textMuted : _K.lightMuted),
          size: 22,
        ),
      ),
    );
  }
}
