import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/quran_model.dart';
import '../quran_provider.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(quranListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(
          'Qur\'oni Karim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (listState.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: listState.isLoading && listState.allSurahs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.softGold))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    onChanged: (val) => ref.read(quranListProvider.notifier).search(val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardBg,
                      hintText: 'Sura qidirish...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(Icons.search, color: Colors.white30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: listState.filteredSurahs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final surah = listState.filteredSurahs[index];
                      return _SurahCard(surah: surah);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SurahCard extends ConsumerWidget {
  final SurahModel surah; 
  const _SurahCard({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.softGold.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            ref.read(surahDetailProvider.notifier).loadAyahs(surah);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.brightness_7, color: AppColors.softGold.withOpacity(0.2), size: 44),
                    Text(
                      '${surah.number}',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.softGold),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.englishName,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${surah.revelationType.toUpperCase()} • ${surah.ayahCount} OYAT',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                Text(
                  surah.name,
                  style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.softGold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
