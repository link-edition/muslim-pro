import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/quran_model.dart';
import '../quran_provider.dart';
import 'surah_detail_screen.dart';
import 'package:muslim_pro/core/localization.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  bool _isSuraTab = true;

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(quranListProvider);
    final l10n = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Container(
        decoration: isDark
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.creamBgTop,
                    context.colors.creamBgBottom,
                  ],
                ),
              ),
        child: Column(
          children: [
            // Custom App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new, size: 20,
                        color: isDark ? Colors.white : context.colors.deepEmerald),
                    ),
                    const Spacer(),
                    Text(
                      l10n.translate('quran_karim'),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (listState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Content
            if (listState.isLoading && listState.allSurahs.isEmpty)
              Expanded(
                child: Center(child: CircularProgressIndicator(color: context.colors.softGold)),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Custom Tab Segment
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? context.colors.cardBg
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? null : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSuraTab = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isSuraTab
                                        ? (isDark
                                            ? context.colors.emeraldDark.withOpacity(0.4)
                                            : const Color(0xFF0F3D2E))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.translate('sura'),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: _isSuraTab ? FontWeight.w600 : FontWeight.w500,
                                        color: _isSuraTab
                                            ? (isDark ? context.colors.softGold : Colors.white)
                                            : context.colors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSuraTab = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isSuraTab
                                        ? (isDark
                                            ? context.colors.emeraldDark.withOpacity(0.4)
                                            : const Color(0xFF0F3D2E))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.translate('juz'),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: !_isSuraTab ? FontWeight.w600 : FontWeight.w500,
                                        color: !_isSuraTab
                                            ? (isDark ? context.colors.softGold : Colors.white)
                                            : context.colors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isSuraTab)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? context.colors.cardBg : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark ? null : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (val) => ref.read(quranListProvider.notifier).search(val),
                            style: TextStyle(color: context.colors.textPrimary),
                            decoration: InputDecoration(
                              filled: false,
                              hintText: l10n.translate('search_surah'),
                              hintStyle: TextStyle(color: context.colors.textMuted),
                              prefixIcon: Icon(Icons.search, color: context.colors.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: _isSuraTab 
                        ? ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: listState.filteredSurahs.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final surah = listState.filteredSurahs[index];
                              return _SurahCard(surah: surah);
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            itemCount: 30,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _JuzCard(juzIndex: index + 1, allSurahs: listState.allSurahs);
                            },
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SurahCard extends ConsumerWidget {
  final SurahModel surah; 
  const _SurahCard({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? context.colors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? context.colors.emeraldLight.withOpacity(0.1)
              : const Color(0xFFD4AF37).withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            ref.read(surahDetailProvider.notifier).loadAyahs(surah);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Gold Surah Number Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFFD4AF37).withOpacity(0.15), const Color(0xFFD4AF37).withOpacity(0.05)]
                          : [const Color(0xFFD4AF37).withOpacity(0.12), const Color(0xFFD4AF37).withOpacity(0.04)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.watch(localizationProvider).translate(surah.uzbekPhoneticName),
                        style: GoogleFonts.inter(
                          color: isDark ? context.colors.textPrimary : const Color(0xFF0F3D2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ref.watch(localizationProvider).translate(surah.revelationType.toLowerCase())} • ${surah.ayahCount} ${ref.watch(localizationProvider).translate('oyat')}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: context.colors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  surah.name,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? context.colors.softGold : const Color(0xFF0A2E20),
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

const Map<int, int> _juzStartSurahs = {
  1: 1, 2: 2, 3: 2, 4: 3, 5: 4, 6: 4, 7: 5, 8: 6, 9: 7, 10: 8,
  11: 9, 12: 11, 13: 12, 14: 15, 15: 17, 16: 18, 17: 21, 18: 23, 19: 25, 20: 27,
  21: 29, 22: 33, 23: 36, 24: 39, 25: 41, 26: 46, 27: 51, 28: 58, 29: 67, 30: 78
};

class _JuzCard extends ConsumerWidget {
  final int juzIndex;
  final List<SurahModel> allSurahs;
  const _JuzCard({required this.juzIndex, required this.allSurahs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (allSurahs.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final targetSurahNumber = _juzStartSurahs[juzIndex] ?? 1;
    final startingSurah = allSurahs.firstWhere(
      (s) => s.number == targetSurahNumber,
      orElse: () => allSurahs.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? context.colors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? context.colors.emeraldLight.withOpacity(0.1)
              : const Color(0xFFD4AF37).withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            ref.read(surahDetailProvider.notifier).loadAyahs(startingSurah);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: startingSurah)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Gold Juz Number Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.12),
                        const Color(0xFFD4AF37).withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$juzIndex',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$juzIndex-${ref.watch(localizationProvider).translate('juz')}',
                        style: GoogleFonts.inter(
                          color: isDark ? context.colors.textPrimary : const Color(0xFF0F3D2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${ref.watch(localizationProvider).translate(startingSurah.uzbekPhoneticName)} dan boshlanadi',
                        style: GoogleFonts.inter(fontSize: 11, color: context.colors.textMuted, letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16,
                    color: isDark ? context.colors.softGold.withOpacity(0.5) : const Color(0xFF0F3D2E).withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
