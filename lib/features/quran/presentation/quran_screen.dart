import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../quran_provider.dart';
import '../data/quran_model.dart';
import 'surah_detail_screen.dart';
/// Qur'on suralar ro'yxati sahifasi (120 FPS optimized)
class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranListProvider);

    return Column(
      children: [
        // Qidiruv paneli
        _buildSearchBar(context),

        // Suralar soni
        if (!quranState.isLoading && quranState.filteredSurahs.isNotEmpty)
          _buildSurahCount(context, quranState),

        // Suralar ro'yxati
        Expanded(
          child: _buildSurahList(context, quranState),
        ),
      ],
    );
  }

  /// Qidiruv paneli
  Widget _buildSearchBar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isSearching
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: Border.all(
          color: _isSearching
              ? AppColors.primaryGreen
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          ref.read(quranListProvider.notifier).search(query);
        },
        onTap: () => setState(() => _isSearching = true),
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
          setState(() => _isSearching = false);
        },
        decoration: InputDecoration(
          hintText: 'Sura qidirish...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryGreen,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(quranListProvider.notifier).clearSearch();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: GoogleFonts.inter(fontSize: 15),
      ),
    );
  }

  /// Suralar soni
  Widget _buildSurahCount(BuildContext context, QuranListState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Text(
            '${state.filteredSurahs.length} sura',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.searchQuery.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              '(${state.allSurahs.length} dan)',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  /// Suralar ro'yxati (ListView.builder + RepaintBoundary)
  Widget _buildSurahList(BuildContext context, QuranListState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text('Suralar yuklanmoqda...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(quranListProvider.notifier).refresh(),
              child: const Text('Qayta yuklash'),
            ),
          ],
        ),
      );
    }

    if (state.filteredSurahs.isEmpty) {
      return FutureBuilder<List<ConnectivityResult>>(
        future: Connectivity().checkConnectivity(),
        builder: (context, snapshot) {
          final isOffline = snapshot.hasData && snapshot.data!.contains(ConnectivityResult.none);
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOffline ? Icons.wifi_off_rounded : Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  isOffline ? 'Oflayn rejim' : 'Sura topilmadi',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    isOffline 
                      ? 'Suralarni yuklash uchun internetga ulaning' 
                      : 'Qidiruv bo\'yicha hech narsa topilmadi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (isOffline) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(quranListProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta urinish'),
                  ),
                ],
              ],
            ),
          );
        }
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(quranListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.filteredSurahs.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        // 120 FPS: cacheExtent kengaytirish — oldinda/orqada
        // ko'rinmaydigan elementlarni tayyorlab qo'yadi
        cacheExtent: 300,
        itemBuilder: (context, index) {
          final surah = state.filteredSurahs[index];
          // Har bir elementni RepaintBoundary bilan izolyatsiya
          return RepaintBoundary(
            child: _SurahCard(
              surah: surah,
              onTap: () => _openSurah(context, surah),
            ),
          );
        },
      ),
    );
  }

  /// Sura sahifasini ochish (CupertinoPageRoute)
  void _openSurah(BuildContext context, SurahModel surah) {
    ref.read(surahDetailProvider.notifier).loadAyahs(surah);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => SurahDetailScreen(surah: surah),
      ),
    );
  }
}

/// Sura kartasi (alohida widget — optimized)
class _SurahCard extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const _SurahCard({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Raqam
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nomi va ma'lumotlari
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: surah.revelationType == 'Meccan'
                                ? Colors.amber.withValues(alpha: 0.15)
                                : Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            surah.revelationType == 'Meccan'
                                ? 'Makka'
                                : 'Madina',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: surah.revelationType == 'Meccan'
                                  ? Colors.amber.shade800
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${surah.ayahCount} oyat',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arabcha nomi
              Text(
                surah.name,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
