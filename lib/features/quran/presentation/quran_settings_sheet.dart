import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../quran_settings_provider.dart';

class QuranSettingsSheet extends ConsumerWidget {
  const QuranSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quranSettingsProvider);
    final notifier = ref.read(quranSettingsProvider.notifier);

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qur\'on matni sozlamalari',
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
          Divider(color: context.colors.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),
          
          _buildSizeSlider(
            context,
            label: 'Arabcha matni',
            value: settings.arabicFontSize,
            min: 18,
            max: 50,
            onChanged: (val) => notifier.setArabicFontSize(val),
          ),
          
          _buildSizeSlider(
            context,
            label: 'Tarjima o\'lchami',
            value: settings.translationFontSize,
            min: 10,
            max: 30,
            onChanged: (val) => notifier.setTranslationFontSize(val),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Tarjima alifbosi',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'latin',
                label: Text('Lotincha'),
              ),
              ButtonSegment(
                value: 'kril',
                label: Text('Kirillcha'),
              ),
            ],
            selected: {settings.translationScript},
            onSelectionChanged: (Set<String> newSelection) {
              notifier.setTranslationScript(newSelection.first);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return context.colors.iconBg.withOpacity(0.2);
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return context.colors.goldText;
                }
                return context.colors.textMuted;
              }),
            ),
          ),
          
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => notifier.reset(),
              child: Text(
                'Asliy holatiga qaytarish',
                style: GoogleFonts.inter(
                  color: context.colors.goldText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
          ),
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
                  color: context.colors.goldText,
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: context.colors.goldText,
            inactiveTrackColor: context.colors.emeraldLight.withOpacity(0.15),
            thumbColor: context.colors.goldText,
            overlayColor: context.colors.goldText.withOpacity(0.2),
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

void showQuranSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const QuranSettingsSheet(),
  );
}
