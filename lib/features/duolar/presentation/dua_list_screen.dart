import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/dua_model.dart';
import '../data/dua_repository.dart';
import '../data/dua_settings_provider.dart';
import '../data/saved_duas_provider.dart';
import 'dua_settings_sheet.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class DuaListScreen extends ConsumerWidget {
  final DuaCategory category;
  
  const DuaListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByCategoryProvider(category.id));

    final l10n = ref.watch(localizationProvider);

    final lang = ref.watch(settingsProvider).language;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          category.getName(lang),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showDuaSettings(context),
            icon: Icon(Icons.settings_outlined, color: context.colors.softGold),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: duasAsync.when(
        data: (duas) {
          if (duas.isEmpty) {
            return Center(
              child: Text(
                l10n.translate("Bu bo'limda duolar hozircha yo'q"),
                style: GoogleFonts.inter(color: context.colors.textMuted),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
            itemCount: duas.length,
            cacheExtent: 1000, // Pre-renders items for smoother scrolling
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: DuaItemCard(dua: duas[index]),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.emeraldMid)),
        error: (e, st) => Center(child: Text('Xatolik: $e')),
      ),
    );
  }

}

class DuaItemCard extends ConsumerStatefulWidget {
  final Dua dua;
  const DuaItemCard({super.key, required this.dua});

  @override
  ConsumerState<DuaItemCard> createState() => _DuaItemCardState();
}

class _DuaItemCardState extends ConsumerState<DuaItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(duaSettingsProvider);
    final isSaved = ref.watch(savedDuasProvider).contains(widget.dua.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? context.colors.surface.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? context.colors.emeraldLight.withOpacity(0.15)
              : const Color(0xFFD4AF37).withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.02 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.transparent,
          child: ExpansionTile(
            onExpansionChanged: (val) {
              setState(() => _isExpanded = val);
            },
            shape: const Border(),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: context.colors.emeraldMid,
            collapsedIconColor: context.colors.emeraldMid.withOpacity(0.5),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.dua.getTitle(ref.watch(settingsProvider).language),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    
                    // Narrator Intro
                    if (widget.dua.narratorIntro.isNotEmpty) ...[
                      Text(
                        widget.dua.getNarratorIntro(ref.watch(settingsProvider).language),
                        style: GoogleFonts.inter(
                          fontSize: 14, // Fixed size
                          fontWeight: FontWeight.w400,
                          color: context.colors.textPrimary.withOpacity(0.85),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Arabic Text
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.dua.arabic,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.amiri(
                          fontSize: settings.arabicFontSize,
                          fontWeight: FontWeight.w600,
                          color: context.colors.goldText, // Made it softGold for high visibility
                          height: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Transliteration (faqat bo'lsa ko'rsatish)
                    if (widget.dua.transcription.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.emeraldLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(localizationProvider).translate("O'QILISHI:"),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: context.colors.emeraldMid,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ref.watch(localizationProvider).translate(widget.dua.transcription),
                              style: GoogleFonts.inter(
                                fontSize: settings.transcriptionFontSize,
                                fontStyle: FontStyle.italic,
                                color: context.colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Translation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.softGold.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* Text(
                            "MA'NOSI:",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: context.colors.softGold,
                            ),
                          ),
                          const SizedBox(height: 6), */
                          Text(
                            widget.dua.getTranslation(ref.watch(settingsProvider).language),
                            style: GoogleFonts.inter(
                              fontSize: settings.translationFontSize,
                              color: context.colors.textPrimary.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reference
                    if (widget.dua.reference.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.dua.reference.toUpperCase(),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            color: context.colors.emeraldMid.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(color: context.colors.emeraldLight.withOpacity(0.1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            ref.read(savedDuasProvider.notifier).toggleSaved(widget.dua.id);
                          },
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? context.colors.softGold : context.colors.textMuted,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final lang = ref.read(settingsProvider).language;
                            Clipboard.setData(ClipboardData(text: "${widget.dua.getTitle(lang)}\n\n${widget.dua.arabic}\n\n${widget.dua.getTranslation(lang)}"));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ref.read(localizationProvider).translate('Nusxa olindi!')),
                              backgroundColor: context.colors.emeraldMid,
                            ));
                          },
                          icon: Icon(Icons.copy, color: context.colors.textMuted),
                        ),
                        IconButton(
                          onPressed: () {
                            final lang = ref.read(settingsProvider).language;
                            Share.share("${widget.dua.getTitle(lang)}\n\n${widget.dua.arabic}\n\n${widget.dua.getTranslation(lang)}\n\nAmal ilovasidan yuborildi.");
                          },
                          icon: Icon(Icons.share, color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
