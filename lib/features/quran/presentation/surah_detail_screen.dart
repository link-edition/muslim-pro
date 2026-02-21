import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../quran_provider.dart';
import '../audio_service.dart';
import '../data/quran_model.dart';

/// Sura tafsilot sahifasi — oyatlar ro'yxati
class SurahDetailScreen extends ConsumerWidget {
  final SurahModel surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(surahDetailProvider);
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              surah.englishName,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              surah.name,
              style: GoogleFonts.amiri(fontSize: 14, color: AppColors.gold),
            ),
          ],
        ),
        actions: [
          // Audio ijro tugmasi
          if (detailState.ayahs.isNotEmpty)
            IconButton(
              icon: Icon(
                audioState.isPlaying &&
                        audioState.currentSurahNumber == surah.number
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: AppColors.gold,
                size: 32,
              ),
              onPressed: () {
                if (audioState.isPlaying &&
                    audioState.currentSurahNumber == surah.number) {
                  ref.read(audioPlayerProvider.notifier).pause();
                } else {
                  ref.read(audioPlayerProvider.notifier).playSurah(
                        surahNumber: surah.number,
                        surahName: surah.englishName,
                        ayahs: detailState.ayahs,
                      );
                }
              },
            ),
        ],
      ),
      body: _buildBody(context, detailState, audioState, ref),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SurahDetailState detailState,
    AudioPlayerState audioState,
    WidgetRef ref,
  ) {
    if (detailState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text('Oyatlar yuklanmoqda...'),
          ],
        ),
      );
    }

    if (detailState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(detailState.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(surahDetailProvider.notifier).loadAyahs(surah),
              child: const Text('Qayta yuklash'),
            ),
          ],
        ),
      );
    }

    if (detailState.ayahs.isEmpty) {
      return const Center(child: Text('Oyatlar topilmadi'));
    }

    final isCurrentSurah = audioState.currentSurahNumber == surah.number;

    return Column(
      children: [
        // Bismillah sarlavhasi (Tawba surasi bundan mustasno)
        if (surah.number != 9) _buildBismillah(context),

        // Oyatlar ro'yxati
        Expanded(
          child: ListView.builder(
            itemCount: detailState.ayahs.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            cacheExtent: 200,
            itemBuilder: (context, index) {
              final ayah = detailState.ayahs[index];
              final isActive =
                  isCurrentSurah && audioState.currentAyahIndex == index;

              return RepaintBoundary(
                child: _AyahCard(
                  ayah: ayah,
                  isActive: isActive,
                  onPlayTap: () {
                    ref.read(audioPlayerProvider.notifier).playSurah(
                          surahNumber: surah.number,
                          surahName: surah.englishName,
                          ayahs: detailState.ayahs,
                          startAyah: index,
                        );
                  },
                ),
              );
            },
          ),
        ),

        // Mini-Player (agar audio ijro etilayotgan bo'lsa)
        if (audioState.hasAudio && isCurrentSurah)
          _buildMiniPlayer(context, audioState, ref),
      ],
    );
  }

  /// Bismillah sarlavha
  Widget _buildBismillah(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(
          fontSize: 24,
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Mini-Player (pastki panel)
  Widget _buildMiniPlayer(
    BuildContext context,
    AudioPlayerState audioState,
    WidgetRef ref,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: audioState.progress,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
              color: AppColors.primaryGreen,
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Oyat raqami
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audioState.currentSurahName ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Oyat ${(audioState.currentAyahIndex ?? 0) + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Boshqaruv tugmalari
              IconButton(
                onPressed: () =>
                    ref.read(audioPlayerProvider.notifier).previousAyah(),
                icon: const Icon(Icons.skip_previous_rounded, size: 28),
                color: AppColors.primaryGreen,
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () =>
                      ref.read(audioPlayerProvider.notifier).togglePlayPause(),
                  icon: Icon(
                    audioState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(audioPlayerProvider.notifier).nextAyah(),
                icon: const Icon(Icons.skip_next_rounded, size: 28),
                color: AppColors.primaryGreen,
              ),

              // Yopish
              IconButton(
                onPressed: () =>
                    ref.read(audioPlayerProvider.notifier).stop(),
                icon: const Icon(Icons.close, size: 20),
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Oyat kartasi
class _AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final bool isActive;
  final VoidCallback onPlayTap;

  const _AyahCard({
    required this.ayah,
    required this.isActive,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: AppColors.primaryGreen, width: 1.5)
            : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sarlavha: raqam + audio tugma
          Row(
            children: [
              // Oyat raqami
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Audio tugma
              GestureDetector(
                onTap: onPlayTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.gold
                        : AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive ? Icons.volume_up : Icons.play_arrow,
                    size: 18,
                    color: isActive ? Colors.white : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Arabcha matn (o'ngdan chapga)
          Text(
            ayah.text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 22,
              height: 2.0,
              color: isActive
                  ? AppColors.primaryGreenDark
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),

          // Tarjima (agar mavjud bo'lsa)
          if (ayah.translation != null && ayah.translation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(
              color: Colors.grey.withValues(alpha: 0.2),
              height: 1,
            ),
            const SizedBox(height: 8),
            Text(
              ayah.translation!,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
