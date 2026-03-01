import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/quran/audio_service.dart';
import 'package:muslim_pro/features/quran/data/quran_model.dart';
import '../quran_provider.dart';
import '../quran_settings_provider.dart';
import 'quran_settings_sheet.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:muslim_pro/core/localization.dart';

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
      backgroundColor: context.colors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark 
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1200), Color(0xFF0F0A00), Color(0xFF000000)],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [context.colors.creamBgTop, context.colors.creamBgBottom],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: (detailState.isLoading && detailState.ayahs.isEmpty)
                    ? Center(child: CircularProgressIndicator(color: context.colors.softGold))
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
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 36, color: context.colors.textSecondary),
          ),
          Column(
            children: [
              Text(
                ref.watch(localizationProvider).translate(widget.surah.uzbekPhoneticName),
                style: GoogleFonts.inter(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                widget.surah.name,
                style: GoogleFonts.amiri(color: context.colors.goldText, fontSize: 16),
              ),
            ],
          ),
          IconButton(
            onPressed: () => showQuranSettings(context),
            icon: Icon(Icons.settings_outlined, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTop(AudioPlayerState audioState, SurahDetailState detailState) {
    return Column(
      children: [
        const SizedBox(height: 8),
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
        const SizedBox(height: 4),
        _buildControls(audioState),
        const SizedBox(height: 12),
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
              activeTrackColor: context.colors.goldText,
              inactiveTrackColor: context.colors.emeraldLight.withOpacity(0.1),
              thumbColor: context.colors.goldText,
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
              Text(_formatDuration(state.position), style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
              Text(_formatDuration(state.duration), style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(AudioPlayerState state) {
    String repeatBadge = '';
    if (state.repeatMode == 1) {
      repeatBadge = '1';
    } else if (state.repeatMode == 5) repeatBadge = '5';
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
            style: GoogleFonts.inter(color: context.colors.goldText, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: () => ref.read(audioPlayerProvider.notifier).previousAyah(),
          icon: Icon(Icons.skip_previous_rounded, size: 36, color: context.colors.textPrimary),
        ),

        GestureDetector(
          onTap: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.colors.goldText,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: context.colors.goldText.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
              ],
            ),
            child: state.isLoading 
              ? Padding(padding: const EdgeInsets.all(20), child: CircularProgressIndicator(color: context.colors.background, strokeWidth: 3))
              : Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40, color: context.colors.background),
          ),
        ),

        IconButton(
          onPressed: () => ref.read(audioPlayerProvider.notifier).nextAyah(),
          icon: Icon(Icons.skip_next_rounded, size: 36, color: context.colors.textPrimary),
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
                color: state.repeatMode == 0 ? context.colors.textMuted : context.colors.goldText
              ),
              if (state.repeatMode != 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: context.colors.emeraldDark, shape: BoxShape.circle),
                    child: Text(
                      repeatBadge,
                      style: TextStyle(fontSize: 10, color: context.colors.softGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String arabic, String translation) {
    final l10n = ref.read(localizationProvider);
    Clipboard.setData(ClipboardData(text: "$arabic\n\n$translation"));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate('copy_success'), style: GoogleFonts.inter()),
        backgroundColor: context.colors.surface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareAyah(String arabic, String translation) {
    final l10n = ref.read(localizationProvider);
    Share.share("$arabic\n\n$translation\n\n${l10n.translate('share_msg')}");
  }



  Widget _buildAyahsList(AudioPlayerState audioState, SurahDetailState detailState) {
    if (detailState.ayahs.isEmpty) return const SizedBox.shrink();
    final quranSettings = ref.watch(quranSettingsProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: detailState.ayahs.length,
      itemBuilder: (context, index) {
        final ayah = detailState.ayahs[index];
        final isPlaying = audioState.currentAyahIndex == index;
        final translationText = quranSettings.translationScript == 'kril' 
            ? ayah.translationKril 
            : ayah.translation;

        final contentTile = ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => ref.read(audioPlayerProvider.notifier).playAyah(index),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.softGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isPlaying
                  ? Icon(Icons.volume_up_rounded, color: context.colors.softGold, size: 16)
                  : Text('${index + 1}', style: TextStyle(color: context.colors.softGold, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          title: Text(
            ayah.text,
            style: GoogleFonts.amiri(
              fontSize: quranSettings.arabicFontSize, 
              color: isPlaying ? context.colors.goldText : context.colors.textPrimary,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          subtitle: (translationText != null && translationText.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        translationText,
                        style: GoogleFonts.roboto(
                          fontSize: quranSettings.translationFontSize,
                          color: context.colors.textSecondary,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _copyToClipboard(ayah.text, translationText),
                            child: Opacity(
                              opacity: 0.3,
                              child: Icon(Icons.copy_rounded, size: 18, color: context.colors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _shareAyah(ayah.text, translationText),
                            child: Opacity(
                              opacity: 0.3,
                              child: Icon(Icons.share_rounded, size: 18, color: context.colors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : null,
        );

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isPlaying
                ? (isDarkMode ? context.colors.softGold.withOpacity(0.12) : const Color(0xFFD4AF37).withOpacity(0.08))
                : (isDarkMode ? context.colors.cardBg.withOpacity(0.4) : Colors.white.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(18),
            border: isPlaying
                ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1)
                : (isDarkMode ? null : Border.all(color: const Color(0xFFD4AF37).withOpacity(0.05))),
            boxShadow: isDarkMode ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: contentTile,
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
