import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../qibla_provider.dart';
import '../qibla_service.dart';

/// Qibla kompas sahifasi
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaProvider);

    return Stack(
      children: [
        // Asosiy kontent
        _buildMainContent(context, qiblaState, ref),

        // Kalibrlash overlay
        if (qiblaState.showCalibration)
          _buildCalibrationOverlay(context, ref),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    QiblaState qiblaState,
    WidgetRef ref,
  ) {
    // Yuklanish holati
    if (qiblaState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text('Kompas tayyorlanmoqda...'),
          ],
        ),
      );
    }

    // Kompas yo'q
    if (!qiblaState.hasCompass) {
      return _buildNoCompassState(context, qiblaState);
    }

    return Column(
      children: [
        const SizedBox(height: 16),

        // Qibla burchagi va aniqlik
        _buildInfoHeader(context, qiblaState, ref),

        // Kompas (RepaintBoundary bilan izolyatsiya — faqat kompas qayta chiziladi)
        Expanded(
          child: RepaintBoundary(
            child: _buildCompass(context, qiblaState),
          ),
        ),

        // Masofa va kalibrlash
        _buildBottomInfo(context, qiblaState, ref),
      ],
    );
  }

  /// Kompas sensori yo'q holati
  Widget _buildNoCompassState(BuildContext context, QiblaState qiblaState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.sensors_off,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Kompas sensori mavjud emas',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Qurilmangizda magnitometr (kompas sensori) topilmadi. '
              'Qibla yo\'nalishini ko\'rish uchun kompas sensori kerak.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            if (qiblaState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                qiblaState.error!,
                style: TextStyle(color: Colors.red.shade400, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Yuqori ma'lumot paneli
  Widget _buildInfoHeader(
    BuildContext context,
    QiblaState qiblaState,
    WidgetRef ref,
  ) {
    final accuracy = qiblaState.accuracy;
    final accuracyColor = switch (accuracy) {
      CompassAccuracy.high => Colors.green,
      CompassAccuracy.medium => Colors.orange,
      CompassAccuracy.low => Colors.red,
    };
    final accuracyText = switch (accuracy) {
      CompassAccuracy.high => 'Yuqori',
      CompassAccuracy.medium => 'O\'rta',
      CompassAccuracy.low => 'Past',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Qibla burchagi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qibla yo\'nalishi',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${qiblaState.qiblaDirection.toStringAsFixed(1)}°',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),

          // Aniqlik ko'rsatkichi
          GestureDetector(
            onTap: () => ref.read(qiblaProvider.notifier).toggleCalibration(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accuracyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accuracyColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accuracyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Aniqlik: $accuracyText',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accuracyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kompas widgeti
  Widget _buildCompass(BuildContext context, QiblaState qiblaState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final compassSize = screenWidth * 0.78;

    return Center(
      child: SizedBox(
        width: compassSize,
        height: compassSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Tashqi kompas siferblati (qurilma bilan aylanadi)
            AnimatedRotation(
              turns: qiblaState.heading / -360,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: _CompassDial(size: compassSize),
            ),

            // 2. Ka'ba ko'rsatkichi (qibla yo'nalishida)
            AnimatedRotation(
              turns: (qiblaState.qiblaDirection - qiblaState.heading) / -360,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: _KaabaIndicator(size: compassSize),
            ),

            // 3. Markaziy nuqta
            _CenterPoint(),
          ],
        ),
      ),
    );
  }

  /// Pastki ma'lumot paneli
  Widget _buildBottomInfo(
    BuildContext context,
    QiblaState qiblaState,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Makkagacha masofa
          if (qiblaState.distanceKm != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Makkagacha masofa',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${qiblaState.distanceKm!.toStringAsFixed(0)} km',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Kalibrlash tugmasi
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(qiblaProvider.notifier).toggleCalibration(),
                  icon: const Icon(Icons.tune, size: 16),
                  label: Text(
                    'Sozlash',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            )
          else
            // Masofa mavjud bo'lmasa
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Masofa aniqlanmadi',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      ref.read(qiblaProvider.notifier).reconnect(),
                  child: const Text('Qayta ulanish'),
                ),
              ],
            ),

          // Xatolik xabari
          if (qiblaState.error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, 
                    color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      qiblaState.error!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Kalibrlash ko'rsatmasi overlay
  Widget _buildCalibrationOverlay(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(qiblaProvider.notifier).hideCalibration(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikonka
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.screen_rotation,
                    color: AppColors.primaryGreen,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // Sarlavha
                Text(
                  'Kompasni sozlash',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Ko'rsatma
                Text(
                  'Aniqlikni oshirish uchun telefonni\n'
                  'havoda "8" shaklida harakatlantiring.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // "8" shakli ko'rsatma rasmi
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '∞',
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Qo'shimcha ko'rsatmalar
                _CalibrationStep(
                  number: '1',
                  text: 'Telefonni tekis ushlab turing',
                ),
                const SizedBox(height: 8),
                _CalibrationStep(
                  number: '2',
                  text: 'Havoda katta "8" shaklini chizing',
                ),
                const SizedBox(height: 8),
                _CalibrationStep(
                  number: '3',
                  text: 'Bir necha marta takrorlang',
                ),
                const SizedBox(height: 24),

                // Yopish tugmasi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(qiblaProvider.notifier).hideCalibration(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Tushundim',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kalibrlash bosqichi
class _CalibrationStep extends StatelessWidget {
  final String number;
  final String text;

  const _CalibrationStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

/// Kompas siferblati (tashqi aylana)
class _CompassDial extends StatelessWidget {
  final double size;

  const _CompassDial({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassDialPainter(
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

/// Kompas siferblat rassomi
class _CompassDialPainter extends CustomPainter {
  final bool isDark;

  _CompassDialPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Tashqi aylana
    final outerCirclePaint = Paint()
      ..color = isDark
          ? Colors.grey.shade800
          : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, outerCirclePaint);

    // Ichki aylana
    final innerCirclePaint = Paint()
      ..color = isDark
          ? Colors.grey.shade700
          : Colors.grey.shade100
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 20, innerCirclePaint);

    // Tomonlar — N, E, S, W
    final directions = ['N', 'E', 'S', 'W'];
    final directionColors = [
      Colors.red, // N - qizil
      isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      isDark ? Colors.grey.shade400 : Colors.grey.shade600,
    ];

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final textRadius = radius - 36;
      final x = center.dx + textRadius * math.cos(angle);
      final y = center.dy + textRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: directionColors[i],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Daraja chiziqlari (har 30 gradusda)
    for (int i = 0; i < 360; i += 30) {
      if (i % 90 == 0) continue; // N, E, S, W o'rnini tashlab ketamiz

      final angle = (i - 90) * math.pi / 180;
      final textRadius = radius - 36;
      final x = center.dx + textRadius * math.cos(angle);
      final y = center.dy + textRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i°',
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Chiziqlar (har 10 gradusda kichik, 30 da katta)
    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final isMain = i % 30 == 0;
      final outerR = radius - 6;
      final innerR = isMain ? radius - 18 : radius - 14;

      final p1 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = isMain
            ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
        ..strokeWidth = isMain ? 2 : 1;

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ka'ba ko'rsatkichi
class _KaabaIndicator extends StatelessWidget {
  final double size;

  const _KaabaIndicator({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Ka'ba belgisi
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mosque, color: Colors.white, size: 20),
                Text(
                  'Ka\'ba',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Chiziq
          Expanded(
            child: Center(
              child: Container(
                width: 2,
                height: size / 2 - 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Markaziy nuqta
class _CenterPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}
