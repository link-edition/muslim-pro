import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/dua_settings_provider.dart';

class DuaSettingsSheet extends ConsumerWidget {
  const DuaSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(duaSettingsProvider);
    final notifier = ref.read(duaSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matn sozlamalari',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.colors.textMuted),
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          _buildSizeSlider(
            context,
            label: 'Arabcha matn',
            value: settings.arabicFontSize,
            min: 20,
            max: 42,
            onChanged: (val) => notifier.setArabicFontSize(val),
          ),
          
          _buildSizeSlider(
            context,
            label: "O'qilishi (Transkrripsiya)",
            value: settings.transcriptionFontSize,
            min: 12,
            max: 24,
            onChanged: (val) => notifier.setTranscriptionFontSize(val),
          ),
          
          _buildSizeSlider(
            context,
            label: 'Ma\'nosi (Tarjima)',
            value: settings.translationFontSize,
            min: 12,
            max: 24,
            onChanged: (val) => notifier.setTranslationFontSize(val),
          ),
          
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => notifier.reset(),
              child: Text(
                'Asliy holatiga qaytarish',
                style: GoogleFonts.inter(
                  color: context.colors.softGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        ),
      ),
    );
  }

  Widget _buildSizeSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                '${value.toInt()} px',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.softGold,
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: context.colors.softGold,
            inactiveTrackColor: context.colors.softGold.withOpacity(0.1),
            thumbColor: context.colors.softGold,
            overlayColor: context.colors.softGold.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

void showDuaSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const DuaSettingsSheet(),
  );
}
