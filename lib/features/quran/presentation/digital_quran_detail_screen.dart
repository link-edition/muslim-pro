import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/quran_model.dart';
import '../data/quran_tajweed_service.dart';
import 'tajweed_digital_parser.dart';
import 'package:muslim_pro/core/localization.dart';

class DigitalQuranDetailScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  const DigitalQuranDetailScreen({super.key, required this.surah});

  @override
  ConsumerState<DigitalQuranDetailScreen> createState() => _DigitalQuranDetailScreenState();
}

class _DigitalQuranDetailScreenState extends ConsumerState<DigitalQuranDetailScreen> {
  double _fontSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final tajweedData = ref.watch(QuranTajweedService.provider);
    final l10n = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF040E0A) : context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.translate(widget.surah.nameUz),
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20.0, 48.0)),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(20.0, 48.0)),
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
      body: tajweedData.when(
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.softGold)),
        error: (err, stack) => Center(child: Text(l10n.translate('error_msg'))),
        data: (allAyahs) {
          final surahAyahs = QuranTajweedService.getAyahsBySurah(allAyahs, widget.surah.number);
          
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: surahAyahs.length,
            separatorBuilder: (context, index) => Divider(color: context.colors.emeraldLight.withOpacity(0.1), height: 32),
            itemBuilder: (context, index) {
              final ayah = surahAyahs[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.softGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.softGold.withOpacity(0.3), width: 0.5),
                        ),
                        child: Text(
                          '${ayah.surah}:${ayah.ayah}',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.softGold),
                        ),
                      ),
                      // Copy button? I'll add that later.
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText.rich(
                    TextSpan(
                      children: TajweedDigitalParser.parse(
                        ayah,
                        fontSize: _fontSize,
                        defaultColor: isDark ? Colors.white : context.colors.textPrimary,
                        fontFamily: 'Amiri', // Or other Uthmanic font
                      ),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
