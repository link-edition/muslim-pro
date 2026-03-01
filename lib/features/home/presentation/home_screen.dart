import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/namoz/prayer_provider.dart';
import 'package:muslim_pro/features/quran/presentation/quran_screen.dart';
import 'package:muslim_pro/features/quran/presentation/quran_entry_screen.dart';
import 'package:muslim_pro/features/duolar/presentation/duolar_entry_screen.dart';
import 'package:muslim_pro/features/tasbeh/presentation/tasbeh_screen.dart';
import 'package:muslim_pro/features/qibla/presentation/qibla_screen.dart';
import 'package:muslim_pro/features/settings/presentation/settings_screen.dart';
import 'package:muslim_pro/features/namoz/presentation/namoz_vaqtlari_page.dart';
import 'package:muslim_pro/features/quran/download_manager.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/features/namoz/prayer_tracker_provider.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';
import 'package:muslim_pro/features/namoz/presentation/prayer_analytics_screen.dart';
import 'package:muslim_pro/core/spiritual_progress_provider.dart';

// ─── Premium Color Constants ───
class _C {
  // Dark mode
  static const darkBg = Color(0xFF040E0A);
  static const cardDark = Color(0xFF0A1F17);
  static const softGold = Color(0xFFD4AF37);
  static const goldGlow = Color(0x33D4AF37);
  static const subtleBorder = Color(0x18D4AF37);
  static const textWhite = Color(0xFFF5F5F0);
  static const textMuted = Color(0xFF7A8B84);

