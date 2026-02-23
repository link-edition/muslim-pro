import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../quran_provider.dart';
import '../data/quran_model.dart';

// ==========================================
// FON RANGLAR
// ==========================================
enum _BgTheme { light, sepia, dark }

const _gold = Color(0xFFD4A843);

Color _bg(_BgTheme t) => switch (t) { _BgTheme.light => const Color(0xFFFFFEF9), _BgTheme.sepia => const Color(0xFFF5ECD5), _BgTheme.dark => const Color(0xFF1A1A1A) };
Color _txt(_BgTheme t) => switch (t) { _BgTheme.light => const Color(0xFF1A0D00), _BgTheme.sepia => const Color(0xFF2C1A00), _BgTheme.dark => const Color(0xFFE8D5B5) };
Color _mut(_BgTheme t) => switch (t) { _BgTheme.light => const Color(0xFF8B7355), _BgTheme.sepia => const Color(0xFF8B6914), _BgTheme.dark => const Color(0xFF6B5B45) };
Color _brd(_BgTheme t) => _gold.withOpacity(t == _BgTheme.dark ? 0.1 : 0.25);
Color _bar(_BgTheme t) => t == _BgTheme.dark ? const Color(0xFF0D0D0D) : const Color(0xFF2C1A00);

// HTML tozalash
String _clean(String s) {
  var t = s.replaceAll(RegExp(r'<sup[^>]*>.*?</sup>', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'<[^>]*foot_note[^>]*>.*?</[^>]*>', caseSensitive: false), '');
  return t;
}
String _strip(String s) => _clean(s).replaceAll(RegExp(r'<[^>]*>'), '');

// ==========================================
// MUSHAF O'QISH SAHIFASI — 604 BET STANDARTI
// ==========================================
class SurahReadingScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  const SurahReadingScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahReadingScreen> createState() => _State();
}

class _State extends ConsumerState<SurahReadingScreen> {
  var _theme = _BgTheme.sepia;
  bool _tajweed = true;
  int _currentIdx = 0;
  PageController? _pc;

  /// Oyatlarni Mushaf sahifa raqamiga qarab guruhlash
  Map<int, List<AyahModel>> _groupByPage(List<AyahModel> ayahs) {
    final map = <int, List<AyahModel>>{};
    for (final a in ayahs) {
      map.putIfAbsent(a.pageNumber, () => []).add(a);
    }
    return map;
  }

  @override
  void dispose() {
    _pc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(surahDetailProvider);

    return Scaffold(
      backgroundColor: _bg(_theme),
      appBar: AppBar(
        backgroundColor: _bar(_theme),
        elevation: 0,
        toolbarHeight: 44,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _gold),
        ),
        title: Text(widget.surah.name, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: _gold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _showSettings, icon: const Icon(Icons.tune_rounded, size: 20, color: _gold)),
        ],
      ),
      body: _body(state),
    );
  }

  Widget _body(SurahDetailState state) {
    if (state.isLoading) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(color: _gold, strokeWidth: 3)),
          const SizedBox(height: 14),
          Text('Yuklanmoqda...', style: GoogleFonts.poppins(fontSize: 14, color: _mut(_theme))),
        ]),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: _mut(_theme)),
          const SizedBox(height: 12),
          Text('Internet xatolik', style: GoogleFonts.poppins(fontSize: 14, color: _mut(_theme))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(surahDetailProvider.notifier).loadAyahs(widget.surah),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            label: Text('Qayta yuklash', style: GoogleFonts.poppins(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: _gold),
          ),
        ]),
      );
    }

    if (state.ayahs.isEmpty) {
      return Center(child: Text('Oyatlar topilmadi', style: GoogleFonts.poppins(color: _mut(_theme))));
    }

    // Mushaf sahifalariga guruhlash
    final grouped = _groupByPage(state.ayahs);
    final pageKeys = grouped.keys.toList()..sort();
    final totalPages = pageKeys.length;

    _pc ??= PageController();

    return Column(
      children: [
        // PageView — horizontal, o'ngdan chapga
        Expanded(
          child: PageView.builder(
            controller: _pc,
            reverse: true,
            itemCount: totalPages,
            onPageChanged: (i) => setState(() => _currentIdx = i),
            itemBuilder: (_, i) {
              final pageNum = pageKeys[i];
              final ayahs = grouped[pageNum]!;
              final juz = ayahs.first.juzNumber;
              final isFirstPage = i == 0;

              return _FixedPage(
                ayahs: ayahs,
                pageNum: pageNum,
                juz: juz,
                surahName: widget.surah.englishName,
                theme: _theme,
                tajweed: _tajweed,
                showBismillah: isFirstPage && widget.surah.number != 1 && widget.surah.number != 9,
              );
            },
          ),
        ),

        // Pastki panel
        Container(
          color: _bar(_theme),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.surah.englishName}', style: GoogleFonts.poppins(fontSize: 10, color: _gold.withOpacity(0.5))),
                if (totalPages <= 15)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(totalPages, (i) => Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i == _currentIdx ? _gold : _gold.withOpacity(0.2)),
                    )),
                  ),
                Text(
                  'Sahifa ${pageKeys.isNotEmpty ? pageKeys[_currentIdx] : "-"} • ${_currentIdx + 1}/$totalPages',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _gold.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SOZLAMALAR
  // ==========================================
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Sozlamalar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.white54)),
            ]),
            const SizedBox(height: 20),
            Text('Fon rangi', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white60)),
            const SizedBox(height: 10),
            Row(children: [
              _bgBtn('Oq', Colors.white, _BgTheme.light, setS),
              const SizedBox(width: 10),
              _bgBtn('Sepia', const Color(0xFFF5ECD5), _BgTheme.sepia, setS),
              const SizedBox(width: 10),
              _bgBtn('Qora', const Color(0xFF1A1A1A), _BgTheme.dark, setS),
            ]),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text('Tajvid ', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                if (_tajweed) ...[_dot(const Color(0xFFB22222)), _dot(const Color(0xFF006400)), _dot(const Color(0xFF0000CD))],
              ]),
              Switch(value: _tajweed, activeColor: _gold, onChanged: (v) { setState(() => _tajweed = v); setS(() {}); }),
            ]),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _bgBtn(String l, Color c, _BgTheme t, void Function(void Function()) ss) {
    final sel = _theme == t;
    return Expanded(child: GestureDetector(
      onTap: () { setState(() => _theme = t); ss(() {}); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? _gold : Colors.transparent, width: 2.5)),
        alignment: Alignment.center,
        child: Text(l, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
          color: c.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)),
      ),
    ));
  }

  Widget _dot(Color c) => Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 3),
    decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}

