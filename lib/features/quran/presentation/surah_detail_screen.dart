import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:muslim_pro/features/quran/audio_service.dart';
import 'package:muslim_pro/features/quran/quran_settings_provider.dart';
import 'package:muslim_pro/features/quran/data/quran_model.dart';
import 'package:translit/translit.dart';
import '../quran_provider.dart';

class SurahDetailScreen extends ConsumerWidget {
  final SurahModel surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(surahDetailProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final settings = ref.watch(quranSettingsProvider);

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: settings.textColor),
        ),
        title: Column(
          children: [
            Text(
              surah.englishName,
              style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.w700,
                color: settings.textColor,
              ),
            ),
            Text(
              surah.name,
              style: GoogleFonts.amiri(
                fontSize: 14, 
                color: AppColors.softGold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showSettings(context, ref),
            icon: Icon(Icons.settings_outlined, color: settings.textColor),
          ),
        ],
      ),
      body: _buildBody(context, detailState, audioState, settings, ref),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuranSettingsSheet(),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SurahDetailState detailState,
    AudioPlayerState audioState,
    QuranSettings settings,
    WidgetRef ref,
  ) {
    if (detailState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.softGold),
            const SizedBox(height: 16),
            Text('Oyatlar yuklanmoqda...', style: TextStyle(color: settings.textColor)),
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
            Text(detailState.error!, style: TextStyle(color: settings.textColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(surahDetailProvider.notifier).loadAyahs(surah),
              child: const Text('Qayta yuklash'),
            ),
          ],
        ),
      );
    }

    final isCurrentSurah = audioState.currentSurahNumber == surah.number;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: detailState.ayahs.length + (surah.number != 1 && surah.number != 9 ? 1 : 0),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) =>  Divider(
                  height: 48,
                  color: settings.textColor.withOpacity(0.1),
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  // Bismillah (Tawba va Fotiha surasi uchun alohida emas)
                  if (surah.number != 1 && surah.number != 9) {
                    if (index == 0) return _buildBismillah(settings);
                    index--;
                  }
                  
                  final ayah = detailState.ayahs[index];
                  final isActive = isCurrentSurah && audioState.currentAyahIndex == index;

                  return _AyahItem(
                    ayah: ayah,
                    isActive: isActive,
                    isPlaying: isActive && audioState.isPlaying,
                    settings: settings,
                    onPlay: () {
                      if (isActive) {
                        ref.read(audioPlayerProvider.notifier).togglePlayPause();
                      } else {
                        ref.read(audioPlayerProvider.notifier).playSurah(
                          surahNumber: surah.number,
                          surahName: surah.englishName,
                          ayahs: detailState.ayahs,
                          startAyah: index,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        // Floating Mini Player
        if (audioState.hasAudio && audioState.currentSurahNumber == surah.number)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _FloatingPlayer(audioState: audioState),
          ),
      ],
    );
  }

  Widget _buildBismillah(QuranSettings settings) {
    return Center(
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        style: GoogleFonts.amiri(
          fontSize: 28,
          color: AppColors.softGold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AyahItem extends StatelessWidget {
  final AyahModel ayah;
  final bool isActive;
  final bool isPlaying;
  final QuranSettings settings;
  final VoidCallback onPlay;

  const _AyahItem({
    required this.ayah,
    required this.isActive,
    required this.isPlaying,
    required this.settings,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ayah.verseKey,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softGold,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: AppColors.softGold, size: 32),
              onPressed: onPlay,
            ),
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 20, color: settings.textColor.withOpacity(0.4)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '${ayah.text}\n\n${ayah.translation}'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nusxalandi')));
              },
            ),
            IconButton(
              icon: Icon(Icons.share_rounded, size: 20, color: settings.textColor.withOpacity(0.4)),
              onPressed: () {
                Share.share('${ayah.text}\n\n${ayah.translation}\n\n(Muslim Pro ilovasidan)');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Arabic Text / Tajweed
        settings.isTajweedMode && ayah.textTajweed != null
            ? Directionality(
                textDirection: TextDirection.rtl,
                child: HtmlWidget(
                  ayah.textTajweed!,
                  textStyle: GoogleFonts.amiri(
                    fontSize: settings.fontSize + 4,
                    height: 2.0,
                    color: settings.textColor,
                  ),
                  customStylesBuilder: (element) {
                    if (element.classes.contains('ham_wasl')) return {'color': '#AAAAAA'};
                    if (element.classes.contains('laam_shamsiyah')) return {'color': '#AAAAAA'};
                    if (element.classes.contains('madda_normal')) return {'color': '#FF0000'};
                    if (element.classes.contains('madda_permissible')) return {'color': '#FF00FF'};
                    if (element.classes.contains('madda_necessary')) return {'color': '#FF0000'};
                    if (element.classes.contains('qlq')) return {'color': '#0000FF'};
                    if (element.classes.contains('ghn')) return {'color': '#00AA00'};
                    if (element.classes.contains('ikhfa')) return {'color': '#DDAA00'};
                    if (element.classes.contains('iqlab')) return {'color': '#008800'};
                    return null;
                  },
                ),
              )
            : Text(
                ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: settings.fontSize + 4,
                  height: 2.0,
                  color: settings.textColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
        
        const SizedBox(height: 16),
        
        // Translation
        if (ayah.translation != null)
          Text(
            settings.script == TranslationScript.latin 
                ? Translit().toTranslit(source: ayah.translation!)
                : ayah.translation!,
            style: GoogleFonts.montserrat(
              fontSize: settings.fontSize - 6,
              height: 1.7,
              color: settings.textColor.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _FloatingPlayer extends ConsumerWidget {
  final AudioPlayerState audioState;
  const _FloatingPlayer({required this.audioState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
            onPressed: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${audioState.currentSurahName} (${(audioState.currentAyahIndex ?? 0) + 1}-oyat)',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: audioState.progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(AppColors.softGold),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            onPressed: () => ref.read(audioPlayerProvider.notifier).stop(),
          ),
        ],
      ),
    );
  }
}

class _QuranSettingsSheet extends ConsumerWidget {
  const _QuranSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quranSettingsProvider);
    final notifier = ref.read(quranSettingsProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'O\'qish sozlamalari',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Theme
                  const Text('Fon rangi', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ThemeButton(
                        label: 'Oq',
                        color: Colors.white,
                        isSelected: settings.theme == QuranTheme.white,
                        onTap: () => notifier.setTheme(QuranTheme.white),
                      ),
                      const SizedBox(width: 12),
                      _ThemeButton(
                        label: 'Sepia',
                        color: const Color(0xFFF4ECD8),
                        isSelected: settings.theme == QuranTheme.sepia,
                        onTap: () => notifier.setTheme(QuranTheme.sepia),
                      ),
                      const SizedBox(width: 12),
                      _ThemeButton(
                        label: 'Dark',
                        color: const Color(0xFF2C2C2C),
                        isSelected: settings.theme == QuranTheme.dark,
                        onTap: () => notifier.setTheme(QuranTheme.dark),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Tajweed Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tajvidli rejim', style: TextStyle(color: Colors.white, fontSize: 16)),
                      Switch(
                        value: settings.isTajweedMode,
                        activeColor: AppColors.softGold,
                        onChanged: (val) => notifier.setTajweedMode(val),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Script Toggle (Lotin / Kirill)
                  const Text('Alifbo (Tarjima)', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ThemeButton(
                        label: 'Lotin',
                        color: Colors.white.withOpacity(0.05),
                        isSelected: settings.script == TranslationScript.latin,
                        onTap: () => notifier.setScript(TranslationScript.latin),
                      ),
                      const SizedBox(width: 12),
                      _ThemeButton(
                        label: 'Kirill',
                        color: Colors.white.withOpacity(0.05),
                        isSelected: settings.script == TranslationScript.cyrillic,
                        onTap: () => notifier.setScript(TranslationScript.cyrillic),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Font Size
                  const Text('Shrift o\'lchami', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Slider(
                    value: settings.fontSize,
                    min: 16,
                    max: 40,
                    activeColor: AppColors.softGold,
                    inactiveColor: Colors.white10,
                    onChanged: (val) => notifier.setFontSize(val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({required this.label, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.softGold : Colors.transparent, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
