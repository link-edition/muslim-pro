import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/dua_model.dart';
import '../data/dua_repository.dart';
import 'dua_list_screen.dart';
import 'dua_settings_sheet.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';

class DuaCategoriesScreen extends ConsumerWidget {
  const DuaCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);
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
          ref.watch(localizationProvider).translate('duolar'),
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
      body: categoriesAsync.when(
        data: (categories) {
          final filteredCategories = categories.where((c) => c.id != 'Salovat').toList();
          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final category = filteredCategories[index];
              return RepaintBoundary(
                child: _DuaCategoryCard(category: category),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.emeraldMid)),
        error: (err, stack) => Center(child: Text('${ref.read(localizationProvider).translate('error_occured')}: $err')),
      ),
    );
  }
}

class _DuaCategoryCard extends ConsumerWidget {
  final DuaCategory category;
  const _DuaCategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final lang = ref.watch(settingsProvider).language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? context.colors.surface.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? context.colors.emeraldLight.withOpacity(0.2)
              : const Color(0xFFD4AF37).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.05 : 0.04),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (category.count > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DuaListScreen(category: category),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category.getName(lang)} — ${l10n.translate('Tez kunda')}'),
                  backgroundColor: context.colors.emeraldMid,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.colors.softGold.withOpacity(0.2), context.colors.softGold.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.getName(lang),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.count > 0 ? '${category.count} duo' : l10n.translate('Tez kunda'),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.emeraldMid.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
