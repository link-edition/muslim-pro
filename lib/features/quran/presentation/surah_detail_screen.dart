import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/quran/audio_service.dart';
import 'package:muslim_pro/features/quran/data/quran_model.dart';
import '../quran_provider.dart';

class SurahDetailScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSurah();
    });
  }

  void _loadSurah() async {
    final audioState = ref.read(audioPlayerProvider);
    if (audioState.currentSurahNumber != widget.surah.number) {
      final detailNotifier = ref.read(surahDetailProvider.notifier);
      await detailNotifier.loadAyahs(widget.surah);
      final detailState = ref.read(surahDetailProvider);
      
      if (detailState.ayahs.isNotEmpty) {
        ref.read(audioPlayerProvider.notifier).playSurah(
              surahNumber: widget.surah.number,
              surahName: widget.surah.englishName,
              ayahs: detailState.ayahs,
              autoPlay: false, 
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final detailState = ref.watch(surahDetailProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0A00),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1200), Color(0xFF0F0A00), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: (detailState.isLoading && detailState.ayahs.isEmpty)
                    ? const Center(child: CircularProgressIndicator(color: AppColors.softGold))
                    : Column(
                        children: [
                          _buildPlayerTop(audioState, detailState),
                          Expanded(child: _buildAyahsList(audioState, detailState)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 36, color: Colors.white70),
          ),
          Text(
            'Qur\'on Audio',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPlayerTop(AudioPlayerState audioState, SurahDetailState detailState) {
    String? currentText;
    if (audioState.currentAyahIndex != null && audioState.ayahs.isNotEmpty) {
      final a = audioState.ayahs[audioState.currentAyahIndex!];
      currentText = a.text;
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          widget.surah.name,
          style: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.softGold),
        ),
        const SizedBox(height: 2),
        Text(
          widget.surah.englishName,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 16),

        // Subtitles maydoni (Faqat Arabcha)
        Container(
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentText != null && currentText.isNotEmpty)
                    Text(
                      currentText,
                      style: GoogleFonts.amiri(fontSize: 28, color: AppColors.softGold, height: 1.6),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    )
                  else
                    Icon(Icons.headphones_rounded, size: 40, color: AppColors.softGold.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        if (detailState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              detailState.error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

        _buildProgressBar(audioState),
        const SizedBox(height: 8),
        _buildControls(audioState),
        const SizedBox(height: 16),
        const Divider(color: Colors.white10, height: 1),
      ],
    );
  }

  Widget _buildProgressBar(AudioPlayerState state) {
    return Column(
      children: [
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              state.error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.softGold,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppColors.softGold,
            ),
            child: Slider(
              value: state.progress,
              onChanged: (val) {
                if (state.duration.inMilliseconds > 0) {
                  final position = Duration(milliseconds: (state.duration.inMilliseconds * val).toInt());
                  ref.read(audioPlayerProvider.notifier).seekTo(position);
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(state.position), style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(_formatDuration(state.duration), style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(AudioPlayerState state) {
    String repeatBadge = '';
    if (state.repeatMode == 1) repeatBadge = '1';
    else if (state.repeatMode == 5) repeatBadge = '5';
    else if (state.repeatMode == -1) repeatBadge = '∞';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => ref.read(audioPlayerProvider.notifier).cycleSpeed(),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: const CircleBorder(),
          ),
          child: Text(
            '${state.playbackSpeed}x',
            style: GoogleFonts.poppins(color: AppColors.softGold, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: () => ref.read(audioPlayerProvider.notifier).previousAyah(),
          icon: const Icon(Icons.skip_previous_rounded, size: 36, color: Colors.white),
        ),

        GestureDetector(
          onTap: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.softGold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.softGold.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: state.isLoading 
              ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
              : Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40, color: Colors.black),
          ),
        ),

        IconButton(
          onPressed: () => ref.read(audioPlayerProvider.notifier).nextAyah(),
          icon: const Icon(Icons.skip_next_rounded, size: 36, color: Colors.white),
        ),

        IconButton(
          onPressed: () => ref.read(audioPlayerProvider.notifier).cycleRepeatMode(),
          icon: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              Icon(
                Icons.repeat_rounded, 
                size: 26, 
                color: state.repeatMode == 0 ? Colors.white54 : AppColors.softGold
              ),
              if (state.repeatMode != 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: AppColors.emeraldDark, shape: BoxShape.circle),
                    child: Text(
                      repeatBadge,
                      style: const TextStyle(fontSize: 10, color: AppColors.softGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAyahsList(AudioPlayerState audioState, SurahDetailState detailState) {
    if (detailState.ayahs.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: detailState.ayahs.length,
      itemBuilder: (context, index) {
        final ayah = detailState.ayahs[index];
        final isPlaying = audioState.currentAyahIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isPlaying ? AppColors.softGold.withOpacity(0.12) : AppColors.cardBg.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: isPlaying ? Border.all(color: AppColors.softGold.withOpacity(0.3), width: 1) : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () => ref.read(audioPlayerProvider.notifier).playAyah(index),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.softGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isPlaying
                    ? const Icon(Icons.volume_up_rounded, color: AppColors.softGold, size: 16)
                    : Text('${index + 1}', style: const TextStyle(color: AppColors.softGold, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            title: Text(
              ayah.text,
              style: GoogleFonts.amiri(
                fontSize: 22, 
                color: isPlaying ? AppColors.softGold : Colors.white,
                height: 1.6,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return "00:00";
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
