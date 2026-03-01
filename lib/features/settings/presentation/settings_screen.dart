import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/features/settings/presentation/notification_settings_screen.dart';
import 'package:muslim_pro/features/quran/download_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  final List<Map<String, String>> adhanList = [
    {'id': 'mishary', 'name': 'Mishary Rashid Alafasy', 'path': 'audio/mishary.mp3'},
  ];



  @override
  void initState() {
    super.initState();
    // Ovoz tugaganda stateni yangilash
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _currentlyPlayingId = null);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(String id, String path) async {
    try {
      // Agar shu fayl aytilyotgan bo'lsa — to'xtatish
      if (_currentlyPlayingId == id) {
        await _audioPlayer.stop();
        setState(() => _currentlyPlayingId = null);
        return;
      }

      // Avvalgisini to'xtatish
      await _audioPlayer.stop();

      setState(() => _currentlyPlayingId = id);

      // Ovoz balandligini to'liq qo'yish
      await _audioPlayer.setVolume(1.0);

      // Asset'dan ijro etish (audioplayers uchun 'assets/' prefikssiz yoziladi)
      await _audioPlayer.play(AssetSource(path));

      debugPrint("ADHAN: Play boshlandi — $id, path: $path");

    } catch (e) {
      debugPrint("ADHAN ERROR: $e");
      Fluttertoast.showToast(
        msg: "Xatolik: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: context.colors.textPrimary),
        ),
        title: Text(
          l10n.translate('settings'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsGroup(l10n.translate('general'), [
            _SettingsTile(
              icon: Icons.language,
              title: l10n.translate('language'),
              subtitle: _getLanguageName(settings.language, l10n),
              onTap: () => _showLanguageDialog(context, ref),
            ),
            _SettingsTile(
              icon: settings.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              title: l10n.translate('theme'),
              subtitle: settings.isDarkMode ? l10n.translate('dark_mode') : l10n.translate('light_mode'),
              trailing: Switch(
                value: settings.isDarkMode,
                activeColor: context.colors.softGold,
                activeTrackColor: context.colors.emeraldMid,
                inactiveThumbColor: context.colors.textMuted,
                inactiveTrackColor: context.colors.cardBg,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleTheme(value);
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSettingsGroup(l10n.translate('notifications'), [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.iconBg.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications_active_outlined, color: context.colors.softGold, size: 24),
              ),
              title: Text(
                l10n.translate('notifications'),
                style: GoogleFonts.inter(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Azon ovozi, Juma va Bomdod eslatmalari',
                style: GoogleFonts.inter(
                  color: context.colors.textMuted,
                  fontSize: 12,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: context.colors.textMuted),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 20),
            _buildSettingsGroup(l10n.translate('about'), [
            _SettingsTile(
              icon: Icons.info_outline,
              title: l10n.translate('version'),
              subtitle: '1.2.0',
            ),
            const _FontSliderTile(),
            const _DownloadProgressTile(),
          ]),
        ],
      ),
    );
  }

  String _getLanguageName(String langCode, AppLocalization l10n) {
    switch (langCode) {
      case 'en': return l10n.translate('language_sub_en');
      case 'ar': return l10n.translate('language_sub_ar');
      case 'id': return l10n.translate('language_sub_id');
      case 'uz': return l10n.translate('language_sub_uz');
      case 'uz_cyr': return l10n.translate('uzbek_cyrillic');
      default: return l10n.translate('uzbek_latin');
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = ref.read(localizationProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.translate('select_language'),
          style: GoogleFonts.inter(color: context.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageTile(code: 'en', name: l10n.translate('language_sub_en'), flag: '🇬🇧', ref: ref),
            _LanguageTile(code: 'ar', name: l10n.translate('language_sub_ar'), flag: '🇸🇦', ref: ref),
            _LanguageTile(code: 'id', name: l10n.translate('language_sub_id'), flag: '🇮🇩', ref: ref),
            _LanguageTile(code: 'uz', name: l10n.translate('language_sub_uz'), flag: '🇺🇿', ref: ref),
            _LanguageTile(code: 'uz_cyr', name: l10n.translate('uzbek_cyrillic'), flag: '🇺🇿', ref: ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? context.colors.softGold : const Color(0xFFD4AF37),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? context.colors.cardBg : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? context.colors.emeraldLight.withOpacity(0.1)
                  : const Color(0xFFD4AF37).withOpacity(0.08),
            ),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: context.colors.softGold, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: context.colors.textPrimary,
        ),
      ),
      trailing: trailing ?? (subtitle != null ? Text(
        subtitle!,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: context.colors.textMuted,
        ),
      ) : null),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String name;
  final String flag;
  final WidgetRef ref;

  const _LanguageTile({
    required this.code, required this.name, required this.flag, required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(name, style: TextStyle(color: context.colors.textPrimary)),
      onTap: () {
        ref.read(settingsProvider.notifier).setLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}

class _FontSliderTile extends ConsumerWidget {
  const _FontSliderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_size, color: context.colors.softGold, size: 22),
              const SizedBox(width: 16),
              Text(
                l10n.translate('font_size'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(settings.fontScale * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.colors.emeraldMid,
              inactiveTrackColor: context.colors.cardBgLight,
              thumbColor: context.colors.softGold,
              overlayColor: context.colors.softGold.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: settings.fontScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setFontScale(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadProgressTile extends ConsumerWidget {
  const _DownloadProgressTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadManager = ref.watch(AudioDownloadManager.provider);
    final l10n = ref.watch(localizationProvider);

    if (!downloadManager.isDownloading && downloadManager.downloadedCount == 0) {
      return const SizedBox.shrink(); // Hide if completely inactive
    }

    final int totalSurahs = 114;
    final int downloaded = downloadManager.downloadedCount;
    final String currentSurah = downloadManager.currentDownloadingSurahName;
    final double surahProgress = downloadManager.currentSurahProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_download_outlined, color: context.colors.softGold, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Qur'on Audiosi (${downloaded}/$totalSurahs)",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              if (downloaded < totalSurahs)
                IconButton(
                  icon: Icon(
                    downloadManager.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: context.colors.softGold,
                  ),
                  onPressed: () {
                    if (downloadManager.isPaused) {
                      downloadManager.resume();
                    } else {
                      downloadManager.pause();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (downloadManager.isDownloading || (downloadManager.isPaused && downloaded < totalSurahs)) ...[
            Text(
              downloadManager.isPaused ? "To'xtatilgan: $currentSurah" : "Yuklanmoqda: $currentSurah",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: downloadManager.isPaused ? Colors.orangeAccent : context.colors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: surahProgress,
                backgroundColor: context.colors.cardBgLight,
                valueColor: AlwaysStoppedAnimation<Color>(context.colors.softGold),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(surahProgress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.softGold,
                ),
              ),
            ),
          ] else if (downloaded == totalSurahs) ...[
            Text(
              "Barcha suralar yuklab olindi",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colors.emeraldLight,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
