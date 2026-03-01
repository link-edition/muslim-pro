import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import '../data/dua_repository.dart';
import 'dua_list_screen.dart';
import 'dua_settings_sheet.dart';
import 'package:muslim_pro/core/localization.dart';

class SalovatlarScreen extends ConsumerWidget {
  const SalovatlarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salovatsAsync = ref.watch(duasByCategoryProvider('Salovat'));

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
          ref.watch(localizationProvider).translate('salovatlar'),
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
      body: salovatsAsync.when(
        data: (salovats) {
          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            itemCount: salovats.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: DuaItemCard(dua: salovats[index]),
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
