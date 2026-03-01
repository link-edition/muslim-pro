import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/core/localization.dart';
import 'dart:ui' as ui;

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          if (!mounted) return;
          final l10n = ref.read(localizationProvider);
          setState(() {
            _error = l10n.translate('location_denied');
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = ref.read(localizationProvider);
      setState(() {
        _error = '${l10n.translate('error_occured')}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          l10n.translate('qibla'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalization l10n) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.softGold),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                l10n.translate(_error!),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.emeraldMid,
                  foregroundColor: context.colors.softGold,
                ),
                child: Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Text(l10n.translate('location_needed')),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: context.colors.softGold),
          );
        }

        final qibla = snapshot.data!;
        return _QiblaCompass(qibla: qibla, l10n: l10n);
      },
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final QiblahDirection qibla;
  final AppLocalization l10n;
  const _QiblaCompass({required this.qibla, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final compassDirection = qibla.direction;
    final qiblaOffset = qibla.offset;

    // Aniq qibla burchagini topamiz (ekranga nisbatan)
    final meccaAngle = qiblaOffset - compassDirection;

    // Qibla to'g'ri yo'nalishda bo'lsa
    double diff = meccaAngle.abs() % 360;
    if (diff > 180) diff = 360 - diff;
    final isAligned = diff <= 5;

    return Column(
      children: [
        const Spacer(flex: 1),

        // Daraja ko'rsatkichi
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isAligned
                ? context.colors.softGold
                : context.colors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAligned
                  ? context.colors.softGold
                  : context.colors.emeraldLight.withOpacity( 0.15),
            ),
            boxShadow: [
              if (isAligned)
                BoxShadow(
                  color: context.colors.softGold.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAligned ? Icons.star_rounded : Icons.explore,
                color: isAligned ? Colors.white : context.colors.textMuted,
                size: isAligned ? 28 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                isAligned
                    ? l10n.translate('qibla_aligned')
                    : '${compassDirection.toStringAsFixed(1)}°',
                style: GoogleFonts.inter(
                  fontSize: isAligned ? 22 : 16,
                  fontWeight: FontWeight.bold,
                  color: isAligned ? Colors.white : context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 1),

        // Kompas
        RepaintBoundary(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Tashqi doira (kompas)
                Transform.rotate(
                  angle: -compassDirection * (pi / 180),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAligned ? context.colors.softGold.withOpacity(0.2) : context.colors.cardBg,
                      border: Border.all(
                        color: isAligned ? context.colors.softGold : context.colors.emeraldLight.withOpacity( 0.2),
                        width: isAligned ? 8 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.softGold.withOpacity(isAligned ? 0.6 : 0.08),
                          blurRadius: isAligned ? 60 : 30,
                          spreadRadius: isAligned ? 15 : 5,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _CompassPainter(
                        colors: context.colors,
                        isLightMode: Theme.of(context).brightness == Brightness.light,
                      ),
                    ),
                  ),
                ),

                // Qibla yo'nalish ko'rsatgichi (ka'ba)
                Transform.rotate(
                  angle: meccaAngle * (pi / 180),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _QiblaAlignedMosque(
                        isAligned: isAligned,
                        colors: context.colors,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Markaziy nuqta
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.goldText,
                    border: Border.all(color: context.colors.deepEmerald, width: 3),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(flex: 1),

        // Pastdagi ma'lumot
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: context.colors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.emeraldLight.withOpacity( 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.colors.softGold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.translate('qibla_hint'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(flex: 1),
        const SizedBox(height: 80),
      ],
    );
  }
}

/// Sodda kompas chizuvchisi
class _CompassPainter extends CustomPainter {
  final MyColors colors;
  final bool isLightMode;

  _CompassPainter({required this.colors, required this.isLightMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Yo'nalish harflari
    final directions = ['N', 'E', 'S', 'W'];
    final dirColors = [
      colors.softGold, 
      colors.textSecondary.withOpacity(0.7),
      colors.textSecondary.withOpacity(0.7),
      colors.textSecondary.withOpacity(0.7),
    ];

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * pi / 180;
      final x = center.dx + (radius - 10) * cos(angle);
      final y = center.dy + (radius - 10) * sin(angle);

      final textSpan = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: dirColors[i],
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // Kichik chiziqlar (har 30 drajada)
    final tickPaint = Paint()
      ..color = colors.textMuted.withOpacity(isLightMode ? 0.3 : 0.24)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 36; i++) {
      if (i % 9 == 0) continue; // N, E, S, W joylarini o'tkazib yubor
      final angle = (i * 10 - 90) * pi / 180;
      final tickLength = i % 3 == 0 ? 12.0 : 6.0;
      final outerX = center.dx + (radius + 5) * cos(angle);
      final outerY = center.dy + (radius + 5) * sin(angle);
      final innerX = center.dx + (radius + 5 - tickLength) * cos(angle);
      final innerY = center.dy + (radius + 5 - tickLength) * sin(angle);

      canvas.drawLine(Offset(outerX, outerY), Offset(innerX, innerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaAlignedMosque extends StatefulWidget {
  final bool isAligned;
  final MyColors colors;

  const _QiblaAlignedMosque({required this.isAligned, required this.colors});

  @override
  State<_QiblaAlignedMosque> createState() => _QiblaAlignedMosqueState();
}

class _QiblaAlignedMosqueState extends State<_QiblaAlignedMosque> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 800)
    );
    if (widget.isAligned) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _QiblaAlignedMosque oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAligned && !oldWidget.isAligned) {
      HapticFeedback.heavyImpact();
      _pulseController.repeat(reverse: true);
    } else if (!widget.isAligned && oldWidget.isAligned) {
      _pulseController.stop();
      _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulse = _pulseController.value;
        return Container(
          width: 60 + (pulse * 8),
          height: 60 + (pulse * 8),
          decoration: BoxDecoration(
            color: Color.lerp(widget.colors.softGold, Colors.white, widget.isAligned ? 0.2 : 0.0),
            shape: BoxShape.circle,
            boxShadow: [
              if (widget.isAligned) ...[
                BoxShadow(
                  color: widget.colors.softGold.withOpacity(0.6 + (pulse * 0.4)),
                  blurRadius: 20 + (pulse * 15),
                  spreadRadius: 5 + (pulse * 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3 + (pulse * 0.2)),
                  blurRadius: 10 + (pulse * 10),
                  spreadRadius: 2 + (pulse * 3),
                ),
              ] else
                BoxShadow(
                  color: widget.colors.softGold.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Center(
             child: Icon(
                Icons.mosque_rounded,
                color: widget.colors.deepEmerald,
                size: 30 + (pulse * 4),
             ),
          ),
        );
      },
    );
  }
}