  // Light mode — premium warm cream
  static const deepEmerald = Color(0xFF0F3D2E);
  static const creamTop = Color(0xFFF8F3EA);
  static const creamBot = Color(0xFFEBE3D4);
  static const lightMuted = Color(0xFF5E6D63);
  static const goldRich = Color(0xFFD4AF37);
  static const goldTop = Color(0xFFE6C76A);
  static const goldBot = Color(0xFFC9A227);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HOME SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _breatheController;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _headerFade;
  late Animation<double> _prayerCardSlide;
  late Animation<double> _pulseAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(AudioDownloadManager.provider).startBackgroundDownload();
    });

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Breathing animation for countdown digits
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _prayerCardSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _cardAnimations = List.generate(4, (index) {
      final start = 0.3 + (index * 0.1);
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerProvider);
    final l10n = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _C.darkBg : _C.creamTop,
      body: Stack(
        children: [
          // ── LAYERED BACKGROUND ──
          _PremiumBackground(isDark: isDark),

          // ── CONTENT ──
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _staggerController,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── HEADER WITH GLOW ──
                            Opacity(
                              opacity: _headerFade.value,
                              child: _PremiumHeader(isDark: isDark, l10n: l10n),
                            ),
                            const SizedBox(height: 16),

                            // ── PRAYER HERO CARD ──
                            Transform.translate(
                              offset: Offset(0, _prayerCardSlide.value),
                              child: Opacity(
                                opacity: _headerFade.value,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => const NamozVaqtlariPage(),
                                    ),
                                  ),
                                  child: _PremiumPrayerCard(
                                    prayerState: prayerState,
                                    pulseAnimation: _pulseAnimation,
                                    shimmerController: _shimmerController,
                                    breatheAnimation: _breatheAnimation,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // ── FEATURE CARDS GRID ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.05,
                    children: [
                      _AnimatedFeatureCard(
                        animation: _cardAnimations[0],
                        icon: Icons.auto_stories_outlined,
                        title: l10n.translate('quran_karim'),
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const QuranEntryScreen()),
                        ),
                      ),
                      _AnimatedFeatureCard(
                        animation: _cardAnimations[1],
                        icon: Icons.auto_stories_outlined,
                        title: l10n.translate('duas'),
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const DuolarEntryScreen()),
                        ),
                      ),
                      _AnimatedFeatureCard(
                        animation: _cardAnimations[2],
                        icon: Icons.touch_app_outlined,
                        title: l10n.translate('tasbeh'),
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const TasbehScreen()),
                        ),
                      ),
                      _AnimatedFeatureCard(
                        animation: _cardAnimations[3],
                        icon: Icons.explore_outlined,
                        title: l10n.translate('qibla'),
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const QiblaScreen()),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── PRAYER TRACKER SECTION ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  sliver: SliverToBoxAdapter(
                    child: _PrayerTrackerCard(isDark: isDark),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM BACKGROUND — Deep atmospheric layers
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PremiumBackground extends StatefulWidget {
  final bool isDark;
  const _PremiumBackground({required this.isDark});

  @override
  State<_PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<_PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _dustController;

  @override
  void initState() {
    super.initState();
    _dustController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _dustController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDark) return _buildDarkBackground(context);
    return _buildLightBackground(context);
  }

  // ── DARK MODE PREMIUM BACKGROUND ──
  Widget _buildDarkBackground(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Deep emerald gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF071E17),  // Top
                Color(0xFF0B2B22),  // Middle
                Color(0xFF061914),  // Bottom
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // Layer 2: Mosque silhouette — thin outline, subtle but noticeable
        const Positioned(
          top: 25,
          right: -15,
          child: Opacity(
            opacity: 0.10,
            child: Icon(
              Icons.mosque_outlined,
              size: 200,
              color: Color(0xFF2A5E4D),
            ),
          ),
        ),

        // Layer 3: Secondary smaller mosque outline — left side depth
        const Positioned(
          top: 85,
          left: -25,
          child: Opacity(
            opacity: 0.05,
            child: Icon(
              Icons.mosque_outlined,
              size: 120,
              color: Color(0xFF2A5E4D),
            ),
          ),
        ),

        // Layer 4: Emerald radial aura behind header ("Amal" title area)
        Positioned(
          top: -40,
          left: -20,
          right: -20,
          height: 280,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.2),
                radius: 0.8,
                colors: [
                  const Color(0xFF0F3D2E).withOpacity(0.25),
                  const Color(0x00071E17),
                ],
              ),
            ),
          ),
        ),

        // Layer 5: Ambient glow behind countdown card area
        Positioned(
          top: 200,
          left: 20,
          right: 20,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [
                  Colors.black.withOpacity(0.35),
                  const Color(0x00061914),
                ],
              ),
            ),
          ),
        ),

        // Layer 6: Vignette effect — darker edges
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.25),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Layer 7: Floating dust particles (extremely subtle)
        AnimatedBuilder(
          animation: _dustController,
          builder: (context, _) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _DustParticlesPainter(
                progress: _dustController.value,
                isDark: true,
              ),
            );
          },
        ),

        // Layer 8: Bottom depth gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00061914),
                  Color(0x80030C08),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── LIGHT MODE PREMIUM BACKGROUND ──
  Widget _buildLightBackground(BuildContext context) {
    return Stack(
      children: [
        // Base vertical gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _C.creamTop,
                Color(0xFFF4EFE6),
                _C.creamBot,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Radial light glow behind header area
        Positioned(
          top: -60,
          left: -40,
          right: -40,
          height: 320,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.3),
                radius: 0.9,
                colors: [Color(0xFFFFFFFF), Color(0x00F4EFE6)],
              ),
            ),
          ),
        ),

        // Ultra subtle mosque silhouette
        Positioned(
          top: 40,
          right: 10,
          child: Opacity(
            opacity: 0.035,
            child: Icon(
              Icons.mosque_rounded,
              size: 180,
              color: _C.deepEmerald,
            ),
          ),
        ),

        // Bottom depth fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00EBE3D4),
                  Color(0x20E5DCC8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Blur filter helper ──
ui.ImageFilter _blurFilter(double sigma) {
  return ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DUST PARTICLES — Ultra subtle floating atmosphere
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _DustParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _DustParticlesPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark
              ? const Color(0xFF1E4D3E)
              : const Color(0xFF0F3D2E))
          .withOpacity(0.02)
      ..style = PaintingStyle.fill;

    final rng = math.Random(42); // Fixed seed for deterministic positions
    const particleCount = 20;

    for (int i = 0; i < particleCount; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * (size.height * 0.4); // Only header area
      final radius = 1.0 + rng.nextDouble() * 2.0;

      // Slow floating motion
      final phase = (i * 0.31) + progress;
      final dx = math.sin(phase * math.pi * 2) * 15;
      final dy = math.cos(phase * math.pi * 2 * 0.7) * 10;

      canvas.drawCircle(
        Offset(baseX + dx, baseY + dy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM HEADER — With emerald glow behind title
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PremiumHeader extends StatelessWidget {
  final bool isDark;
  final AppLocalization l10n;
  const _PremiumHeader({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title with glow — both modes
        Stack(
          children: [
            // Emerald/cream glow behind "Amal"
            Positioned(
              left: -10,
              top: 8,
              child: Container(
                width: 110,
                height: 45,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? _C.deepEmerald.withOpacity(0.25)
                          : _C.deepEmerald.withOpacity(0.08),
                      blurRadius: isDark ? 50 : 35,
                      spreadRadius: isDark ? 12 : 8,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('assalom'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? _C.textMuted : _C.lightMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.translate('app_name'),
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: isDark ? _C.textWhite : _C.deepEmerald,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        _SettingsButton(isDark: isDark),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS BUTTON — Glass floating icon
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SettingsButton extends StatefulWidget {
  final bool isDark;
  const _SettingsButton({required this.isDark});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => const SettingsScreen()),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: widget.isDark ? _C.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: widget.isDark
                  ? _C.subtleBorder
                  : _C.goldRich.withOpacity(0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.06),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
              if (!widget.isDark)
                BoxShadow(
                  color: _C.goldRich.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Icon(
            Icons.settings_outlined,
            color: widget.isDark ? _C.softGold : _C.deepEmerald,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM PRAYER CARD — Gradient background + glowing badge
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PremiumPrayerCard extends StatelessWidget {
  final PrayerState prayerState;
  final Animation<double> pulseAnimation;
  final AnimationController shimmerController;
  final Animation<double> breatheAnimation;
  final bool isDark;

  const _PremiumPrayerCard({
    required this.prayerState,
    required this.pulseAnimation,
    required this.shimmerController,
    required this.breatheAnimation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final nextPrayer = prayerState.prayerTimes?.prayers
        .where((p) => p.isNext)
        .firstOrNull;
    final countdown = prayerState.countdown;
    final hours = countdown != null ? countdown.inHours : 0;
    final minutes = countdown != null ? countdown.inMinutes.remainder(60) : 0;
    final seconds = countdown != null ? countdown.inSeconds.remainder(60) : 0;

    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            // Light mode: subtle warm gradient. Dark: emerald gradient
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF134D3A),  // #0F3D2E lighter top
                      Color(0xFF0F3D2E),  // Core card color
                      Color(0xFF0A2A1F),  // Deeper bottom
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFCF9F3),
                      Color(0xFFF7F1E7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Color.lerp(
                      const Color(0x08FFFFFF),
                      _C.softGold.withOpacity(0.12),
                      (math.sin(shimmerController.value * math.pi * 2) + 1) / 2,
                    )!
                  : _C.goldRich.withOpacity(0.1),
              width: 1.2,
            ),
            boxShadow: [
              // Outer deep shadow
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.6 : 0.06),
                blurRadius: isDark ? 30 : 25,
                spreadRadius: 0,
                offset: const Offset(0, 12),
              ),
              if (!isDark)
                BoxShadow(
                  color: _C.goldRich.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              // Inner subtle highlight for dark mode
              if (isDark)
                BoxShadow(
                  color: Colors.white.withOpacity(0.03),
                  blurRadius: 1,
                  spreadRadius: -1,
                  offset: const Offset(0, -1),
                ),
            ],
          ),
          child: (prayerState.isLoading && prayerState.prayerTimes == null)
              ? Center(
                  child: SizedBox(
                    height: 50,
                    child: CircularProgressIndicator(
                      color: isDark ? _C.softGold : _C.deepEmerald,
                      strokeWidth: 1.5,
                    ),
                  ),
                )
              : Consumer(
                  builder: (context, ref, child) {
                    final l10n = ref.watch(localizationProvider);
                    return Column(
                      children: [
                        // Mosque badge with glow
                        _GlowingPrayerBadge(
                          name: l10n.translate(nextPrayer?.name ?? 'Bomdod'),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Countdown Timer with breathing
                        AnimatedBuilder(
                          animation: breatheAnimation,
                          builder: (context, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _PremiumCountdownUnit(
                                  value: hours,
                                  label: l10n.translate('hours'),
                                  isDark: isDark,
                                  breatheScale: breatheAnimation.value,
                                ),
                                _AnimatedSeparator(
                                  pulseAnimation: pulseAnimation,
                                  isDark: isDark,
                                ),
                                _PremiumCountdownUnit(
                                  value: minutes,
                                  label: l10n.translate('minutes'),
                                  isDark: isDark,
                                  breatheScale: breatheAnimation.value,
                                ),
                                _AnimatedSeparator(
                                  pulseAnimation: pulseAnimation,
                                  isDark: isDark,
                                ),
                                _PremiumCountdownUnit(
                                  value: seconds,
                                  label: l10n.translate('seconds'),
                                  isDark: isDark,
                                  breatheScale: breatheAnimation.value,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GLOWING PRAYER BADGE — Active prayer name with soft glow
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _GlowingPrayerBadge extends StatelessWidget {
  final String name;
  final bool isDark;
  const _GlowingPrayerBadge({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final badgeColor = isDark ? _C.softGold : _C.deepEmerald;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(isDark ? 0.15 : 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: badgeColor.withOpacity(isDark ? 0.2 : 0.12),
              width: 0.8,
            ),
            // Soft glow behind badge
            boxShadow: [
              BoxShadow(
                color: badgeColor.withOpacity(0.12),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mosque_outlined, size: 14, color: badgeColor),
              const SizedBox(width: 6),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COUNTDOWN UNIT — Premium breathing digits with inner shadow
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PremiumCountdownUnit extends StatelessWidget {
  final int value;
  final String label;
  final bool isDark;
  final double breatheScale;

  const _PremiumCountdownUnit({
    required this.value,
    required this.label,
    required this.isDark,
    required this.breatheScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.2)
            : _C.deepEmerald.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? _C.softGold.withOpacity(0.15)
              : _C.deepEmerald.withOpacity(0.07),
          width: 0.8,
        ),
        // Simulated inner shadow via layered box shadows
        boxShadow: isDark
            ? null
            : [
                // Outer shadow for depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                // Inner shadow simulation: dark top edge
                const BoxShadow(
                  color: Color(0x0D000000), // rgba(0,0,0,0.05)
                  blurRadius: 10,
                  spreadRadius: -3,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Breathing scale on digits
          Transform.scale(
            scale: breatheScale,
            child: Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.inter(
                fontSize: 38,
                fontWeight: FontWeight.w800, // Heavier weight
                color: isDark ? _C.softGold : _C.deepEmerald,
                height: 1,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : _C.lightMuted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ANIMATED SEPARATOR — Pulsing colon
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AnimatedSeparator extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final bool isDark;

  const _AnimatedSeparator({
    required this.pulseAnimation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Opacity(
            opacity: pulseAnimation.value,
            child: Text(
              ':',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? _C.softGold : _C.deepEmerald,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ANIMATED FEATURE CARD — Floating tile with gold gradient icon + haptics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AnimatedFeatureCard extends StatefulWidget {
  final Animation<double> animation;
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedFeatureCard({
    required this.animation,
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - widget.animation.value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
        },
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: widget.isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF134D3A),  // Lighter top edge
                        Color(0xFF0F3D2E),  // Core card
                        Color(0xFF0A2A1F),  // Depth
                      ],
                    )
                  : null,
              color: widget.isDark ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(_pressed ? 0.06 : 0.03)
                    : _C.goldRich.withOpacity(_pressed ? 0.18 : 0.08),
                width: 1.0,
              ),
              boxShadow: [
                // Deep outer shadow
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.6 : 0.06),
                  blurRadius: widget.isDark ? 30 : 25,
                  offset: const Offset(0, 12),
                ),
                if (!widget.isDark)
                  BoxShadow(
                    color: _C.goldRich.withOpacity(_pressed ? 0.12 : 0.04),
                    blurRadius: _pressed ? 18 : 16,
                    spreadRadius: _pressed ? 1 : -2,
                    offset: const Offset(0, 6),
                  ),
                // Inner highlight for dark mode float effect
                if (widget.isDark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.03),
                    blurRadius: 1,
                    spreadRadius: -1,
                    offset: const Offset(0, -1),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with rich gold gradient
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: widget.isDark
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x18E6C76A), // goldTop @ 9%
                                Color(0x10C9A227), // goldBot @ 6%
                              ],
                            ),
                      color: widget.isDark
                          ? _C.goldGlow.withOpacity(0.1)
                          : null,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: widget.isDark
                            ? _C.softGold.withOpacity(0.12)
                            : _C.goldRich.withOpacity(0.14),
                        width: 0.8,
                      ),
                    ),
                    child: ShaderMask(
                      shaderCallback: widget.isDark
                          ? (bounds) => LinearGradient(
                                colors: [_C.softGold, _C.softGold],
                              ).createShader(bounds)
                          : (bounds) => const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_C.goldTop, _C.goldBot],
                              ).createShader(bounds),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 24,  // 10% bigger than 22
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? _C.textWhite : _C.deepEmerald,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRAYER TRACKER CARD — Daily 5 prayer check-in
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PrayerTrackerCard extends ConsumerWidget {
  final bool isDark;
  const _PrayerTrackerCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerState = ref.watch(prayerTrackerProvider);
    final tracker = trackerState.record;
    final l10n = ref.watch(localizationProvider);
    final prayerNames = ['Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton'];
    final prayerIcons = [
      Icons.wb_twilight_rounded,     // Bomdod — dawn
      Icons.wb_sunny_outlined,       // Peshin — midday
      Icons.sunny_snowing,           // Asr — afternoon
      Icons.nights_stay_outlined,    // Shom — sunset
      Icons.dark_mode_outlined,      // Xufton — night
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF134D3A),
                  Color(0xFF0F3D2E),
                  Color(0xFF0A2A1F),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFCF9F3),
                  Color(0xFFF7F1E7),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : _C.goldRich.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.02),
              blurRadius: 1,
              spreadRadius: -1,
              offset: const Offset(0, -1),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const PrayerAnalyticsScreen(),
                ),
              );
            },
            child: Container(
              color: Colors.transparent, // to increase tap area
              child: Row(
                children: [
                  Icon(
                    Icons.mosque_outlined,
                    size: 18,
                    color: isDark ? _C.softGold : _C.deepEmerald,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.translate('daily_prayers'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? _C.textWhite : _C.deepEmerald,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  // Analytics button, bigger and bolder
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isDark ? _C.softGold : _C.deepEmerald)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 16,
                          color: isDark ? _C.softGold : _C.deepEmerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Statistika',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? _C.softGold : _C.deepEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Progress bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tracker.completionPercentage,
              minHeight: 4,
              backgroundColor: (isDark ? _C.softGold : _C.deepEmerald)
                  .withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? _C.softGold : _C.deepEmerald,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Progress text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${tracker.completedCount}/5',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: (isDark ? _C.textMuted : _C.lightMuted),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 5 Prayer circles ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final name = prayerNames[index];
              PrayerStatus status = PrayerStatus.unknown;
              switch (name.toLowerCase()) {
                case 'bomdod':
                  status = tracker.fajr;
                  break;
                case 'peshin':
                  status = tracker.dhuhr;
                  break;
                case 'asr':
                  status = tracker.asr;
                  break;
                case 'shom':
                  status = tracker.maghrib;
                  break;
                case 'xufton':
                  status = tracker.isha;
                  break;
              }
              return Expanded(
                child: Center(
                  child: _PrayerCircle(
                    name: l10n.translate(name),
                    icon: prayerIcons[index],
                    status: status,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showPrayerOptions(context, ref, name, l10n.translate(name), status, l10n, isDark);
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      _showPrayerOptions(context, ref, name, l10n.translate(name), status, l10n, isDark);
                    },
                  ),
                ),
              );
            }),
          ),

          // ── Completion message ──
          if (tracker.isAllCompleted) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: (isDark ? _C.softGold : _C.deepEmerald)
                    .withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isDark ? _C.softGold : _C.deepEmerald)
                      .withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: isDark ? _C.softGold : _C.deepEmerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.translate('all_prayers_done'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? _C.softGold : _C.deepEmerald,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Mountain Level Indicator ──
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final sp = ref.watch(spiritualProgressProvider);
              final accent = isDark ? _C.softGold : _C.deepEmerald;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.terrain_rounded, size: 16, color: accent.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Text(sp.level.nameUz, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: sp.mountainDotPosition,
                          minHeight: 3,
                          backgroundColor: accent.withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(accent.withOpacity(0.4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${sp.totalScore}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? _C.textMuted : _C.lightMuted)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRAYER CIRCLE — Individual prayer toggle
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PrayerCircle extends StatefulWidget {
  final String name;
  final IconData icon;
  final PrayerStatus status;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PrayerCircle({
    required this.name,
    required this.icon,
    required this.status,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_PrayerCircle> createState() => _PrayerCircleState();
}

class _PrayerCircleState extends State<_PrayerCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PrayerCircle old) {
    super.didUpdateWidget(old);
    if (widget.status != old.status && 
       (widget.status == PrayerStatus.prayed || widget.status == PrayerStatus.qazaCompleted)) {
      _checkController.forward(from: 0);
    }
  }

  Color get _borderColor {
    final accentColor = widget.isDark ? _C.softGold : _C.deepEmerald;
    if (widget.status == PrayerStatus.prayed || widget.status == PrayerStatus.qazaCompleted) return accentColor.withOpacity(0.4);
    if (widget.status == PrayerStatus.missed) return (widget.isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1));
    return (widget.isDark ? Colors.white.withOpacity(0.08) : _C.deepEmerald.withOpacity(0.1));
  }
  
  Color get _bgColor {
    final accentColor = widget.isDark ? _C.softGold : _C.deepEmerald;
    if (widget.status == PrayerStatus.prayed) return accentColor.withOpacity(widget.isDark ? 0.2 : 0.1);
    if (widget.status == PrayerStatus.qazaCompleted) return accentColor.withOpacity(0.05);
    if (widget.status == PrayerStatus.missed) return (widget.isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02));
    return (widget.isDark ? Colors.white.withOpacity(0.04) : _C.deepEmerald.withOpacity(0.04));
  }

  Color get _iconColor {
    final accentColor = widget.isDark ? _C.softGold : _C.deepEmerald;
    if (widget.status == PrayerStatus.prayed || widget.status == PrayerStatus.qazaCompleted) return accentColor;
    if (widget.status == PrayerStatus.missed) return (widget.isDark ? _C.textMuted.withOpacity(0.5) : _C.lightMuted.withOpacity(0.5));
    return (widget.isDark ? _C.textMuted : _C.lightMuted);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isDark ? _C.softGold : _C.deepEmerald;
    final isDone = widget.status == PrayerStatus.prayed || widget.status == PrayerStatus.qazaCompleted;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _bgColor,
                border: Border.all(
                  color: _borderColor,
                  width: isDone ? 1.5 : 1.0,
                ),
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : widget.icon,
                size: isDone ? 22 : 20,
                color: _iconColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.name,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                color: isDone ? accentColor : (widget.isDark ? _C.textMuted : _C.lightMuted),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRAYER OPTIONS BOTTOM SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
void _showPrayerOptions(BuildContext context, WidgetRef ref, String rawName, String localizedName, PrayerStatus status, AppLocalization l10n, bool isDark) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      final bottomPadding = MediaQuery.of(ctx).padding.bottom;
      return Container(
        padding: EdgeInsets.only(top: 16, bottom: bottomPadding + 32, left: 24, right: 24),
        decoration: BoxDecoration(
          color: isDark ? _C.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : _C.goldRich.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizedName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : _C.deepEmerald,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context: ctx,
              title: "Vaqtida o'qildi",
              icon: Icons.check_circle_outline,
              color: isDark ? _C.softGold : _C.deepEmerald,
              isSelected: status == PrayerStatus.prayed,
              isDark: isDark,
              onTap: () {
                ref.read(prayerTrackerProvider.notifier).setPrayerStatus(rawName, PrayerStatus.prayed);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context: ctx,
              title: "O'tkazib yuborildi",
              icon: Icons.circle_outlined,
              color: isDark ? _C.textMuted : _C.lightMuted,
              isSelected: status == PrayerStatus.missed,
              isDark: isDark,
              onTap: () {
                ref.read(prayerTrackerProvider.notifier).setPrayerStatus(rawName, PrayerStatus.missed);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context: ctx,
              title: "Qazosi o'qildi",
              icon: Icons.restore_rounded,
              color: isDark ? _C.softGold : _C.deepEmerald,
              isSelected: status == PrayerStatus.qazaCompleted,
              isDark: isDark,
              onTap: () {
                ref.read(prayerTrackerProvider.notifier).setPrayerStatus(rawName, PrayerStatus.qazaCompleted);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOptionTile({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Color color,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color.withOpacity(0.3) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isDark ? Colors.white : _C.deepEmerald,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check_rounded, color: color, size: 18),
        ],
      ),
    ),
  );
}