// ==========================================
// BITTA MUSHAF SAHIFASI — FIXED HEIGHT
// ==========================================
class _FixedPage extends StatelessWidget {
  final List<AyahModel> ayahs;
  final int pageNum;
  final int juz;
  final String surahName;
  final _BgTheme theme;
  final bool tajweed;
  final bool showBismillah;

  const _FixedPage({
    required this.ayahs, required this.pageNum, required this.juz,
    required this.surahName, required this.theme, required this.tajweed,
    required this.showBismillah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg(theme),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: _bg(theme),
          border: Border.all(color: _brd(theme), width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: [
            // TEPAGI — Juz va Sura nomi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _brd(theme)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$juz-Juz', style: GoogleFonts.poppins(fontSize: 10, color: _mut(theme))),
                  Text(surahName, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _mut(theme))),
                  Text('$pageNum', style: GoogleFonts.poppins(fontSize: 10, color: _mut(theme))),
                ],
              ),
            ),

            // ASOSIY MATN — ekranga sig'adigan, scroll yo'q
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          maxHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bismilloh
                            if (showBismillah) ...[
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                                  style: GoogleFonts.amiri(fontSize: 22, color: _txt(theme), fontWeight: FontWeight.bold),
                                ),
                              ),
                              Divider(color: _brd(theme), height: 20),
                            ],

                            // Matn — FittedBox bilan sig'dirish
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: constraints.maxWidth - 24,
                                  child: tajweed ? _tajweedWidget() : _plainWidget(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // PASTGI — sahifa raqami
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: _brd(theme)))),
              child: Center(child: Text('— $pageNum —', style: GoogleFonts.poppins(fontSize: 9, color: _mut(theme).withOpacity(0.4)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tajweedWidget() {
    final html = ayahs.map((a) => _clean(a.textTajweed ?? a.text)).join(' ');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: HtmlWidget(
        '<div style="text-align:justify; line-height:2.4; direction:rtl;">$html</div>',
        textStyle: GoogleFonts.amiri(fontSize: 22, height: 2.2, color: _txt(theme)),
        customStylesBuilder: (el) {
          final c = el.className;
          if (c.contains('ham_wasl')) return {'color': '#808080'};
          if (c.contains('laam_shamsiyah')) return {'color': '#808080'};
          if (c.contains('madda_necessary')) return {'color': '#B22222'};
          if (c.contains('madda_normal')) return {'color': '#FF4500'};
          if (c.contains('madda_permissible')) return {'color': '#FF6347'};
          if (c.contains('qlq')) return {'color': '#0000CD'};
          if (c.contains('ghn')) return {'color': '#006400'};
          if (c.contains('ikhfa')) return {'color': '#DAA520'};
          if (c.contains('iqlab')) return {'color': '#228B22'};
          if (c.contains('idghm_shafawi')) return {'color': '#FF69B4'};
          if (c.contains('idghm_gyn') || c.contains('idghm_msl')) return {'color': '#9932CC'};
          if (c.contains('idghm_mutjns') || c.contains('idghm_mutqrb')) return {'color': '#BA55D3'};
          if (el.localName == 'span' && c.contains('end')) return {'color': '#D4A843', 'font-size': '70%'};
          return null;
        },
      ),
    );
  }

  Widget _plainWidget() {
    final text = ayahs.map((a) => _strip(a.textTajweed ?? a.text)).join(' ');
    return Text(
      text,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.amiri(fontSize: 22, height: 2.2, color: _txt(theme)),
    );
  }
}
