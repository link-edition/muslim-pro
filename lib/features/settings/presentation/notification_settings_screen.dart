import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';

import 'package:audioplayers/audioplayers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  final List<Map<String, String>> adhanList = [
    {
      'id': 'mishary',
      'name': 'Mishary Rashid Alafasy',
      'path': 'audio/mishary.mp3',
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(String adhanId, String path) async {
    if (_currentlyPlayingId == adhanId) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingId = null;
      });
    } else {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingId = adhanId;
      });
      await _audioPlayer.play(AssetSource(path));
      
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _currentlyPlayingId = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.translate('notifications'), style: TextStyle(color: context.colors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.softGold),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        children: [
          SwitchListTile(
            title: Text(
              l10n.translate('notifications'),
              style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Asosiy namoz bildirishnomalarini yoqish/o\'chirish',
              style: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 13),
            ),
            value: settings.notificationsEnabled,
            activeColor: context.colors.softGold,
            secondary: Icon(Icons.notifications_outlined, color: context.colors.softGold),
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications(value);
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: Text(
              l10n.translate('adhan_voice'),
              style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Namoz vaqtida azon ovozi chalinsinmi?',
              style: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 13),
            ),
            value: settings.adhanEnabled,
            activeColor: context.colors.softGold,
            secondary: Icon(Icons.volume_up_outlined, color: context.colors.softGold),
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleAdhan(value);
            },
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: settings.adhanEnabled 
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.softGold.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Azon ovozini tanlang',
                            style: GoogleFonts.inter(
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ...adhanList.map((adhan) {
                          final isSelected = settings.selectedAdhan == adhan['id'];
                          final isPlaying = _currentlyPlayingId == adhan['id'];
                          
                          return ListTile(
                            title: Text(
                              adhan['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? context.colors.softGold : context.colors.textPrimary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                                    color: isPlaying ? Colors.redAccent : context.colors.softGold,
                                    size: 24,
                                  ),
                                  onPressed: () => _playPreview(adhan['id']!, adhan['path']!),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: context.colors.softGold, size: 20),
                              ],
                            ),
                            onTap: () {
                              ref.read(settingsProvider.notifier).setSelectedAdhan(adhan['id']!);
                              _playPreview(adhan['id']!, adhan['path']!);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          ),

          const SizedBox(height: 10),
          Divider(color: context.colors.emeraldLight.withOpacity(0.2)),
          
          SwitchListTile(
            title: Text(
              l10n.translate('pre_prayer_reminder'),
              style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Namoz vaqtidan 10 daqiqa oldin qisqacha ogohlantirish (Azon ovozisiz)',
              style: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 13),
            ),
            value: settings.prePrayerReminderEnabled,
            activeColor: context.colors.softGold,
            secondary: Icon(Icons.timer_outlined, color: context.colors.softGold),
            onChanged: (value) {
              ref.read(settingsProvider.notifier).togglePrePrayerReminder(value);
            },
          ),
          
          SwitchListTile(
            title: Text(
              l10n.translate('juma_reminder'),
              style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Har juma soat 10:00 da salovat aytish uchun eslatma kelishi',
              style: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 13),
            ),
            value: settings.jumaReminderEnabled,
            activeColor: context.colors.softGold,
            secondary: Icon(Icons.brightness_high_rounded, color: context.colors.softGold),
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleJumaReminder(value);
            },
          ),
        ],
      ),
    );
  }
}
