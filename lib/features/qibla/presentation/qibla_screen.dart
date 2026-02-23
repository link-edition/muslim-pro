import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
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
          setState(() {
            _error = 'Joylashuvga ruxsat berilmadi';
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
      setState(() {
        _error = 'Xatolik: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          'Qibla',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.softGold),
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
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldMid,
                  foregroundColor: AppColors.softGold,
                ),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return const Center(
        child: Text('Joylashuvga ruxsat kerak'),
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.softGold),
          );
        }

        final qibla = snapshot.data!;
        return _QiblaCompass(qibla: qibla);
      },
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final QiblahDirection qibla;
  const _QiblaCompass({required this.qibla});

  @override
  Widget build(BuildContext context) {
    final qiblaDirection = qibla.qiblah;
    final compassDirection = qibla.direction;

    // Qibla to'g'ri yo'nalishda bo'lsa
    final isAligned = (qiblaDirection.abs() < 5);

    return Column(
      children: [
        const Spacer(flex: 1),

        // Daraja ko'rsatkichi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isAligned
                ? AppColors.softGold.withOpacity( 0.15)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAligned
                  ? AppColors.softGold
                  : AppColors.emeraldLight.withOpacity( 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAligned ? Icons.check_circle : Icons.explore,
                color: isAligned ? AppColors.softGold : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isAligned
                    ? 'Qibla yo\'nalishidasiz!'
                    : '${compassDirection.toStringAsFixed(1)}°',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isAligned ? AppColors.softGold : AppColors.textPrimary,
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
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardBg,
                      border: Border.all(
                        color: AppColors.emeraldLight.withOpacity( 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softGold.withOpacity( 0.08),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _CompassPainter(),
                    ),
                  ),
                ),

                // Qibla yo'nalish ko'rsatgichi (ka'ba)
                Transform.rotate(
                  angle: qiblaDirection * (pi / 180),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: isAligned ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          if (isAligned && value > 0.9) {
                            HapticFeedback.selectionClick();
                          }
                          return Container(
                            width: 54 + (value * 6),
                            height: 54 + (value * 6),
                            decoration: BoxDecoration(
                              color: Color.lerp(AppColors.softGold, Colors.white, value * 0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.softGold.withOpacity( 0.4 + (value * 0.2)),
                                  blurRadius: 15 + (value * 10),
                                  spreadRadius: 2 + (value * 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.mosque_rounded,
                              color: AppColors.deepEmerald,
                              size: 28 + (value * 2),
                            ),
                          );
                        },
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
                    color: AppColors.softGold,
                    border: Border.all(color: AppColors.deepEmerald, width: 3),
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
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.emeraldLight.withOpacity( 0.1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.softGold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Telefoningizni tekis ushlang va sekin aylantiring',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Yo'nalish harflari
    final directions = ['N', 'E', 'S', 'W'];
    final dirColors = [
      const Color(0xFFD4AF37), // N - oltin
      Colors.white70,
      Colors.white70,
      Colors.white70,
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
      ..color = Colors.white24
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
