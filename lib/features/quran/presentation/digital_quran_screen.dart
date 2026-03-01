import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/quran/quran_provider.dart';
import 'digital_quran_detail_screen.dart';
import 'package:muslim_pro/core/localization.dart';

class DigitalQuranScreen extends ConsumerWidget {
  const DigitalQuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(quranListProvider);
    final l10n = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF040E0A) : context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.translate('mushaf'), // Reuse 'mushaf' label for digital tajweed version
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: listState.isLoading && listState.allSurahs.isEmpty
          ? Center(child: CircularProgressIndicator(color: context.colors.softGold))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    onChanged: (val) => ref.read(quranListProvider.notifier).search(val),
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.colors.cardBg,
                      hintText: l10n.translate('search_surah'),
                      hintStyle: TextStyle(color: context.colors.textMuted),
                      prefixIcon: Icon(Icons.search, color: context.colors.textMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: listState.filteredSurahs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final surah = listState.filteredSurahs[index];
                      return _SurahListTile(surah: surah, isDark: isDark);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SurahListTile extends StatelessWidget {
  final dynamic surah;
  final bool isDark;
  const _SurahListTile({required this.surah, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DigitalQuranDetailScreen(surah: surah)),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${surah.number}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37)),
            ),
          ),
        ),
        title: Text(
          surah.uzbekPhoneticName,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${surah.ayahCount} oyat • ${surah.revelationType}',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        ),
        trailing: Text(
          surah.name,
          style: GoogleFonts.amiri(fontSize: 20, color: const Color(0xFFD4AF37)),
        ),
      ),
    );
  }
}
