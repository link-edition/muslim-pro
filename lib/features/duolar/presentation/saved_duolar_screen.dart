import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/dua_repository.dart';
import 'dua_list_screen.dart';
import 'dua_settings_sheet.dart';
import 'package:muslim_pro/core/localization.dart';

class SavedDuolarScreen extends ConsumerWidget {
  const SavedDuolarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedDuasAsync = ref.watch(savedDuasListProvider);

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
          ref.watch(localizationProvider).translate('saqlanganlar') ?? 'Saqlanganlar',
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
      body: savedDuasAsync.when(
        data: (duas) {
          if (duas.isEmpty) {
            return Center(
              child: Text(
                ref.watch(localizationProvider).translate('saqlangan_yoq') ?? 'Hali hech narsa saqlanmagan',
                style: GoogleFonts.inter(color: context.colors.textMuted),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            itemCount: duas.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: DuaItemCard(dua: duas[index]),
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
